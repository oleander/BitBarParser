import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([String])
extension Raw.Tail: Arbitrary, Equatable, CustomStringConvertible {
  public var description: String {
    return output.inspected()
  }
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  public static var arbitrary: Gen<Tail> {
    return Gen<(String, [Param])>.zip(string, Param.both).map {
      return .node($0, $1, [])
    }
  }

  var output: String { return toString(0) }

  func toString(_ level: Int) -> String {
    return indent(level) + title.titled() + "| " + params
      .map { $0.output }.joined(separator: " ") + "\n"
      + menus.map { $0.toString(level + 1) }.joined()
  }

  private func indent(_ level: Int) -> String {
    return (0..<level).map { _ in "--" }.joined()
  }

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

  public static func == (lhs: Raw.Tail, rhs: Raw.Tail) -> Bool {
    preconditionFailure("should not be used")
  }

  public static func ==== (lhs: Raw.Tail, rhs: Raw.Tail) -> Property {
    preconditionFailure("should not be used")
  }

}
