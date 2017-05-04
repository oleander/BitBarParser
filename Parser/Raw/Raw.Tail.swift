extension Raw {
  enum Tail {
    case node(String, [Param], [Tail])
    case error([String])

    internal func add(node: Raw.Tail, level: Int) -> Raw.Tail {
      switch (self, level) {
      case let (.node(title, params, menus), 0):
        return .node(title, params, menus + [node])
      case let (.node(_, _, menus), _) where menus.isEmpty:
        return failure("No more levels to go \(node), \(self)")
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

    private func failure(_ message: String) -> Raw.Tail {
      switch self {
      case let .error(messages):
        return .error(messages + [message])
      default:
        return .error([message])
      }
    }
  }
}
