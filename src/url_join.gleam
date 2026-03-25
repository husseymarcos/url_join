//// Join URL path segments and normalize the result.
////
//// A simple and clean library for combining URL segments into a properly
//// formatted URL. Handles protocols, slashes, query parameters, and hash
//// fragments automatically.
////
//// ## Example
////
//// ```gleam
//// import url_join
////
//// let url = url_join.join([
////   "https://example.com",
////   "api",
////   "v1",
////   "users",
////   "?page=1",
//// ])
//// // -> "https://example.com/api/v1/users?page=1"
//// ```

import gleam/list
import gleam/string

/// Join URL path segments and normalize the result.
///
/// This function takes a list of URL segments and combines them into a single,
/// properly normalized URL. It handles protocols, slashes, query strings, and
/// hash fragments intelligently.
///
/// ## Examples
///
/// ```gleam
/// join(["http://www.google.com", "a", "/b/cd", "?foo=123"])
/// // -> "http://www.google.com/a/b/cd?foo=123"
///
/// join(["https://example.com/", "/api/", "users"])
/// // -> "https://example.com/api/users"
///
/// join(["a", "b", "c"])
/// // -> "a/b/c"
/// ```
///
/// ## Behaviour
///
/// - Filters out empty segments
/// - Merges a leading bare protocol (e.g. `"http:"`) with the next segment
/// - Merges a leading `"/"` with the next segment  
/// - Normalises protocols to `protocol://` (and `file:///` for file)
/// - Trims and collapses slashes between segments
/// - Does not add a slash before `?`, `#`, or `&`
/// - Normalises query string (multiple `?`/`&` become a single `?` then `&`)
///
pub fn join(parts: List(String)) -> String {
  parts
  |> list.filter(fn(part) { !string.is_empty(part) })
  |> normalize
}

fn normalize(segments: List(String)) -> String {
  case segments {
    [] -> ""
    [first, ..rest] ->
      first
      |> merge_leading_parts(rest)
      |> process_parts
      |> join_parts
      |> normalize_query
  }
}

// ============================================================================
// Merge Leading Parts
// ============================================================================

fn merge_leading_parts(first: String, rest: List(String)) -> List(String) {
  case rest {
    [] -> [normalize_protocol(first)]
    [next, ..tail] -> {
      case is_plain_protocol(first), first == "/" {
        True, _ -> merge_leading_parts(first <> next, tail)
        _, True -> merge_leading_parts("/" <> next, tail)
        _, _ -> [normalize_protocol(first), ..rest]
      }
    }
  }
}

fn is_plain_protocol(s: String) -> Bool {
  case string.split_once(s, on: ":") {
    Ok(#(before, after)) ->
      !string.contains(before, "/")
      && !string.contains(before, ":")
      && only_slashes_or_empty(after)
    Error(_) -> False
  }
}

fn only_slashes_or_empty(s: String) -> Bool {
  s |> string.replace("/", "") |> string.is_empty
}

// ============================================================================
// Protocol Normalization
// ============================================================================

fn normalize_protocol(s: String) -> String {
  let is_file_triple = string.starts_with(s, "file:///")
  let is_file = string.starts_with(s, "file:")
  let is_ipv6 = string.starts_with(s, "[") && string.contains(s, "]")

  // By matching on a tuple of conditions, we flatten the deep nesting entirely.
  case is_file_triple, is_file, is_ipv6, string.split_once(s, "://"), string.split_once(s, ":") {
    True, _, _, _, _ -> s
    _, True, _, _, _ -> "file:///" <> drop_leading_slashes(string.drop_start(s, 5))
    _, _, True, _, _ -> s
    _, _, _, Ok(_), _ -> s
    _, _, _, Error(_), Ok(#(protocol, rest)) -> protocol <> "://" <> drop_leading_slashes(rest)
    _, _, _, _, _ -> s
  }
}

// ============================================================================
// Slash Handling
// ============================================================================

// Replaced complex string reversing and grapheme popping with simple recursion
// using `string.drop_start` and `string.drop_end`.
fn drop_leading_slashes(s: String) -> String {
  case string.starts_with(s, "/") {
    True -> drop_leading_slashes(string.drop_start(s, 1))
    False -> s
  }
}

fn drop_trailing_slashes(s: String) -> String {
  case string.ends_with(s, "/") {
    True -> drop_trailing_slashes(string.drop_end(s, 1))
    False -> s
  }
}

fn collapse_trailing_slashes(s: String) -> String {
  let trimmed = drop_trailing_slashes(s)
  case string.ends_with(s, "/"), string.is_empty(trimmed) {
    True, False -> trimmed <> "/"
    _, _ -> trimmed
  }
}

// ============================================================================
// Part Processing
// ============================================================================

fn process_parts(parts: List(String)) -> List(String) {
  let len = list.length(parts)
  parts
  |> list.index_map(fn(part, i) {
    let no_leading = case i > 0 {
      True -> drop_leading_slashes(part)
      False -> part
    }
    case i < len - 1 {
      True -> drop_trailing_slashes(no_leading)
      False -> collapse_trailing_slashes(no_leading)
    }
  })
  |> list.filter(fn(p) { !string.is_empty(p) })
}

fn join_parts(parts: List(String)) -> String {
  case parts {
    [] -> ""
    // Use list.fold instead of manually recreating the recursive loop
    [first, ..rest] -> list.fold(rest, first, join_two_parts)
  }
}

fn join_two_parts(prev: String, part: String) -> String {
  case string.ends_with(prev, "?") || string.ends_with(prev, "#") {
    True -> prev <> part
    False -> prev <> "/" <> part
  }
}

// ============================================================================
// Query Normalization
// ============================================================================

fn normalize_query(s: String) -> String {
  s
  |> string.replace("/?", "?")
  |> string.replace("/#", "#")
  |> string.replace("/&", "&")
  |> normalize_query_params
}

fn normalize_query_params(s: String) -> String {
  case string.split_once(s, on: "#") {
    Ok(#(before_hash, after_hash)) -> {
      let hash = case after_hash {
        "" -> ""
        _ -> "#" <> after_hash
      }
      build_query(before_hash) <> hash
    }
    Error(_) -> build_query(s)
  }
}

fn build_query(s: String) -> String {
  case split_query_parts(s) {
    [] -> s
    [path] -> path
    [path, ..params] -> path <> "?" <> string.join(params, "&")
  }
}

fn split_query_parts(s: String) -> List(String) {
  s
  |> string.replace("?", "&")
  |> string.split("&")
  |> list.filter(fn(x) { !string.is_empty(x) })
}