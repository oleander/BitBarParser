extension Menu {
  public enum Head {
    case text([Text], [Tail])
    case error([String])

    static func reduce(_ menu: Raw.Head) -> Menu.Head {
      switch menu {
      case let .node(pairs, tails):
        switch (Text.reduce(pairs), Menu.Tail.reduce(tails)) {
        case let (.good(text), .good(tails)):
          return .text(text, tails)
        case let (text, tails):
          return .error(text +! tails)
        }
      case let .error(messages):
        return .error(messages)
      }
    }
  }
}
