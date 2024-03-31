import gleam/dynamic
import gleam/bytes_builder.{type BytesBuilder}
import gleam/http/response.{type Response}
import gleam/json

pub fn parse_json_string_from(error: json.DecodeError) -> String {
  "internal error json decode to string..."
}

pub fn parse_string_from(errors: List(dynamic.DecodeError)) -> String {
  case errors {
    [e, ..] -> "expected: " <> e.expected <> ", found: " <> e.found
    [] -> "internal error decode to string..."
  }
}

pub fn set_body(
  response: Response(t),
  str: String,
) -> response.Response(BytesBuilder) {
  response
  |> response.set_body(bytes_builder.from_string(str))
}
