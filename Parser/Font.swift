public enum Font: Equatable {
  case name(String)
  case size(Float)
  case font(String, Float)

  public static func == (lhs: Font, rhs: Font) -> Bool {
    switch (lhs, rhs) {
    case let (.name(n1), .name(n2)):
      return n1 == n2
    case let (.size(s1), .size(s2)):
      return s1 == s2
    case let (.font(f1), .font(f2)):
      return f1 == f2
    default:
      return false
    }
  }
}
