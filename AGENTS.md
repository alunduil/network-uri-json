# AGENTS.md

Repo conventions for AI agents working on `network-uri-json`. Repo-specific
only; does not duplicate user-level or general Haskell guidance.

## What this is

A small library: `FromJSON`/`ToJSON` instances for `Network.URI.URI`. One
public module (`src/Network/URI/JSON.hs`), one hspec suite
(`test/Network/URI/JSONSpec.hs`). The interesting work happens in tests.

## Commands

- `cabal build` — compile library and tests.
- `cabal test` — run the hspec suite.
- `cabal haddock` — render Haddock for the library.

Lint and format tooling (ormolu, hlint, `cabal check`, `cabal-gild`) is being
introduced under milestone 0.4.0.2 — see #60, #61, #65, #68. Until those
land, don't introduce a competing formatter or lint config.

## Invariants

- **PVP versioning** (<https://pvp.haskell.org>). Major bumps for breaking
  changes, minor for additive, patch for non-API. The
  conventional-commits → PVP mapping is being formalised in #80.
- **Property-test coverage.** Tests use `hspec` + `network-arbitrary`
  (URI generators) + `test-invariant`. The existing round-trip property
  (`fromJust . decode . encode <=> id`) is the template — new behaviour
  should ship with a property where the law makes sense (round-trip,
  idempotence). Property roadmap: #67.
- **No partial functions in library code.** `src/Network/URI/JSON.hs` uses
  `withText` + `maybe ... fail` for parse failure; match that. `fromJust`
  is acceptable in test scaffolding only because failure surfaces as a
  test failure.
- **Orphans confined to `Network.URI.JSON`.** This module exists to hold
  the orphan instances for `URI`. Don't reintroduce orphans elsewhere.

## Don't touch

- **`text` bound** stays `>=1.2 && <3` (#93). Don't tighten the lower
  bound — older Stackage LTS series are still in scope.
- **`network-uri` bound** stays `>=2.6 && <2.8` until upstream ships 2.8.
  Bumping requires a PVP-aware bound bump, not a silent upgrade.
- **`aeson` bound** spans 1.x and 2.x; both must keep building.
- **Public API.** `stability: stable` in the cabal file. Removing or
  renaming exports is a major bump and needs explicit user direction;
  additive changes are tracked in #62.
- **Nix files** (`default.nix`, `shell.nix`, `network-uri-json.nix`,
  `nix/`, `.envrc`) are slated for removal alongside devcontainer
  adoption — decision recorded in #89. Don't update them; cite the
  retirement issue if they need to change.
- **`source-repository` `branch:` field** in the cabal file currently
  reads `develop`; it flips to `main` under #70. Don't update it ahead
  of that issue.

## Modernization in flight

The repo is mid-modernization — see #89 (master tracker) before assuming
state matches the `network-arbitrary` template. Notably absent today:
`.github/workflows/`, `.devcontainer/`, `.pre-commit-config.yaml`,
`cabal-version: 3.0` syntax, `main` as the default branch. Each is its
own issue under milestones 0.4.0.1–0.4.0.3.

## Layout

- `src/Network/URI/JSON.hs` — the entire library.
- `test/Spec.hs`, `test/Network/URI/JSONSpec.hs` — hspec suite.
- `network-uri-json.cabal` — package description (still `>=1.10`
  syntax until #56).
- `ChangeLog.md` — release notes; Keep a Changelog adoption tracked
  separately.
- `README.md` — public-facing.
