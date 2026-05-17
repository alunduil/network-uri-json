#!/usr/bin/env bash
# Rewrites the SemVer artifacts release-please-action just wrote into
# PVP (https://pvp.haskell.org) form, on the release PR branch.
#
# release-please-action is SemVer-native: it reads conventional commits,
# bumps a 3-component version, and writes that to .release-please-manifest.json,
# the cabal version line, and the latest ChangeLog.md heading. This script
# maps that SemVer bump direction (major/minor/patch) onto a PVP bump
# (A.B / C / D) and rewrites the user-facing surfaces (.cabal, ChangeLog.md).
# .release-please-manifest.json stays in SemVer so release-please can keep
# bumping it on the next push.
#
# Inputs (env):
#   BASE_REF — git ref to read prior versions from (default: origin/main)
#   CABAL_FILE — path to cabal file (default: network-uri-json.cabal)
#   CHANGELOG_FILE — path to changelog (default: ChangeLog.md)
#   MANIFEST_FILE — release-please manifest (default: .release-please-manifest.json)

set -euo pipefail

base_ref="${BASE_REF:-origin/main}"
cabal_file="${CABAL_FILE:-network-uri-json.cabal}"
changelog_file="${CHANGELOG_FILE:-ChangeLog.md}"
manifest_file="${MANIFEST_FILE:-.release-please-manifest.json}"

read_cabal_version() {
  sed -n 's/^version: *\([0-9][0-9.]*\).*/\1/p' "$1" | head -1
}

new_semver=$(jq -r '."."' "$manifest_file")
old_semver=$(git show "$base_ref:$manifest_file" | jq -r '."."')
old_pvp=$(git show "$base_ref:$cabal_file" | sed -n 's/^version: *\([0-9][0-9.]*\).*/\1/p' | head -1)

if [[ -z "$new_semver" || -z "$old_semver" || -z "$old_pvp" ]]; then
  echo "post-processor: missing version data (new=$new_semver old=$old_semver pvp=$old_pvp)" >&2
  exit 1
fi

if [[ "$new_semver" == "$old_semver" ]]; then
  echo "post-processor: manifest unchanged ($new_semver); nothing to do" >&2
  exit 0
fi

IFS='.' read -r old_major old_minor old_patch <<< "$old_semver"
IFS='.' read -r new_major new_minor new_patch <<< "$new_semver"

if [[ "$old_major" != "$new_major" ]]; then
  direction='major'
elif [[ "$old_minor" != "$new_minor" ]]; then
  direction='minor'
elif [[ "$old_patch" != "$new_patch" ]]; then
  direction='patch'
else
  echo "post-processor: cannot infer bump direction from $old_semver -> $new_semver" >&2
  exit 1
fi

IFS='.' read -r pvp_a pvp_b pvp_c pvp_d <<< "$old_pvp"
case "$direction" in
  major) pvp_b=$((pvp_b + 1)); pvp_c=0; pvp_d=0 ;;
  minor) pvp_c=$((pvp_c + 1)); pvp_d=0 ;;
  patch) pvp_d=$((pvp_d + 1)) ;;
esac
new_pvp="$pvp_a.$pvp_b.$pvp_c.$pvp_d"

# Rewrite cabal version. release-please's simple updater touched it to SemVer;
# we put it back to PVP. Preserve the original column alignment by reading the
# whitespace span between "version:" and the value.
python3 - "$cabal_file" "$new_pvp" <<'PY'
import re, sys
path, new = sys.argv[1], sys.argv[2]
with open(path) as f:
    src = f.read()
src = re.sub(r'^(version:\s*)[0-9][0-9.]*', lambda m: m.group(1) + new, src, count=1, flags=re.M)
with open(path, 'w') as f:
    f.write(src)
PY

# Rewrite the latest changelog heading from the SemVer release-please wrote
# to PVP. Headings look like "## [0.5.0](...)" or "## 0.5.0 (...)" — match
# the version token after a leading "## " and replace the first occurrence.
python3 - "$changelog_file" "$new_semver" "$new_pvp" <<'PY'
import re, sys
path, semver, pvp = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    src = f.read()
pat = re.compile(r'(^##\s+\[?)' + re.escape(semver) + r'(\]?)', re.M)
src, n = pat.subn(lambda m: m.group(1) + pvp + m.group(2), src, count=1)
if n == 0:
    sys.exit(f"post-processor: changelog heading for {semver} not found in {path}")
with open(path, 'w') as f:
    f.write(src)
PY

echo "post-processor: rewrote $cabal_file and $changelog_file to PVP $new_pvp (from SemVer $new_semver, $direction bump)"
