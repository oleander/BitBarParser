import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([String])
extension Raw.Head: Arbitrary, Equatable, CustomStringConvertible {
  public typealias Head = Raw.Head
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  private static let tail = Tail.arbitrary.proliferate
  private static let text = Param.textableish
  private static let heads = Gen<(String, [Param])>.zip(string, text).map { ($0, $1) }.proliferateNonEmpty

  public static var arbitrary: Gen<Head> {
    return Gen<([(String, [Param])], [Tail], [Tail])>.zip(heads, tail, tail).map {
      return Array(zip($1, $2)).enumerated().reduce(.node($0, [])) { head, tail in
        return head.add(node: tail.1.0, level: tail.0).add(node: tail.1.1, level: tail.0)
      }
    }
  }

  var output: String {
    return title + render(menus)
  }

  private func render(_ menus: [Raw.Tail]) -> String {
    if menus.isEmpty { return "\n" }
    return "\n---\n" + menus.map { $0.output }.joined()
  }

  private func render(_ params: [Raw.Param]) -> String {
    if params.isEmpty { return "" }
    return "|" + params.map { $0.output }.joined(separator: " ")
  }

  private var title: String {
    switch self {
    case let .node(titles, _) where titles.isEmpty:
      return "\n"
    case let .node(titles, _):
      return titles.map { (info: (title: String, params: [Raw.Param])) in
        return info.title.titled() + "" + render(info.params)
      }.joined(separator: "\n")
    case let .error(messages):
      preconditionFailure("Error: \(messages)")
    }
  }

  private var menus: [Raw.Tail] {
    switch self {
    case let .node(_, menus):
      return menus
    case .error:
      return []
    }
  }

  public static func == (lhs: Raw.Head, rhs: Raw.Head) -> Bool {
    switch (lhs, rhs) {
    case let (.node(t1, m1), .node(t2, m2)):
      return t1 == t2 && m1 == m2
    case let (.error(m1), .error(m2)):
      return m1 == m2
    default:
      return false
    }
  }

  public var description: String {
    return output.inspected()
  }
}