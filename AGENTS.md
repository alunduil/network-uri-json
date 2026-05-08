# AGENTS.md

Repo conventions for AI coding agents working on `network-uri-json`.
Repo-specific only — does not duplicate user-level or general Haskell
guidance.

## What this is

A small library: `FromJSON`/`ToJSON` instances for `Network.URI.URI`. One
public module (`src/Network/URI/JSON.hs`), one hspec suite
(`test/Network/URI/JSONSpec.hs`). The interesting work happens in tests.

## Setup & commands

- `cabal build` — compile library and tests.
- `cabal test` — run the hspec suite.
- `cabal haddock` — render Haddock for the library.

GHC versions exercised: see `tested-with` in `network-uri-json.cabal`.
The cabal file still uses `cabal-version: >=1.10` syntax; that flips
to `3.0` under #56.

## Code style

- **Orphans confined to `Network.URI.JSON`.** This module exists to
  hold the orphan instances for `URI`. Don't reintroduce orphans
  elsewhere or split the module.
- **No partial functions in library code.** `src/Network/URI/JSON.hs`
  uses `withText` + `maybe ... fail` for parse failure — match that.
  `fromJust` / `head` / `error` are acceptable in test scaffolding
  only, because failure surfaces as a test failure.
- **Formatter.** Ormolu adoption is in flight (#60). Until it lands,
  match the surrounding style; don't introduce a competing formatter
  or reformat unrelated code in passing.

## Testing

- Stack: `hspec` + `hspec-discover` + `network-arbitrary` (URI
  generators) + `test-invariant` (`<=>` for invariant laws).
- The existing round-trip property `fromJust . decode . encode <=> id`
  is the template — new behaviour should ship with a property where
  the law makes sense (round-trip, idempotence, etc.). Property
  roadmap: #67.
- Don't test upstream behaviour (aeson decoding, `network-uri`
  parsing). Project tests cover this library's instances and
  invariants only.

## Pull requests

- **Trunk-based.** Branch from `develop` today; the default flips to
  `main` under #70.
- **Conventional commits.** `feat:` / `fix:` / `chore:` / `docs:` /
  `ci:` / `test:` / `refactor:`. Imperative subject ≤50 chars, blank
  line, wrapped body when context is needed.
- **PVP versioning** (<https://pvp.haskell.org>). Working mapping
  until #80 formalises it:
  - `feat!:` / `BREAKING CHANGE:` — A.B bump (major)
  - `feat:` adding to the public API — C bump (minor)
  - `fix:` or non-API change — D bump (patch)
  - non-user-visible (`chore:`, `ci:`, `test:`, `docs:`) — no bump
- **Draft PRs by default.** Maintainer promotes to ready after review.
- **Squash merge, linear history** (#71). Don't worry about
  commit-by-commit cleanliness; the squash collapses noise.

## Don't touch

- **`text` bound** stays `>=1.2 && <3` (#93). Don't tighten the lower
  bound — older Stackage LTS series are still in scope.
- **`network-uri` bound** stays `>=2.6 && <2.8` until upstream ships
  2.8. Bumping requires a PVP-aware bound bump, not a silent upgrade.
- **`aeson` bound** spans 1.x and 2.x; both must keep building.
- **Public API.** `stability: stable` in the cabal file. Removing or
  renaming exports is a major bump and needs explicit user direction;
  additive changes are tracked in #62.
- **In-flight modernization artefacts.** `default.nix`, `shell.nix`,
  `network-uri-json.nix`, `nix/`, `.envrc`, and the cabal
  `source-repository`'s `branch: develop` field are all queued for
  removal or update. Don't update them in passing; cite the relevant
  issue under #89 instead.

## Modernization status

This repo is mid-modernization toward the `network-arbitrary`
template. State that doesn't match the template
(no `.github/workflows`, no `.devcontainer`, `cabal-version: >=1.10`,
default branch `develop`) is intentional and tracked. **Master tracker:
#89** — read it before assuming a missing piece is an oversight rather
than a queued issue.
