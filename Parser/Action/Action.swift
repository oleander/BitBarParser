public enum Action {
  case nop
  case refresh
  case script(Script)
  case href(String, [Event])

  static func lift(_ script: Result<Script>) -> Result<Action> {
    return script.map(Action.script)
  }

  private static func reduce(_ acc: Accumulator) -> Result<Action> {
    switch acc {
    case let .bad(message):
      return .bad(message)
    case let .script(script):
      return lift(script.reduce())
    case .href(.none, _):
      return .bad(["Href not set"])
    case let .href(.some(url), events):
      return .good(.href(url, events))
    case .nop:
      return .good(.nop)
    case .refresh(true):
      return .good(.refresh)
    default:
      return .good(.nop)
    }
  }

  static func reduce(_ params: [Raw.Param]) -> Result<Action> {
    return reduce(params.reduce(.nop) { acc, param in
      switch (acc, param) {
        /* Special case */
      case (.bad, _):
        return acc
      case (.nop, _):
        return acc.select(param)

        /* Script */
      case (.script, .href):
        return .bad(["Script != href"])
      case let (.script(script), .bash(path)):
        return lift(script.set(path: path))
      case let (.script(script), .argument(index, value)):
        return lift(script.set(arg: value, at: index))
      case let (.script(script), .terminal(state)):
        return lift(script.set(foreground: state))
      case let (.script(script), .refresh(true)):
        return lift(script.add(event: .refresh))
      case (.script, .refresh(false)):
        return acc

        /* Href - failures */
      case (.href, .bash):
        return .bad(["Href and bash cannot be defined together"])
      case (.href(.some, _), .href):
        return .bad(["Href has already been defined"])
      case let (.href, .argument(index, _)):
        return .bad(["param\(index) can't be defined with href"])
      case let (.href(_, params), .refresh(true)) where params.has(.refresh):
        return .bad(["Refresh can only be defined once"])

        /* Href - ok */
      case let (.href(_, params), .href(url)):
        return .href(url, params)
      case let (.href(url, params), .refresh(true)):
        return .href(url, params + [.refresh])
      case let (.href(url, params), .refresh(false)):
        return .href(url, params)

        /* Refresh - failure */
      case (.refresh, .refresh):
        return .bad(["Refresh can only be defined once"])

        /* Refresh - ok */
      case let (.refresh(true), .argument(index, value)):
        return lift(Accumulator.Script(arg: value, at: index).add(event: .refresh))
      case let (.refresh(false), .argument(index, value)):
        return .script(Accumulator.Script(arg: value, at: index))
      case let (.refresh(true), .terminal(state)):
        return lift(Accumulator.Script(foreground: state).add(event: .refresh))
      case let (.refresh(false), .terminal(state)):
        return .script(Accumulator.Script(foreground: state))
      case let (.refresh(false), .bash(path)):
        return .script(Accumulator.Script(path: path))
      case let (.refresh(true), .bash(path)):
        return .script(Accumulator.Script(path: path, events: [.refresh]))
      case let (.refresh(true), .href(url)):
        return .href(url, [.refresh])
      case let (.refresh(false), .href(url)):
        return .href(url, [])
      default:
        return acc
      }
    })
  }

  static func lift(_ script: Result<Accumulator.Script>) -> Accumulator {
    switch script {
    case let .bad(message):
      return .bad(message)
    case let .good(script):
      return .script(script)
    }
  }
}
