extension Menu {
  public enum Tail {
    case text(Text, [Param], [Tail], Action)
    case image(Image, [Param], [Tail], Action)
    case error([String])
    case separator

    static func reduce(_ menus: [Raw.Tail]) -> Result<[Menu.Tail]> {
      return menus.reduce(.output([])) { acc, menu in
        switch (acc, reduce(menu)) {
        case (.error, _):
          return acc
        case let (_, .error(message)):
          return .error(message)
        case let (.output(tails), .output(tail)):
          return .output(tails + [tail])
        default:
          return acc
        }
      }
    }

    static func reduce(_ menu: Raw.Tail) -> Result<Menu.Tail> {
      switch menu {
        /* Invalid states */
      case let .node("-", params, _) where !params.isEmpty:
        return .error(["Separator cannot have any params"])
      case let .node("-", _, tails) where !tails.isEmpty:
        return .error(["Separator cannot have any sub menus"])

        /* Valid states */
      case .node("-", _, _):
        return .output(.separator)
      case let .node(_, params, tails) where has(image: params):
        switch (
          Image.reduce(params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.output(image), .output(params), .output(tails), .output(action)):
          return .output(.image(image, params, tails, action))
        case let (image, params, tails, action):
          return .error(image.errors + params.errors + tails.errors + action.errors)
        }
      case let .node(title, params, tails) where params.has(.dropdown(false)) && !tails.isEmpty:
        return reduce(.node(title, params, [])) /* Remove all sub menus, if dropdown=false */
      case let .node(title, params, tails):
        switch (
          Text.reduce(title, params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.output(text), .output(params), .output(tails), .output(action)):
          return .output(.text(text, params, tails, action))
        case let (text, params, tails, action):
          return .error(text.errors + params.errors + tails.errors + action.errors)
        }
      case let .error(messages):
        return .error(messages)
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
