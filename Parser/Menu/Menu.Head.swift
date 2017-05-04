extension Menu {
  public enum Head {
    case text(Text, [Tail])
    case error([String])

    static func reduce(_ menu: Raw.Head) -> Menu.Head {
      switch menu {
      case let .node(title, params, tails):
        switch (
          Text.reduce(title, params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.output(text), .output(ps), .output(tails), .output(.nop)) where ps.isEmpty:
          return .text(text, tails)
        case let (.output, .output(params), .output, .output) where params.isEmpty:
          return .error(["No action allowed for menu bar"])
        case (.output, .output, .output, .output):
          return .error(["Params not allowed for menu bar"])
        case let (text, params, tails, action):
          return .error(text.errors + params.errors + tails.errors + action.errors)
        }
      case let .error(messages):
        return .error(messages)
      }
    }

    private static func failure<T>(from outputs: [Result<T>]) -> Menu.Head {
      let errors = outputs.reduce([String]()) { acc, output in
        switch output {
        case let .error(messages):
          return acc + messages
        default:
          return acc
        }
      }

      if errors.isEmpty {
        preconditionFailure("no errors")
      }

      return .error(errors)
    }
  }
}
