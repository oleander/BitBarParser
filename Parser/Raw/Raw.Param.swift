extension Raw {
  public enum Param: Equatable {
    case bash(String)
    case trim(Bool)
    case dropdown(Bool)
    case href(String)
    case image(Image)
    case font(String)
    case size(Float)
    case terminal(Bool)
    case refresh(Bool)
    case length(Int)
    case alternate(Bool)
    case emojize(Bool)
    case ansi(Bool)
    case color(Color)
    case checked(Bool)
    case argument(Int, String)
    case error(String, ValueError)

    public static func == (lhs: Raw.Param, rhs: Raw.Param) -> Bool {
      switch (lhs, rhs) {
      case let (.font(f1), .font(f2)):
        return f1 == f2
      case let (.size(s1), .size(s2)):
        return s1 == s2
      case let (.length(l1), .length(l2)):
        return l1 == l2
      case let (.emojize(e1), .emojize(e2)):
        return e1 == e2
      case let (.trim(t1), .trim(t2)):
        return t1 == t2
      case let (.ansi(a1), .ansi(a2)):
        return a1 == a2
      case let (.color(c1), .color(c2)):
        return c1 == c2
      case let (.bash(b1), .bash(b2)):
        return b1 == b2
      case let (.dropdown(d1), .dropdown(d2)):
        return d1 == d2
      case let (.href(h1), .href(h2)):
        return h1 == h2
      case let (.image(i1), .image(i2)):
        return i1 == i2
      case let (.terminal(t1), .terminal(t2)):
        return t1 == t2
      case let (.refresh(r1), .refresh(r2)):
        return r1 == r2
      case let (.alternate(a1), .alternate(a2)):
        return a1 == a2
      case let (.checked(c1), .checked(c2)):
        return c1 == c2
      case let (.argument(i1, a1), .argument(i2, a2)):
        return i1 == i2 && a1 == a2
      case let (.error(e1, v1), .error(e2, v2)):
        return e1 == e2 && v1 == v2
      default:
        return false
      }
    }
  }
}
