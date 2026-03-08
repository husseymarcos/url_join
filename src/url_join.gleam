// Join URL path segments and normalize the result, similar to npm's url-join.
// See: https://www.npmjs.com/package/url-join

import gleam/list
import gleam/string

/// Join two or more URL path segments into a single URL, normalizing slashes
/// and handling protocols, query strings, and hashes.
///
/// ## Examples
///
/// ```gleam
/// join(["http://www.google.com", "a", "/b/cd", "?foo=123"])
/// // -> "http://www.google.com/a/b/cd?foo=123"
///
/// join(["https://example.com/", "/api/", "users"])
/// // -> "https://example.com/api/users"
/// ```
pub fn join(parts: List(String)) -> String {
  let filtered = list.filter(parts, fn(part) { !string.is_empty(part) })
  normalize(filtered)
}

fn normalize(parts: List(String)) -> String {
  case parts {
    [] -> ""
    [first, ..rest] -> {
      let merged = merge_leading_parts(first, rest)
      let processed = process_parts(merged)
      let joined = join_parts(processed)
      normalize_query_and_hash(joined)
    }
  }
}

// If the first part is a bare protocol (e.g. "http:") or leading "/", merge with next.
fn merge_leading_parts(first: String, rest: List(String)) -> List(String) {
  case rest {
    [] -> [normalize_protocol(first)]
    [next, ..tail] -> {
      case is_plain_protocol(first), first == "/" {
        True, _ -> merge_leading_parts(first <> next, tail)
        _, True -> merge_leading_parts("/" <> next, tail)
        _, _ -> [normalize_protocol(first), ..list.map(rest, fn(p) { p })]
      }
    }
  }
}

fn is_plain_protocol(s: String) -> Bool {
  case string.split_once(s, on: ":") {
    Ok(#(before, after)) -> {
      !string.contains(does: before, contain: "/")
      && !string.contains(does: before, contain: ":")
      && only_slashes_or_empty(after)
    }
    Error(_) -> False
  }
}

fn only_slashes_or_empty(s: String) -> Bool {
  string.replace(in: s, each: "/", with: "") |> string.is_empty
}

fn normalize_protocol(s: String) -> String {
  case string.starts_with(s, "file:///") {
    True -> s
    False -> case string.starts_with(s, "file:") {
      True ->
        // file: or file:/ or file:// -> file:///
        "file:///" <> trim_leading_slashes(string.drop_start(s, up_to: 5))
      False -> case is_ipv6_host(s) {
        True -> s
        False -> {
          case string.split_once(s, on: "://") {
            Ok(_) -> s
            Error(_) -> {
              case string.split_once(s, on: ":") {
                Ok(#(protocol, rest)) -> {
                  let rest_trimmed = trim_leading_slashes(rest)
                  protocol <> "://" <> rest_trimmed
                }
                Error(_) -> s
              }
            }
          }
        }
      }
    }
  }
}

fn is_ipv6_host(s: String) -> Bool {
  string.starts_with(s, "[") && string.contains(does: s, contain: "]")
}

fn process_parts(parts: List(String)) -> List(String) {
  list.index_map(parts, fn(part, i) {
    let len = list.length(parts)
    let no_leading =
      case i > 0 {
        True -> trim_leading_slashes(part)
        False -> part
      }
    case i < len - 1 {
      True -> trim_trailing_slashes(no_leading)
      False -> collapse_trailing_slash(no_leading)
    }
  })
  |> list.filter(fn(p) { !string.is_empty(p) })
}

fn trim_leading_slashes(s: String) -> String {
  drop_leading_chars(s, "/")
}

fn trim_trailing_slashes(s: String) -> String {
  drop_trailing_chars(s, "/")
}

// Replace multiple trailing slashes with a single /
fn collapse_trailing_slash(s: String) -> String {
  let trimmed = drop_trailing_chars(s, "/")
  case string.ends_with(s, "/"), string.is_empty(trimmed) {
    True, False -> trimmed <> "/"
    _, _ -> trimmed
  }
}

fn drop_leading_chars(s: String, char: String) -> String {
  case string.pop_grapheme(s) {
    Ok(#(g, rest)) -> case g == char {
      True -> drop_leading_chars(rest, char)
      False -> s
    }
    Error(_) -> ""
  }
}

fn drop_trailing_chars(s: String, char: String) -> String {
  case string.pop_grapheme(string.reverse(s)) {
    Ok(#(g, rev_rest)) -> case g == char {
      True -> string.reverse(rev_rest) |> drop_trailing_chars(char)
      False -> s
    }
    Error(_) -> ""
  }
}

fn join_parts(parts: List(String)) -> String {
  case parts {
    [] -> ""
    [one] -> one
    [first, second, ..rest] -> {
      let acc = join_two(first, second)
      list.fold(rest, acc, fn(acc, part) { join_two(acc, part) })
    }
  }
}

fn join_two(prev: String, part: String) -> String {
  case string.ends_with(prev, "?"), string.ends_with(prev, "#") {
    True, _ | _, True -> prev <> part
    _, _ -> prev <> "/" <> part
  }
}

// Remove trailing slash before ? & # and normalize query (?) and (&) to &
fn normalize_query_and_hash(s: String) -> String {
  let no_slash_before_special =
    string.replace(in: s, each: "/?", with: "?")
  let no_slash_before_hash =
    string.replace(in: no_slash_before_special, each: "/#", with: "#")
  let no_slash_before_amp =
    string.replace(in: no_slash_before_hash, each: "/&", with: "&")
  normalize_query_params(no_slash_before_amp)
}

fn normalize_query_params(s: String) -> String {
  case string.split_once(s, on: "#") {
    Ok(#(before_hash, after_hash)) -> {
      let hash_suffix =
        case string.is_empty(after_hash) {
          True -> ""
          False -> "#" <> after_hash
        }
      let parts = split_query_parts(before_hash)
      case parts {
        [] -> s
        [path] -> path <> hash_suffix
        [path, ..params] -> {
          path <> "?" <> string.join(params, with: "&") <> hash_suffix
        }
      }
    }
    Error(_) -> {
      let parts = split_query_parts(s)
      case parts {
        [] -> s
        [path] -> path
        [path, ..params] -> path <> "?" <> string.join(params, with: "&")
      }
    }
  }
}

// Split by ? and & so "path?foo=1&bar=2" -> ["path", "foo=1", "bar=2"]
fn split_query_parts(s: String) -> List(String) {
  string.replace(in: s, each: "?", with: "&")
  |> string.split(on: "&")
  |> list.filter(fn(x) { !string.is_empty(x) })
}
