import gleam/http/elli
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/bytes_builder.{type BytesBuilder}
import gleam/io
import gleam/dynamic.{type Dynamic}
import utils/utils
import path.{type Path}

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
  case path {
    path.Root ->
      response.new(200)
      |> utils.set_body("hi!")
    path.Echo -> echo_(request.map(req, fn(bo) { dynamic.from(bo) }))
    path.NotFound ->
      response.new(404)
      |> utils.set_body("not found...")
  }
}

pub fn main() {
  io.println("Listening localhost:3000")
  elli.become(handle, on_port: 3000)
}
