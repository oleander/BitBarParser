extension Text {
  public enum Param: Equatable {
    case font(String)
    case length(Int)
    case color(Color)
    case size(Float)
    case emojize
    case ansi
    case trim

    static func reduce(_ params: [Raw.Param]) -> Result<[Text.Param]> {
      return .output(params.reduce([]) { acc, param in
        switch param {
        case let .font(name):
          return acc + [.font(name)]
        case let .length(value):
          return acc + [.length(value)]
        case let .color(color):
          return acc + [.color(color)]
        case let .size(value):
          return acc + [.size(value)]
        case .emojize(true):
          return acc + [.emojize]
        case .ansi(true):
          return acc + [.ansi]
        case .trim(true):
          return acc + [.trim]
        default:
          return acc
        }
      })
    }

    public static func == (lhs: Text.Param, rhs: Text.Param) -> Bool {
      switch (lhs, rhs) {
      case let (.font(f1), .font(f2)):
        return f1 == f2
      case let (.length(l1), .length(l2)):
        return l1 == l2
      case let (.color(c1), .color(c2)):
        return c1 == c2
      case let (.size(s1), .size(s2)):
        return s1 == s2
      case (.emojize, .emojize):
        return true
      case (.ansi, ansi):
        return true
      case (.trim, .trim):
        return true
      default:
        return false
      }
    }
  }
}
