import SwiftCheck
@testable import Parser

extension Text.Param: Parsable {
  public var description: String { return output.inspected() }
  var output: String {
    switch self {
    case .emojize:
      return "emojize=true"
    case .ansi:
      return "ansi=true"
    case .trim:
      return "trim=true"
    case let .font(name):
      return "font=\(name.quoted())"
    case let .size(value):
      return "size=\(value)"
    case let .length(value):
      return "length=\(value)"
    case let .color(color):
      return color.output
    }
  }

  static func ==== (lhs: Text.Param, rhs: Text.Param) -> Property {
    switch (lhs, rhs) {
    case let (.font(f1), .font(f2)):
      return f1 ==== f2
    case let (.length(l1), .length(l2)):
      return l1 ==== l2
    case let (.color(c1), .color(c2)):
      return c1 ==== c2
    case let (.size(s1), .size(s2)):
      return s1 ==== s2
    case (.emojize, .emojize):
      return true <?> "emojize"
    case (.ansi, ansi):
      return true <?> "ansi"
    case (.trim, .trim):
      return true <?> "trim"
    default:
      return false <?> "no match for \(lhs), \(rhs)"
    }
  }
}
