import gleeunit
import gleeunit/should
import simple_http_server
import gleam/http/request
import gleam/http/response
import gleam/bytes_builder

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`

pub fn handle_root_test() {
  let test_case =
    request.new()
    |> request.set_path("")
  let expect =
    response.new(200)
    |> response.set_body(bytes_builder.from_string("hi!"))
  simple_http_server.handle(test_case)
  |> should.equal(expect)
}

pub fn handle_top_test() {
  let test_case =
    request.new()
    |> request.set_path("/")
  let expect =
    response.new(200)
    |> response.set_body(bytes_builder.from_string("hi!"))
  simple_http_server.handle(test_case)
  |> should.equal(expect)
}

pub fn handle_echo_test() {
  let test_case =
    request.new()
    |> request.set_path("/echo")
    |> request.set_body("hello world")
  let expect =
    response.new(200)
    |> response.set_body(bytes_builder.from_string("hello world"))
  simple_http_server.handle(test_case)
  |> should.equal(expect)
}

pub fn handle_echo_error_test() {
  let test_case =
    request.new()
    |> request.set_path("/echo")
    |> request.set_body(1)
  let expect =
    response.new(500)
    |> response.set_body(bytes_builder.from_string(
      "expected: String, found: Int",
    ))
  simple_http_server.handle(test_case)
  |> should.equal(expect)
}
