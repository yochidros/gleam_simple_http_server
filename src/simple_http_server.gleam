import gleam/http/elli
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/bytes_builder.{type BytesBuilder}
import gleam/io
import gleam/dynamic.{type Dynamic}

fn parse_string_from(errors: List(dynamic.DecodeError)) -> String {
	case errors {
    [e, ..] -> "expected: " <> e.expected <> ", found: " <> e.found
		[] -> "internal error decode to string..."
	}
}
fn set_body(response: Response(t), str: String) -> response.Response(BytesBuilder) {
	response
      |> response.set_body(bytes_builder.from_string(str))
}

fn echo_(ctx: Request(Dynamic)) -> Response(BytesBuilder) {
  io.debug(ctx.body)
  case dynamic.string(ctx.body) {
    Ok(content) ->
      response.new(200)
			|> set_body(content)
    Error(errors) ->
      response.new(500)
			|> set_body(parse_string_from(errors))
  }
}

pub type Path {
  Root
  Echo
  NotFound
}

pub fn parse_path(path: String) -> Path {
  case path {
    "" | "/" -> Root
    "/echo" -> Echo
    _ -> NotFound
  }
}

pub fn handle(req: Request(body)) -> Response(BytesBuilder) {
  let path = parse_path(req.path)
  case path {
    Root ->
      response.new(200)
			|> set_body("hi!")
    Echo -> echo_(request.map(req, fn(bo) { dynamic.from(bo) }))
    NotFound ->
      response.new(404)
      |> set_body("not found...")
  }
}

pub fn main() {
  io.println("Listening localhost:3000")
  elli.become(handle, on_port: 3000)
}
