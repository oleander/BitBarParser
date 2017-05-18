public enum Event: Equatable {
  case refresh
  case terminal

  public static func == (lhs: Event, rhs: Event) -> Bool {
    switch (lhs, rhs) {
    case (.refresh, .refresh):
      return true
    case (.terminal, .terminal):
      return true
    default:
      return false
    }
  }
}
