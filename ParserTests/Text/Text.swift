import SwiftCheck
@testable import Parser
// case normal(String, [Param])

extension Text: Parsable, Equatable {
  public var description: String { return output.inspected() }
  var output: String {
    return toString([], .nop)
  }

  public static func == (lhs: Text, rhs: Text) -> Bool {
    switch (lhs, rhs) {
    case let (.normal(t1, p1), .normal(t2, p2)):
      return t1 == t2 && p1 == p2
    }
  }

  static func ==== (lhs: Text, rhs: Text) -> Property {
    switch (lhs, rhs) {
    case let (.normal(t1, p1), .normal(t2, p2)):
      return t1 ==== t2 ^&&^ p1 ==== p2
    }
  }

  static func ==== (text: Text, title: String) -> Property {
    switch text {
    case let .normal(other, _):
      return other ==== title
    }
  }

  static func ==== (text: Text, params: [Raw.Param]) -> Property {
    switch text {
    case let .normal(_, other):
      return other ==== params
    }
  }

  func toString(_ p2: [Menu.Param], _ action: Action) -> String {
    switch self {
    case let .normal(title, p1):
      let params = p1.map { $0.output } + p2.map { $0.output }
      switch (params.isEmpty, action) {
      case (true, .nop):
        return title.titled()
      case (false, .nop):
        return title.titled() + "| " + params.joined(separator: " ")
      case (true, _):
        return title.titled() + "| " + action.output
      case (_, _):
        return title.titled() + "| " + params.joined(separator: " ") + " " + action.output
      }
    }
  }
}
