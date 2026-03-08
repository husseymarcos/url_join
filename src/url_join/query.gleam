import gleam/list
import gleam/string

pub fn normalize(s: String) -> String {
  let no_slash_before_special = string.replace(in: s, each: "/?", with: "?")
  let no_slash_before_hash =
    string.replace(in: no_slash_before_special, each: "/#", with: "#")
  let no_slash_before_amp =
    string.replace(in: no_slash_before_hash, each: "/&", with: "&")
  normalize_params(no_slash_before_amp)
}

fn normalize_params(s: String) -> String {
  case string.split_once(s, on: "#") {
    Ok(#(before_hash, after_hash)) -> {
      let hash_suffix = case string.is_empty(after_hash) {
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

fn split_query_parts(s: String) -> List(String) {
  string.replace(in: s, each: "?", with: "&")
  |> string.split(on: "&")
  |> list.filter(fn(x) { !string.is_empty(x) })
}
