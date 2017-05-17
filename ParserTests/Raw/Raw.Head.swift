import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([String])
extension Raw.Head: Arbitrary, Equatable, CustomStringConvertible {
  typealias Head = Raw.Head
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  private static let tail = Tail.arbitrary.proliferate
  private static let text = Param.textableish

  public static var arbitrary: Gen<Head> {
    return Gen<(String, [Param], [Tail], [Tail])>.zip(string, text, tail, tail).map { title, params, t1, t2 in
      return Array(zip(t1, t2)).enumerated().reduce(.node([(title, params)], [])) { head, tail in
        return head.add(node: tail.1.0, level: tail.0).add(node: tail.1.1, level: tail.0)
      }
    }
  }

  var output: String {
    return title + render(menus)
  }

  private func render(_ menus: [Raw.Tail]) -> String {
    if menus.isEmpty { return "\n" }
    return "\n---\n" + menus.map { $0.output }.joined() + "\n"
  }

  private func render(_ params: [Raw.Param]) -> String {
    if params.isEmpty { return "" }
    return "|" + params.map { $0.output }.joined(separator: " ")
  }

  private var title: String {
    switch self {
    case let .node(titles, _):
      return titles.map { (info: (title: String, params: [Raw.Param])) in
        return info.title.titled() + "" + render(info.params)
      }.joined(separator: "\n")
    case let .error(messages):
      return messages.joined(separator: " ")
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


func == (lhs: [(String, [Raw.Param])], rhs: [(String, [Raw.Param])]) -> Bool {
  for (index, item1) in lhs.enumerated() {
    let item2 = rhs[index]
    if item1.0 != item2.0 {
      return false
    }

    if item1.1 != item2.1 {
      return false
    }
  }
  return lhs.count == rhs.count
}
