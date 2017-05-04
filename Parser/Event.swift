public enum Event: Equatable {
  case refresh

  public static func == (lhs: Event, rhs: Event) -> Bool {
    switch (lhs, rhs) {
    case (.refresh, .refresh):
      return true
    }
  }
}
