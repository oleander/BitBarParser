public enum MenuError {
  case duplicate([Raw.Param])
  case duplicateActions(Action, Action)
  case invalidSubMenuDepth(Raw.Tail, Raw.Tail, Int) /* Parent, Child, Level-- */
  case invalidMenuDepth(Raw.Head, Raw.Tail, Int) /* Parent, Child, Level-- */
  case noParamsForSeparator([Raw.Param])
  case noSubMenusForSeparator([Raw.Tail])
  case param(String, ValueError)
  case parseError(Failure)
  case argumentsSetButNotBash([String])
  case eventsSetButNotBash([Event])
  case argumentsAndEventsAreSetButNotBash([String], [Event])
}

public enum ValueError: Equatable {
  case int(String)
  case float(String)
  case image(String)
  case base64OrHref(String)
  case font(String)
  case color(String)

  public static func == (lhs: ValueError, rhs: ValueError) -> Bool {
    switch (lhs, rhs) {
    case let (.int(i1), .int(i2)):
      return i1 == i2
    case let (.float(f1), .float(f2)):
      return f1 == f2
    case let (.font(f1), .font(f2)):
      return f1 == f2
    case let (.image(i1), .image(i2)):
      return i1 == i2
    default:
      return false
    }
  }
}
