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
          return .error(["bash='...', href='...' and other params are not allowed in menu bar"])
        case (.output, .output, .output, .output):
          return .error(["Menu bar cannot have params, i.e 'Title|bash='...'"])
        case let (text, params, tails, action):
          return .error(text.errors + params.errors + tails.errors + action.errors)
        }
      case let .error(messages):
        return .error(messages)
      }
    }
  }
}
