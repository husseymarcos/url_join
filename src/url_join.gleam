import gleam/list
import gleam/string
import url_join/merge
import url_join/parts
import url_join/query

pub fn join(parts: List(String)) -> String {
  let filtered = list.filter(parts, fn(part) { !string.is_empty(part) })
  normalize(filtered)
}

fn normalize(segments: List(String)) -> String {
  case segments {
    [] -> ""
    [first, ..rest] -> {
      let merged = merge.merge_leading_parts(first, rest)
      let processed = parts.process(merged)
      let joined = parts.join(processed)
      query.normalize(joined)
    }
  }
}
