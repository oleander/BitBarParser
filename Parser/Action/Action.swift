public enum Action: Equatable {
  case nop
  case refresh
  case script(Script)
  case href(String, [Event])

  static func reduce(_ params: [Raw.Param]) -> Result<Action> {
    return params.reduce(Accumulator()) { acc, param in acc + param }.reduce()
  }

  public static func == (lhs: Action, rhs: Action) -> Bool {
    switch (lhs, rhs) {
    case (.nop, nop):
      return true
    case (.refresh, .refresh):
      return true
    case let (.script(s1), .script(s2)):
      return s1 == s2
    case let (.href(u1, e1), .href(u2, e2)):
      return u1 == u2 && e1 == e2
    default:
      return false
    }
  }
}
