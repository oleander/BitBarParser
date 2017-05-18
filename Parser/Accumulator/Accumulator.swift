struct Accumulator {
  var script: Accumulator.Script = Accumulator.Script()
  var refresh: Bool? = nil
  var href: String? = nil
  var events = [Event]()
  var errors = [String]()

  func reduce() -> Result<Action> {
    switch (script.reduce(), href, refresh) {
    case let (.good(script), .some(href), .some(true)):
      return .bad([.duplicateActions(.script(script), .href(href, [.refresh]))])
    case let (.good(script), .some(href), _):
      return .bad([.duplicateActions(.script(script), .href(href, []))])
    case let (.bad(messages), .some, _) where !messages.isEmpty:
      return .bad(messages)
    case let (.good(script), _, _):
      return .good(.script(script))
    case let (_, .some(url), .some(true)):
      return .good(.href(url, [.refresh]))
    case let (_, .some(url), .some(false)):
      return .good(.href(url, []))
    case let (_, .some(url), .none):
      return .good(.href(url, []))
    case (_, _, .some(true)):
      return .good(.refresh)
    case (_, _, _):
      return .good(.nop)
    }
  }

  mutating func set(refresh: Bool) {
    if refresh {
      script.add(event: .refresh)
    }

    self.refresh = refresh
  }

  static func + (accu: Accumulator, param: Raw.Param) -> Accumulator {
    var acc = accu
    switch param {
    case let .bash(path):
      acc.script.set(path: path)
    case let .href(href):
      acc.href = href
    case .terminal(true):
      acc.script.add(event: .terminal)
    case let .refresh(state):
      acc.set(refresh: state)
    case let .argument(index, arg):
      acc.script.set(arg: arg, at: index)
    default:
      break
    }

    return acc
  }
}
