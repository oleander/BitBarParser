import SwiftCheck
@testable import Parser

// case text([Text], [Tail])
// case error([MenuError])

extension Menu.Head: Parsable, Equatable {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .text(text, tails):
      return render(text) + render(tails) + "\n"
    case let .error(messages):
      preconditionFailure("[Error]: \(messages)")
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

  static func ==== (head: Menu.Head, raw: Raw.Head) -> Property {
    switch (head, raw) {
    case let (.text(texts, tails1), .node(titles, tails2)):
      return texts ==== titles ^&&^ tails1 ==== tails2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "\(head) != \(raw)"
    }
  }

  static func ==== (lhs: Menu.Head, rhs: Menu.Head) -> Property {
    switch (lhs, rhs) {
    case let (.text(t1, m1), .text(t2, m2)):
      return t1 ==== t2 ^&&^ m1 ==== m2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }

  private func render(_ text: [Text]) -> String {
    if text.isEmpty { return "" }
    return text.map { $0.toString([], .nop) }.joined(separator: "\n")
  }

  private func render(_ tails: [Menu.Tail]) -> String {
    if tails.isEmpty { return "" }
    return "\n---\n" + tails.map { $0.output }.joined()
  }
}
