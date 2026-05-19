// Runs release-please with a PVP (https://pvp.haskell.org) versioning
// strategy. PVP is 4-component (A.B.C.D); release-please's Version class
// is 3-component (SemVer). A registered "pvp" strategy maps Conventional
// Commits to A.B / C / D bumps, and Version.parse / toString are patched
// to round-trip the 4th component through release-please's data flow.
//
// Mapping (matches AGENTS.md):
//   feat! / BREAKING CHANGE  -> A.B bump (bump B, reset C+D)
//   feat                     -> C   bump (bump C, reset D)
//   fix and everything else  -> D   bump
//
// release-please's GenericUpdater regex is SemVer-shaped too, so the
// cabal version is written via Octokit after the manifest run instead of
// through extra-files. That adds one follow-up commit to the release PR.

import {
  Manifest,
  GitHub,
  registerVersioningStrategy,
} from 'release-please';
import {Version} from 'release-please/build/src/version.js';
import {Octokit} from '@octokit/rest';

// --- Version patches ----------------------------------------------------

const PVP_RE = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/;

const _origParse = Version.parse.bind(Version);
Version.parse = function (s) {
  const m = String(s).match(PVP_RE);
  if (m) {
    const v = new Version(Number(m[1]), Number(m[2]), Number(m[3]));
    v._pvpD = Number(m[4]);
    return v;
  }
  return _origParse(s);
};

const _origToString = Version.prototype.toString;
Version.prototype.toString = function () {
  if (typeof this._pvpD === 'number') {
    return `${this.major}.${this.minor}.${this.patch}.${this._pvpD}`;
  }
  return _origToString.call(this);
};

// --- PVP version updaters ----------------------------------------------

function pvpVersion(major, minor, patch, d, preRelease, build) {
  const v = new Version(major, minor, patch, preRelease, build);
  v._pvpD = d;
  return v;
}

class PvpAbUpdate {
  bump(v) {
    return pvpVersion(v.major, v.minor + 1, 0, 0, v.preRelease, v.build);
  }
}
class PvpCUpdate {
  bump(v) {
    return pvpVersion(v.major, v.minor, v.patch + 1, 0, v.preRelease, v.build);
  }
}
class PvpDUpdate {
  bump(v) {
    const d = typeof v._pvpD === 'number' ? v._pvpD : 0;
    return pvpVersion(v.major, v.minor, v.patch, d + 1, v.preRelease, v.build);
  }
}
class NoopUpdate {
  bump(v) {
    return v;
  }
}

class PvpVersioningStrategy {
  bump(version, commits) {
    return this.determineReleaseType(version, commits).bump(version);
  }
  determineReleaseType(_version, commits) {
    let breaking = 0;
    let features = 0;
    let fixes = 0;
    for (const c of commits) {
      if (c.breaking) breaking++;
      else if (c.type === 'feat' || c.type === 'feature') features++;
      else if (c.type === 'fix') fixes++;
    }
    if (breaking > 0) return new PvpAbUpdate();
    if (features > 0) return new PvpCUpdate();
    if (fixes > 0) return new PvpDUpdate();
    return new NoopUpdate();
  }
}

registerVersioningStrategy('pvp', () => new PvpVersioningStrategy());

// --- Cabal write via Octokit -------------------------------------------

const CABAL_PATH = process.env.CABAL_FILE || 'network-uri-json.cabal';
const MANIFEST_PATH = '.release-please-manifest.json';

async function syncCabalToManifest(octokit, owner, repo, prBranch) {
  const manifestFile = await octokit.repos.getContent({
    owner,
    repo,
    path: MANIFEST_PATH,
    ref: prBranch,
  });
  const manifest = JSON.parse(
    Buffer.from(manifestFile.data.content, 'base64').toString('utf8'),
  );
  const newVersion = manifest['.'];
  if (!newVersion) {
    throw new Error(`manifest at ${prBranch} has no entry for "."`);
  }

  const cabalFile = await octokit.repos.getContent({
    owner,
    repo,
    path: CABAL_PATH,
    ref: prBranch,
  });
  const cabal = Buffer.from(cabalFile.data.content, 'base64').toString('utf8');
  const updated = cabal.replace(
    /^(version:\s*)[0-9][0-9.]*/m,
    `$1${newVersion}`,
  );

  if (updated === cabal) {
    console.log(`cabal version already ${newVersion}; skipping commit`);
    return;
  }

  await octokit.repos.createOrUpdateFileContents({
    owner,
    repo,
    path: CABAL_PATH,
    message: `chore(release): bump ${CABAL_PATH} to ${newVersion}`,
    content: Buffer.from(updated, 'utf8').toString('base64'),
    sha: cabalFile.data.sha,
    branch: prBranch,
  });
  console.log(`bumped ${CABAL_PATH} to ${newVersion} on ${prBranch}`);
}

// --- Run release-please -------------------------------------------------

const slug = process.env.GITHUB_REPOSITORY;
if (!slug) {
  console.error('GITHUB_REPOSITORY required');
  process.exit(1);
}
const [owner, repo] = slug.split('/');
const targetBranch = process.env.RELEASE_PLEASE_TARGET_BRANCH || 'main';
const token = process.env.GITHUB_TOKEN;
if (!token) {
  console.error('GITHUB_TOKEN required');
  process.exit(1);
}

const github = await GitHub.create({
  owner,
  repo,
  token,
  defaultBranch: targetBranch,
});

const manifest = await Manifest.fromManifest(
  github,
  targetBranch,
  'release-please-config.json',
  '.release-please-manifest.json',
);

const prs = (await manifest.createPullRequests()).filter(Boolean);
const releases = (await manifest.createReleases()).filter(Boolean);

if (prs.length > 0) {
  const octokit = new Octokit({auth: token});
  for (const pr of prs) {
    console.log(`release PR ready: #${pr.number} (${pr.headBranchName})`);
    await syncCabalToManifest(octokit, owner, repo, pr.headBranchName);
  }
} else {
  console.log('no release PR changes');
}

if (releases.length > 0) {
  console.log(
    `created release(s): ${releases.map(r => r.tagName).join(', ')}`,
  );
} else {
  console.log('no releases to create');
}
