import SwiftCheck
@testable import Parser
// case text(Text, [Param], [Tail], Action)
// case image(Image, [Param], [Tail], Action)
// case error([String])
// case separator
extension Menu.Tail: Parsable, Equatable {
  public var description: String { return output.inspected() }
  var output: String { return toString(0) }

  public static func == (lhs: Menu.Tail, rhs: Menu.Tail) -> Bool {
    switch (lhs, rhs) {
    case let (.text(t1, p1, m1, x1), .text(t2, p2, m2, x2)):
      return t1 == t2 && p1 == p2 && m1 == m2 && x1 == x2
    case let (.error(m1), .error(m2)):
      return m1 == m2
    case let (.image(t1, p1, m1, x1), .image(t2, p2, m2, x2)):
      return t1 == t2 && p1 == p2 && m1 == m2 && x1 == x2
    case (.separator, .separator):
      return true
    default:
      return false
    }
  }

  func toString(_ level: Int) -> String {
    switch self {
    case let .text(text, params, tails, action) where tails.isEmpty:
      return indent(level)
        + text.toString(params, action)
        + "\n"
    case let .text(text, params, tails, action):
      return indent(level)
        + text.toString(params, action)
        + "\n"
        + tail(for: tails, at: level)
    case let .image(image, params, tails, .nop) where tails.isEmpty:
      return [
        indent(level),
        "[Image]",
        "| ",
        params.map { $0.output }.joined(separator: " "),
        " ",
        image.output,
        "\n"
      ].joined()
    case let .image(image, params, tails, .nop):
      return [
        indent(level),
        "[Image]",
        "| ",
        params.map { $0.output }.joined(separator: " "),
        " ",
        image.output,
        "\n",
        tail(for: tails, at: level)
      ].joined()
    case let .image(image, params, tails, action):
      return [
        indent(level),
        "[Image]",
        "| ",
        params.map { $0.output }.joined(separator: " "),
        " ",
        image.output,
        " ",
        action.output,
        "\n",
        tail(for: tails, at: level)
      ].joined()
    case .separator:
      return "-" + "\n"
    case let .error(messages):
      preconditionFailure("[Error] \(messages)")
    }
  }

  static func ==== (lhs: Menu.Tail, rhs: Menu.Tail) -> Property {
    switch (lhs, rhs) {
    case let (.text(t1, p1, m1, x1), .text(t2, p2, m2, x2)):
      return t1 ==== t2 ^&&^ p1 ==== p2 ^&&^ m1 ==== m2 ^&&^ x1 ==== x2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    case let (.image(t1, p1, m1, x1), .image(t2, p2, m2, x2)):
      return t1 ==== t2 ^&&^ p1 ==== p2 ^&&^ m1 ==== m2 ^&&^ x1 ==== x2
    case (.separator, .separator):
      return true <?> "separator"
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }

  private func tail(for tails: [Menu.Tail], at level: Int) -> String {
    return tails.map { $0.toString(level + 1) }.joined()
  }

  private func indent(_ level: Int) -> String {
    return (0..<level).map { _ in "--" }.joined()
  }
}
