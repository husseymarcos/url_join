import gleam/list
import gleam/string
import url_join/slashes

pub fn process(parts: List(String)) -> List(String) {
  list.index_map(parts, fn(part, i) {
    let len = list.length(parts)
    let no_leading = case i > 0 {
      True -> slashes.trim_leading(part)
      False -> part
    }
    case i < len - 1 {
      True -> slashes.trim_trailing(no_leading)
      False -> slashes.collapse_trailing(no_leading)
    }
  })
  |> list.filter(fn(p) { !string.is_empty(p) })
}

pub fn join(parts: List(String)) -> String {
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
