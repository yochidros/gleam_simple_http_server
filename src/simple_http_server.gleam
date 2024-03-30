import gleam/http/elli
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/bytes_builder.{type BytesBuilder}
import gleam/io
import gleam/dynamic.{type Dynamic}

fn echo_(ctx: Request(Dynamic)) -> Response(BytesBuilder) {
  io.debug(ctx.body)
  case dynamic.string(ctx.body) {
    Ok(content) ->
      response.new(200)
      |> response.set_body(bytes_builder.from_string(content))
    Error([e, ..]) ->
      response.new(500)
      |> response.set_body(bytes_builder.from_string("expected: " <> e.expected <> ", found: " <> e.found))
    Error([]) ->
      response.new(500)
      |> response.set_body(bytes_builder.from_string(
        "internal error decode to string...",
      ))
  }
}

pub fn handle(req: Request(body)) -> Response(BytesBuilder) {
  let path = req.path
  case path {
    // top
    "" | "/" ->
      response.new(200)
      |> response.set_body(bytes_builder.from_string("hi!"))
    "/echo" -> echo_(request.map(req, fn(bo) { dynamic.from(bo) }))
    _ ->
      response.new(404)
      |> response.set_body(bytes_builder.from_string("not found..."))
  }
}

pub fn main() {
  io.println("Listening localhost:3000")
  elli.become(handle, on_port: 3000)
}
