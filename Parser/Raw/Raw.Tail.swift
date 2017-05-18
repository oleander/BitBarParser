extension Raw {
  public enum Tail {
    case node(String, [Param], [Tail])
    case error([MenuError])

    internal func add(node: Raw.Tail, level: Int) -> Raw.Tail {
      switch (self, level) {
      case let (.node(title, params, menus), 0):
        return .node(title, params, menus + [node])
      case let (.node(_, _, menus), _) where menus.isEmpty:
        return .error([.invalidSubMenuDepth(self, node, level)])
      case let (.node(title, params, menus), _):
        return .node(
          title,
          params,
          menus.initial() + [menus.last!.add(node: node, level: level - 1)]
        )
      case (.error, _):
        return self
      }
    }
  }
}
