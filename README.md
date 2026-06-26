# Description

[![CI](https://github.com/alunduil/network-uri-json/actions/workflows/ci.yml/badge.svg)](https://github.com/alunduil/network-uri-json/actions/workflows/ci.yml)

> **Deprecated — use [aeson] instead.** Since aeson 2.2.0.0 (2023),
> aeson ships `FromJSON`/`ToJSON` (and `FromJSONKey`/`ToJSONKey`)
> instances for [`Network.URI.URI`][network-uri] directly. This
> package is redundant, and its orphan instances *conflict* with
> aeson's on aeson `>= 2.2` — the two cannot be imported together.
> Drop the `network-uri-json` dependency and use aeson's built-in
> instances.
>
> One behavioural difference if you relied on it: this package decoded
> with `parseURIReference` (accepts relative references such as
> `/path`), whereas aeson decodes with `parseURI` (absolute URIs
> only). The encoding (`uriToString`) is identical.

[FromJSON] and [ToJSON] Instances for [Network.URI][network-uri]

# Getting Started

Documentation is available on [Hackage].  A beginner's guide to
[Data.Aeson][aeson] is <https://artyom.me/aeson>.

# Building

Build, test, and generate Haddock documentation with [cabal]:

```
cabal build
cabal test
cabal haddock
```

# Reporting Issues

Any issues discovered should be recorded on [github][issues].  If you believe
you've found an error or have a suggestion for a new feature; please, ensure
that it is reported.

If you would like to contribute a fix or new feature; please, submit a pull
request.

# Contributors

The `COPYRIGHT` file contains a list of contributors with their respective
copyrights and other information.  If you submit a pull request and would like
attribution; please, add yourself to the `COPYRIGHT` file.

[aeson]: https://hackage.haskell.org/package/aeson
[cabal]: https://www.haskell.org/cabal/
[FromJSON]: https://hackage.haskell.org/package/aeson/docs/Data-Aeson.html#t:FromJSON
[Hackage]: https://hackage.haskell.org/package/network-uri-json
[Haskell]: https://www.haskell.org/
[issues]: https://github.com/alunduil/network-uri-json/issues
[network-uri]: https://hackage.haskell.org/package/network-uri
[ToJSON]: https://hackage.haskell.org/package/aeson/docs/Data-Aeson.html#t:ToJSON
