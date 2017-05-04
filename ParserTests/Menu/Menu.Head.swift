import SwiftCheck
@testable import Parser

// case text(Text, [Param], [Tail], Action)
// case error([String])
extension Menu.Head: Parsable, Equatable {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .text(text, tails) where tails.isEmpty:
      return text.toString([], .nop) + "\n"
    case let .text(text, tails):
      return text.toString([], .nop) + "\n---\n" + tails.map { $0.output }.joined()
    case let .error(messages):
      return "[Error] Found \(messages.count) errors\n---\n"
        + messages.joined(separator: "\n")
        + "\n"
    }
  }

  public static func ==== (lhs: Menu.Head, rhs: Menu.Head) -> Property {
    switch (lhs, rhs) {
    case let (.text(t1, m1), .text(t2, m2)):
      return t1 ==== t2 ^&&^ m1 ==== m2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }

  public static func == (lhs: Menu.Head, rhs: Menu.Head) -> Bool {
    switch (lhs, rhs) {
    case let (.text(t1, p1), .text(t2, p2)):
      return t1 == t2 && p1 == p2
    case let (.error(m1), .error(m2)):
      return m1 == m2
    default:
      return false
    }
  }

  func has(_ param: Raw.Param) -> Bool {
    switch param {
    case .length: fallthrough
    case .size: fallthrough
    case .color: fallthrough
    case .font: fallthrough
    case .size: fallthrough
    case .trim: fallthrough
    case .ansi: fallthrough
    case .emojize:
      switch self {
      case let .text(text, _):
        return text.has(param)
      default:
        return true
      }
    default:
      return true
    }
  }
}

func ==== (lhs: [Menu.Head], rhs: [Menu.Head]) -> Property {
  return (lhs == rhs) <?> "ok"
}

