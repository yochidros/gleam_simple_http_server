import gleam/http/elli
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/http
import gleam/bytes_builder.{type BytesBuilder}
import gleam/io
import gleam/dynamic.{type Dynamic, field, string}
import gleam/json.{object}
import utils/utils
import path

type Todo {
  Todo(title: String, is_done: Bool)
}

type CreateTodoPayload {
  CreateTodoPayload(title: String)
}

fn decode_create_todo(json_string: String) -> Result(Todo, json.DecodeError) {
  let decoder = dynamic.decode1(CreateTodoPayload, field("title", of: string))
  case json.decode(from: json_string, using: decoder) {
    Ok(v) -> Ok(Todo(v.title, False))
    Error(e) -> Error(e)
  }
}

fn encode_todo(t: Todo) -> BytesBuilder {
  object([#("title", json.string(t.title)), #("is_done", json.bool(t.is_done))])
  |> json.to_string
  |> bytes_builder.from_string
}

fn todo_(ctx: Request(Dynamic)) -> Response(BytesBuilder) {
  io.debug(ctx.body)
  case ctx.method {
    http.Post ->
      case dynamic.string(ctx.body) {
        Ok(content) ->
          case decode_create_todo(content) {
            Ok(t) ->
              response.new(200)
              |> response.set_body(encode_todo(t))
            Error(e) ->
              response.new(500)
              |> utils.set_body(utils.parse_json_string_from(e))
          }
        Error(errors) ->
          response.new(500)
          |> utils.set_body(utils.parse_string_from(errors))
      }
    _ ->
      response.new(405)
      |> utils.set_body("method not permit")
  }
}

fn echo_(ctx: Request(Dynamic)) -> Response(BytesBuilder) {
  io.debug(ctx.body)
  case dynamic.string(ctx.body) {
    Ok(content) ->
      response.new(200)
      |> utils.set_body(content)
    Error(errors) ->
      response.new(500)
      |> utils.set_body(utils.parse_string_from(errors))
  }
}

pub fn handle(req: Request(body)) -> Response(BytesBuilder) {
  let path = path.parse_path(req.path)
  io.debug(req.method)
  case path {
    path.Root ->
      response.new(200)
      |> utils.set_body("hi!")
    path.Echo -> echo_(request.map(req, fn(bo) { dynamic.from(bo) }))
    path.Todo -> todo_(request.map(req, fn(bo) { dynamic.from(bo) }))
    path.NotFound ->
      response.new(404)
      |> utils.set_body("not found...")
  }
}

pub fn main() {
  io.println("Listening localhost:3000")
  elli.become(handle, on_port: 3000)
}
