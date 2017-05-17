enum Accumulator {
  case script(Script)
  case refresh(Bool)
  case href(String?, [Event])
  case bad([String])
  case nop

  func select(_ param: Raw.Param) -> Accumulator {
    switch param {
    case let .refresh(state):
      return .refresh(state)
    case let .bash(path):
      return .script(Script(path: path))
    case let .argument(index, value):
      return .script(Script(arg: value, at: index))
    case let .terminal(state):
      return .script(Script(foreground: state))
    case let .href(url):
      return .href(url, [])
    default:
      return self
    }
  }
}
