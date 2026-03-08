import gleeunit
import url_join

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn join_basic_url_test() {
  let result =
    url_join.join([
      "http://www.google.com",
      "a",
      "/b/cd",
      "?foo=123",
    ])
  assert result == "http://www.google.com/a/b/cd?foo=123"
}

pub fn join_with_trailing_slash_test() {
  let result =
    url_join.join([
      "https://example.com/",
      "/api/",
      "users",
    ])
  assert result == "https://example.com/api/users"
}

pub fn join_empty_list_test() {
  assert url_join.join([]) == ""
}

pub fn join_single_part_test() {
  assert url_join.join(["https://example.com"]) == "https://example.com"
}

pub fn join_filters_empty_parts_test() {
  let result =
    url_join.join([
      "http://a.com",
      "",
      "b",
      "",
      "c",
    ])
  assert result == "http://a.com/b/c"
}

pub fn join_plain_protocol_merged_test() {
  let result = url_join.join(["http:", "www.example.com", "path"])
  assert result == "http://www.example.com/path"
}

pub fn join_with_hash_test() {
  let result =
    url_join.join([
      "https://example.com/page",
      "#section",
    ])
  assert result == "https://example.com/page#section"
}

pub fn join_query_params_normalized_test() {
  let result =
    url_join.join([
      "https://example.com",
      "search",
      "?q=hello&page=1",
    ])
  assert result == "https://example.com/search?q=hello&page=1"
}

pub fn join_leading_slash_merged_test() {
  let result = url_join.join(["/", "api", "users"])
  assert result == "/api/users"
}

pub fn join_relative_paths_test() {
  let result = url_join.join(["a", "b", "c"])
  assert result == "a/b/c"
}
