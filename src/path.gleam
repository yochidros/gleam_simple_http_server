pub type Path {
  Root
  Echo
  Todo
  NotFound
}

pub fn parse_path(path: String) -> Path {
  case path {
    "" | "/" -> Root
    "/echo" -> Echo
    "/todo" -> Todo
    _ -> NotFound
  }
}
