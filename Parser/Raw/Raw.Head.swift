extension Raw {
  enum Head {
    case node([(String, [Param])], [Tail])
    case error([String])
    
    internal func add(node: Raw.Tail, level: Int) -> Raw.Head {
      switch (self, level) {
      case let (.node(title, menus), 0):
        return .node(title, menus + [node])
      case let (.node(_, menus), _) where menus.isEmpty:
        return failure("No more levels to go")
      case let (.node(title, menus), _):
        return .node(
          title,
          menus.initial() + [menus.last!.add(node: node, level: level - 1)]
        )
      default:
        return failure("Not sure how to handle event \(node) on level \(level)")
      }
    }

    func reduce() -> Menu.Head {
      return Menu.Head.reduce(self)
    }

    private func failure(_ message: String) -> Raw.Head {
      switch self {
      case let .error(messages):
        return .error(messages + [message])
      default:
        return .error([message])
      }
    }

    func append(_ line: Line) -> Raw.Head {
      switch (self, line) {
      case let (.node(text, tails), (_, title, params)):
        return .node(text + [(title, params)], tails)
      default:
        return self
      }
    }
  }
}
