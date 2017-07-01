extension Menu {
  public enum Tail: Equatable {
    case text(Text, [Param], [Tail], Action)
    case image(Image, [Param], [Tail], Action)
    case error([MenuError])
    case separator

    static func reduce(_ menus: [Raw.Tail]) -> Result<[Menu.Tail]> {
      return .good(menus.map(reduce))
    }

    static func reduce(_ menu: Raw.Tail) -> Menu.Tail {
      switch menu {
        /* Invalid states */
      case let .node("-", params, _) where params.count != 0:
        return .error([.noParamsForSeparator(params)])
      case let .node("-", _, tails) where !tails.isEmpty:
        return .error([.noSubMenusForSeparator(tails)])
        /* Valid states */
      case .node("-", _, _):
        return .separator
      case let .node(_, params, tails) where has(image: params):
        switch (
          params.image,
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.some(image), .good(params), .good(tails), .good(action)):
          return .image(image, params, tails, action)
        case let (_, params, tails, action):
          return .error(params +! tails +! action)
        }
      case let .node(title, params, tails) where params.has(.dropdown(false)) && !tails.isEmpty:
        return reduce(.node(title, params, []))
      case let .node(title, params, tails):
        switch (
          Text.reduce(title, params),
          Menu.Param.reduce(params),
          Menu.Tail.reduce(tails),
          Action.reduce(params)
        ) {
        case let (.good(text), .good(params), .good(tails), .good(action)):
          return .text(text, params, tails, action)
        case let (text, params, tails, action):
          return .error(text +! params +! tails +! action)
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

    public static func == (lhs: Menu.Tail, rhs: Menu.Tail) -> Bool {
      switch (lhs, rhs) {
      case let (.text(t1, p1, m1, x1), .text(t2, p2, m2, x2)):
        return t1 == t2 && p1 == p2 && m1 == m2 && x1 == x2
      case let (.error(m1), .error(m2)):
        return m1 == m2
      case let (.image(t1, p1, m1, x1), .image(t2, p2, m2, x2)):
        return t1 == t2 && p1 == p2 && m1 == m2 && x1 == x2
      case (.separator, .separator):
        return true
      default:
        return false
      }
    }
  }
}
