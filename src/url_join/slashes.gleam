import gleam/string

pub fn trim_leading(s: String) -> String {
  drop_leading_chars(s, "/")
}

pub fn trim_trailing(s: String) -> String {
  drop_trailing_chars(s, "/")
}

pub fn collapse_trailing(s: String) -> String {
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
