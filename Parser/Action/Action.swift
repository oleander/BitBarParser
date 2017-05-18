public enum Action {
  case nop
  case refresh
  case script(Script)
  case href(String, [Event])

  static func reduce(_ params: [Raw.Param]) -> Result<Action> {
    return params.reduce(Accumulator()) { acc, param in acc + param }.reduce()
  }
}
