# AGENTS.md

## Setup

- `cabal build`
- `cabal test`
- `cabal haddock`

## Code style

- Orphan instances for `URI` live in `Network.URI.JSON`. Don't
  reintroduce orphans elsewhere or split the module.
- Library code: no partial functions. `src/Network/URI/JSON.hs` uses
  `withText` + `maybe ... fail` for parse failure — match that
  pattern. `fromJust` / `head` / `error` are acceptable only in test
  scaffolding, where failure surfaces as a test failure.
- Formatter: ormolu adoption is in flight (#60). Until it lands,
  match surrounding style; don't introduce a competing formatter or
  reformat unrelated code in passing.

## Testing

- `network-arbitrary` supplies `URI` generators; `test-invariant`
  supplies `<=>` for invariant laws.
- The round-trip property `fromJust . decode . encode <=> id` in
  `test/Network/URI/JSONSpec.hs` is the template — new behaviour
  should ship with a property where the law makes sense (round-trip,
  idempotence). Property roadmap: #67.
- Don't test upstream behaviour (aeson decoding, `network-uri`
  parsing). Project tests cover this library's instances only.

## Pull requests

- Conventional commits, imperative subject ≤50 chars.
- PVP bumps (<https://pvp.haskell.org>) — working mapping until #80
  formalises it:
  - `feat!:` / `BREAKING CHANGE:` → A.B (major)
  - `feat:` adding public API → C (minor)
  - `fix:` or non-API change → D (patch)
  - `chore:` / `ci:` / `test:` / `docs:` → no bump
- Draft PRs by default; maintainer promotes after review.
- Squash merge, linear history (#71).

## Don't touch

- `text` bound stays `>=1.2 && <3` (#93) — older Stackage LTS series
  are still in scope.
- `network-uri` bound stays `>=2.6 && <2.8` until upstream ships 2.8.
- `aeson` bound spans 1.x and 2.x; both must keep building.
- Public API is `stability: stable`. Removing or renaming exports is
  a major bump and needs explicit direction; additive changes are
  tracked in #62.
- `default.nix`, `shell.nix`, `network-uri-json.nix`, `nix/`, and
  `.envrc` are queued for removal — the devcontainer (#54) supersedes
  them. Don't update in passing.

## Modernization status

Mid-modernization toward the `network-arbitrary` template. Outstanding
gaps (`.github/workflows`, `.devcontainer`, `cabal-version: 3.0`) are
tracked across the modernization milestones (0.4.0.1, 0.4.0.2,
0.4.0.3). Check the relevant milestone before treating a gap as an
oversight.
