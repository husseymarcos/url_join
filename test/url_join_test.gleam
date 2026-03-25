import gleeunit
import gleeunit/should
import url_join

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn join_basic_url_test() {
  url_join.join([
    "http://www.google.com",
    "a",
    "/b/cd",
    "?foo=123",
  ])
  |> should.equal("http://www.google.com/a/b/cd?foo=123")
}

pub fn join_with_trailing_slash_test() {
  url_join.join([
    "https://example.com/",
    "/api/",
    "users",
  ])
  |> should.equal("https://example.com/api/users")
}

pub fn join_empty_list_test() {
  url_join.join([])
  |> should.equal("")
}

pub fn join_single_part_test() {
  url_join.join(["https://example.com"])
  |> should.equal("https://example.com")
}

pub fn join_filters_empty_parts_test() {
  url_join.join([
    "http://a.com",
    "",
    "b",
    "",
    "c",
  ])
  |> should.equal("http://a.com/b/c")
}

pub fn join_plain_protocol_merged_test() {
  url_join.join(["http:", "www.example.com", "path"])
  |> should.equal("http://www.example.com/path")
}

pub fn join_with_hash_test() {
  url_join.join([
    "https://example.com/page",
    "#section",
  ])
  |> should.equal("https://example.com/page#section")
}

pub fn join_query_params_normalized_test() {
  url_join.join([
    "https://example.com",
    "search",
    "?q=hello&page=1",
  ])
  |> should.equal("https://example.com/search?q=hello&page=1")
}

pub fn join_leading_slash_merged_test() {
  url_join.join(["/", "api", "users"])
  |> should.equal("/api/users")
}

pub fn join_relative_paths_test() {
  url_join.join(["a", "b", "c"])
  |> should.equal("a/b/c")
}

// ============================================================================
// Protocol Tests
// ============================================================================

pub fn join_https_protocol_test() {
  url_join.join(["https:", "example.com", "path"])
  |> should.equal("https://example.com/path")
}

pub fn join_ftp_protocol_test() {
  url_join.join(["ftp:", "files.example.com", "downloads"])
  |> should.equal("ftp://files.example.com/downloads")
}

pub fn join_file_protocol_triple_slash_test() {
  url_join.join(["file:///", "path", "to", "file.txt"])
  |> should.equal("file:///path/to/file.txt")
}

pub fn join_file_protocol_single_slash_test() {
  url_join.join(["file:/", "path", "to", "file.txt"])
  |> should.equal("file:///path/to/file.txt")
}

pub fn join_file_protocol_no_slashes_test() {
  url_join.join(["file:", "path", "to", "file.txt"])
  |> should.equal("file:///path/to/file.txt")
}

pub fn join_already_normalized_protocol_test() {
  url_join.join(["http://example.com", "path"])
  |> should.equal("http://example.com/path")
}

// ============================================================================
// IPv6 Tests
// ============================================================================

pub fn join_ipv6_host_test() {
  url_join.join(["http://[::1]", "api", "v1"])
  |> should.equal("http://[::1]/api/v1")
}

pub fn join_ipv6_with_port_test() {
  url_join.join(["http://[::1]:8080", "path"])
  |> should.equal("http://[::1]:8080/path")
}

// ============================================================================
// Slash Handling Tests
// ============================================================================

pub fn join_multiple_consecutive_slashes_test() {
  url_join.join(["http://example.com///", "///path///", "///"])
  |> should.equal("http://example.com/path")
}

pub fn join_only_slashes_test() {
  url_join.join(["/", "/", "/"])
  |> should.equal("")
}

pub fn join_trailing_slash_preserved_test() {
  url_join.join(["http://example.com", "path/"])
  |> should.equal("http://example.com/path/")
}

pub fn join_leading_slash_in_middle_test() {
  url_join.join(["http://example.com", "/api", "users"])
  |> should.equal("http://example.com/api/users")
}

pub fn join_absolute_path_with_leading_slash_test() {
  url_join.join(["/api/v1", "users"])
  |> should.equal("/api/v1/users")
}

// ============================================================================
// Query String Tests
// ============================================================================

pub fn join_multiple_question_marks_test() {
  url_join.join(["http://example.com", "?a=1", "?b=2"])
  |> should.equal("http://example.com?a=1&b=2")
}

