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
