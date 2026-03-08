import gleam/list
import url_join/protocol

pub fn merge_leading_parts(first: String, rest: List(String)) -> List(String) {
  case rest {
    [] -> [protocol.normalize(first)]
    [next, ..tail] -> {
      case protocol.is_plain_protocol(first), first == "/" {
        True, _ -> merge_leading_parts(first <> next, tail)
        _, True -> merge_leading_parts("/" <> next, tail)
        _, _ -> [protocol.normalize(first), ..list.map(rest, fn(p) { p })]
      }
    }
  }
}
