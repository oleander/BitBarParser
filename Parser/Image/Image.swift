public enum Image: Equatable {
  case base64(String, Sort)
  case href(String, Sort)

  public static func == (lhs: Image, rhs: Image) -> Bool {
    switch (lhs, rhs) {
    case let (.base64(b1, s1), .base64(b2, s2)):
      return b1 == b2 && s1 == s2
    case let (.href(h1, s1), .href(h2, s2)):
      return h1 == h2 && s1 == s2
    default:
      return false
    }
  }
}
