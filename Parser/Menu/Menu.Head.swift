extension Menu {
  public enum Head {
    case text([Text], [Tail])
    case error([MenuError])

    static func reduce(_ menu: Raw.Head) -> Menu.Head {
      switch (menu, menu.errors) {
      case let (.node(pairs, tails), errors) where errors.isEmpty:
        return reduce(pairs, tails)
      case let (_, errors):
        return .error(errors)
      }
    }

    static func reduce(_ pairs: [(String, [Raw.Param])], _ tails: [Raw.Tail]) -> Menu.Head {
      switch (Text.reduce(pairs), Menu.Tail.reduce(tails)) {
      case let (.good(text), .good(tails)):
        return .text(text, tails)
      case let (text, tails):
        return .error(text +! tails)
      }
    }
  }
}