pub fn join_multiple_ampersands_test() {
  url_join.join(["http://example.com", "?a=1&", "&b=2"])
  |> should.equal("http://example.com?a=1&b=2")
}

pub fn join_empty_query_param_test() {
  url_join.join(["http://example.com", "?"])
  |> should.equal("http://example.com")
}

pub fn join_query_with_special_chars_test() {
  url_join.join(["http://example.com", "?q=hello+world&foo=bar"])
  |> should.equal("http://example.com?q=hello+world&foo=bar")
}

pub fn join_only_query_string_test() {
  url_join.join(["?foo=bar", "&baz=qux"])
  |> should.equal("foo=bar?baz=qux")
}

pub fn join_query_param_in_middle_test() {
  url_join.join(["http://example.com", "?foo=1", "path"])
  |> should.equal("http://example.com?foo=1/path")
}

// ============================================================================
// Hash Fragment Tests
// ============================================================================

pub fn join_hash_only_test() {
  url_join.join(["#section"])
  |> should.equal("#section")
}

pub fn join_hash_with_query_test() {
  url_join.join(["http://example.com", "?foo=1", "#section"])
  |> should.equal("http://example.com?foo=1#section")
}

pub fn join_multiple_hashes_test() {
  url_join.join(["http://example.com", "#section1", "#section2"])
  |> should.equal("http://example.com#section1#section2")
}

pub fn join_hash_in_middle_test() {
  url_join.join(["http://example.com", "#hash", "path"])
  |> should.equal("http://example.com#hash/path")
}

pub fn join_empty_hash_test() {
  url_join.join(["http://example.com", "#"])
  |> should.equal("http://example.com")
}

// ============================================================================
// Complex URL Tests
// ============================================================================

pub fn join_complex_url_test() {
  url_join.join([
    "https:",
    "user:pass@example.com:8080",
    "/api/v1/",
    "/users/",
    "?page=1",
    "&limit=10",
    "#results",
  ])
  |> should.equal(
    "https://user:pass@example.com:8080/api/v1/users?page=1&limit=10#results",
  )
}

pub fn join_url_with_auth_info_test() {
  url_join.join(["http://user:pass@example.com", "api"])
  |> should.equal("http://user:pass@example.com/api")
}

pub fn join_url_with_port_test() {
  url_join.join(["http://example.com:8080", "api"])
  |> should.equal("http://example.com:8080/api")
}

// ============================================================================
// Edge Case Tests
// ============================================================================

pub fn join_single_slash_test() {
  url_join.join(["/"])
  |> should.equal("")
}

pub fn join_single_dot_test() {
  url_join.join(["."])
  |> should.equal(".")
}

pub fn join_dots_in_path_test() {
  url_join.join(["http://example.com", "./path", "../other"])
  |> should.equal("http://example.com/./path/../other")
}

pub fn join_spaces_in_path_test() {
  url_join.join(["http://example.com", "path with spaces"])
  |> should.equal("http://example.com/path with spaces")
}

pub fn join_unicode_in_path_test() {
  url_join.join(["http://example.com", "café", "résumé"])
  |> should.equal("http://example.com/café/résumé")
}

pub fn join_url_encoded_chars_test() {
  url_join.join(["http://example.com", "path%20encoded"])
  |> should.equal("http://example.com/path%20encoded")
}

pub fn join_single_segment_test() {
  url_join.join(["path"])
  |> should.equal("path")
}

pub fn join_two_segments_test() {
  url_join.join(["path", "to"])
  |> should.equal("path/to")
}

pub fn join_many_empty_strings_test() {
  url_join.join(["", "", "", "path", "", "", ""])
  |> should.equal("path")
}

pub fn join_whitespace_only_parts_test() {
  url_join.join(["  ", "path", "   "])
  |> should.equal("  /path/   ")
}

pub fn join_protocol_with_extra_slashes_test() {
  url_join.join(["http://", "example.com", "path"])
  |> should.equal("http://example.com/path")
}

pub fn join_protocol_with_double_colon_test() {
  url_join.join(["http::", "example.com"])
  |> should.equal("http://:/example.com")
}
