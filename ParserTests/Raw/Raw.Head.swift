import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([String])
extension Raw.Head: Arbitrary, Equatable {
  public typealias Head = Raw.Head
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  private static let tail = Tail.arbitrary.proliferate
  private static let text = Param.textableish
  private static let heads = Gen<(String, [Param])>.zip(string, text).map { ($0, $1) }.proliferate

  public static var arbitrary: Gen<Head> {
    return Gen<([(String, [Param])], [Tail], [Tail])>.zip(heads, tail, tail).map {
      return Array(zip($1, $2)).enumerated().reduce(.node($0, [])) { head, tail in
        return head.add(node: tail.1.0, level: tail.0).add(node: tail.1.1, level: tail.0)
      }
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
}
