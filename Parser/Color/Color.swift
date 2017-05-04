public enum Color: Equatable {
  case hex(String)
  case name(String)

  public static func == (lhs: Color, rhs: Color) -> Bool {
    switch (lhs, rhs) {
    case let (.name(s1), .name(s2)):
      return s1 == s2
    case let (.hex(c1), .hex(c2)):
      return c1 == c2
    default:
      return false
    }
  }
}
