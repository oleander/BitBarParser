extension Menu {
  public enum Tail {
    case text(Text, [Param], [Tail], Action)
    case image(Image, [Param], [Tail], Action)
    case error([String], Int)
    case separator

    static func reduce(_ menus: [Raw.Tail]) -> Result<[Menu.Tail]> {
      return .output(menus.enumerated().map { reduce($0.1, at: $0.0) })
    }

    static func reduce(_ menu: Raw.Tail, at row: Int) -> Menu.Tail {
      switch menu {
        /* Invalid states */
      case let .node("-", params, _) where !params.isEmpty:
        return .error(["Separators cannot have params, i.e ---|bash='...'"], row)
      case let .node("-", _, tails) where !tails.isEmpty:
        return .error(["Separators cannot have sub menus"], row)
      case let .node("", params, tails):
        return reduce(.node("[Empty]", params, tails), at: row)
        /* Valid states */
      case .node("-", _, _):
        return .separator
      case let .node(_, params, tails) where has(image: params):
        switch (
          Image.reduce(params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.output(image), .output(params), .output(tails), .output(action)):
          return .image(image, params, tails, action)
        case let (image, params, tails, action):
          return .error(image.errors + params.errors + tails.errors + action.errors, row)
        }
      case let .node(title, params, tails) where params.has(.dropdown(false)) && !tails.isEmpty:
        return reduce(.node(title, params, []), at: row) /* Remove all sub menus, if dropdown=false */
      case let .node(title, params, tails):
        switch (
          Text.reduce(title, params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.output(text), .output(params), .output(tails), .output(action)):
          return .text(text, params, tails, action)
        case let (text, params, tails, action):
          return .error(text.errors + params.errors + tails.errors + action.errors, row)
        }
      case let .error(messages):
        return .error(messages, row)
      }
    }

    private static func has(image params: [Raw.Param]) -> Bool {
      return params.reduce(false) { acc, param in
        switch param {
        case .image:
          return true
        default:
          return acc
        }
      }
    }
  }
}
