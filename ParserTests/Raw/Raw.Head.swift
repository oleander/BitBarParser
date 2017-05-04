import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([String])
extension Raw.Head: Arbitrary, Equatable, CustomStringConvertible {
  typealias Head = Raw.Head
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  public static var arbitrary: Gen<Head> {
    let n1: Gen<Head> = Gen<(String, [Param], [Tail])>.zip(string, Param.textableish, Tail.arbitrary.proliferate).map { title, params, tails in
      return tails.enumerated().reduce(.node(title, params, [])) { head, tail in
        return head.add(node: tail.1, level: tail.0)
      }
    }

    return n1
  }

  var output: String {
    switch (params.isEmpty, menus.isEmpty) {
    case (true, true):
      return head + "\n"
    case (true, false):
       return head + "\n---\n" + tail
    case (false, true):
      return head + "| " + middle + "\n"
    case (false, false):
       return head + "| " + middle + "\n---\n" + tail
    }
  }

  private var tail: String { return menus.map { $0.output }.joined() }
  private var head: String { return title.titled() }
  private var middle: String { return params.map { $0.output }.joined(separator: " ") }

  var title: String {
    switch self {
    case let .node(title, _, _):
      return title
    case let .error(messages):
      return messages.joined(separator: " ")
    }
  }

  var menus: [Raw.Tail] {
    switch self {
    case let .node(_, _, menus):
      return menus
    case .error:
      return []
    }
  }

  var params: [Raw.Param] {
    switch self {
    case let .node(_, params, _):
      return params
    case .error:
      return []
    }
  }

  func hasImage() -> Bool {
    return params.reduce(false) { acc, param in
      switch param {
      case .image:
        return true
      default:
        return acc
      }
    }
  }

  public static func == (lhs: Raw.Head, rhs: Raw.Head) -> Bool {
    switch (lhs, rhs) {
    case let (.node(t1, p1, m1), .node(t2, p2, m2)):
      return t1 == t2 && p1 == p2 && m1 == m2
    case let (.error(m1), .error(m2)):
      return m1 == m2
    default:
      return false
    }
  }

  public static func ==== (lhs: Raw.Head, rhs: Raw.Head) -> Property {
    switch (lhs, rhs) {
    case let (.node(_, p1, m1), .node(_, p2, m2)) where lhs.hasImage() && rhs.hasImage():
      return p1.filter(filter) ==== p2.filter(filter) ^&&^ m1 ==== m2
    case let (.node(t1, p1, m1), .node(t2, p2, m2)):
      return t1 ==== t2 ^&&^ p1.filter(filter) ==== p2.filter(filter) ^&&^ m1 ==== m2

    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }

  public var description: String {
    return output.inspected()
  }
}
