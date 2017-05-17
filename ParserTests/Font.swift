@testable import Parser

extension Font {
  var output: String {
    switch self {
    case let .name(name):
      return "font=\(name.quoted())"
    case let .size(size):
      return "size=\(size)"
    case let .font(name, size):
      return "font=\(name.quoted()) size=\(size)"
    }
  }

  static func == (rhs: Font, lhs: String) -> Bool {
    switch rhs {
    case let .name(name):
      return lhs == name
    case let .font(name, _):
      return name == lhs
    default:
      return false
    }
  }

  static func == (rhs: Font, lhs: Float) -> Bool {
    switch rhs {
    case let .font(_, size):
      return size == lhs
    case let .size(size):
      return size == lhs
    default:
      return false
    }
  }

  static func == (rhs: Font, lhs: [Raw.Param]) -> Bool {
    switch rhs {
    case let .name(name):
      return lhs.has(.font(name))
    case let .font(name, size):
      return lhs.has(.font(name)) && lhs.has(.size(size))
    case let .size(size):
      return lhs.has(.size(size))
    }
  }
}
