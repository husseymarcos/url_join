# url_join

[![Package Version](https://img.shields.io/hexpm/v/url_join)](https://hex.pm/packages/url_join)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/url_join/)

Join URL path segments and normalize the result, similar to [npm's url-join](https://www.npmjs.com/package/url-join).

## Installation

```sh
gleam add url_join
```

## Usage

```gleam
import url_join

pub fn main() -> Nil {
  // Join segments and normalize slashes, protocol, query, and hash
  let url =
    url_join.join([
      "http://www.google.com",
      "a",
      "/b/cd",
      "?foo=123",
    ])
  // -> "http://www.google.com/a/b/cd?foo=123"

  let api =
    url_join.join([
      "https://example.com/",
      "/api/",
      "users",
    ])
  // -> "https://example.com/api/users"
}
```

## Behaviour

- Filters out empty segments
- Merges a leading bare protocol (e.g. `"http:"`) with the next segment
- Merges a leading `"/"` with the next segment
- Normalises protocols to `protocol://` (and `file:///` for file)
- Trims and collapses slashes between segments
- Does not add a slash before `?`, `#`, or `&`
- Normalises query string (multiple `?`/`&` become a single `?` then `&`)

Further documentation can be found at <https://hexdocs.pm/url_join>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```