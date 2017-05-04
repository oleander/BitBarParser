extension Raw {
  enum Head {
    case node(String, [Param], [Tail])
    case error([String])
    internal func add(node: Raw.Tail, level: Int) -> Raw.Head {
      switch (self, level) {
      case let (.node(title, params, menus), 0):
        return .node(title, params, menus + [node])
      case let (.node(_, _, menus), _) where menus.isEmpty:
        return failure("No more levels to go")
      case let (.node(title, params, menus), _):
        return .node(
          title,
          params,
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
  }
}
