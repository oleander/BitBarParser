extension Raw {
  public enum Head {
    case node([(String, [Param])], [Tail])
    case error([MenuError])

    internal func add(node: Raw.Tail, level: Int) -> Raw.Head {
      switch (self, level) {
      case let (.node(title, menus), 0):
        return .node(title, menus + [node])
      case let (.node(_, menus), _) where menus.isEmpty:
        return .error([.invalidMenuDepth(self, node, level)])
      case let (.node(title, menus), _):
        return .node(
          title,
          menus.initial() + [menus.last!.add(node: node, level: level - 1)]
        )
      case (.error, _):
        return self
      }
    }

    func reduce() -> Menu.Head {
      return Menu.Head.reduce(self)
    }

    func append(_ line: Line) -> Raw.Head {
      switch (self, line) {
      case let (.node(text, tails), (_, title, params)):
        return .node(text + [(title, params)], tails)
      default:
        return self
      }
    }

    var errors: [MenuError] {
      switch self {
      case let .node(pairs, _):
        return pairs.errors.map { .param($0.0, $0.1) }
      case let .error(messages):
        return messages
      }
    }
  }
}
