import gleam/string
import url_join/slashes

pub fn normalize(s: String) -> String {
  case string.starts_with(s, "file:///") {
    True -> s
    False -> case string.starts_with(s, "file:") {
      True ->
        "file:///" <> slashes.trim_leading(string.drop_start(s, up_to: 5))
      False -> case is_ipv6_host(s) {
        True -> s
        False -> {
          case string.split_once(s, on: "://") {
            Ok(_) -> s
            Error(_) -> {
              case string.split_once(s, on: ":") {
                Ok(#(protocol, rest)) -> {
                  let rest_trimmed = slashes.trim_leading(rest)
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

pub fn is_plain_protocol(s: String) -> Bool {
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

fn is_ipv6_host(s: String) -> Bool {
  string.starts_with(s, "[") && string.contains(does: s, contain: "]")
}
