import SwiftCheck
@testable import Parser
// case normal(String, [Param])

extension Text: Parsable, Equatable {
  public var description: String { return output.inspected() }
  func toString(_ params: [Menu.Param], _ action: Action) -> String {
    switch self {
    case let .normal(title, params2):
      return output2(title.titled(), params.map { $0.output }, params2.map { $0.output } , action)
    }
  }

  var output: String {
    return toString([], .nop)
  }


  public static func ==== (lhs: Text, rhs: Text) -> Property {
    switch (lhs, rhs) {
    case let (.normal(t1, p1), .normal(t2, p2)):
      return t1 ==== t2 ^&&^ p1 ==== p2
    }
  }

  public static func == (lhs: Text, rhs: Text) -> Bool {
    switch (lhs, rhs) {
    case let (.normal(t1, p1), .normal(t2, p2)):
      return t1 == t2 && p1 == p2
    }
  }

  func has(_ param: Raw.Param) -> Bool {
    switch (param, self) {
    case let (.emojize(state), .normal(_, params)):
      return params.has(.emojize) == state
    case let (.ansi(state), .normal(_, params)):
      return params.has(.ansi) == state
    case let (.trim(state), .normal(_, params)):
      return params.has(.trim) == state
    case let (.size(value), .normal(_, params)):
      return params.has(.size(value))
    case let (.font(name), .normal(_, params)):
      return params.has(.font(name))
    case let (.color(value), .normal(_, params)):
      return params.has(.color(value))
    case let (.length(value), .normal(_, params)):
      return params.has(.length(value))
    default:
      preconditionFailure("Invalid state in text: param=\(param), self=\(self)")
    }
  }

  private func output2(_ title: String, _ params1: [String], _ params2: [String], _ action: Action) -> String {
      let x = params1 + params2
      switch (x.isEmpty, action) {
      case (true, .nop):
        return title
      case (false, .nop):
        return title + "| " + x.joined(separator: " ")
      case (true, _):
        return title + "| " + action.output
      case (_, _):
        return title + "| " + x.joined(separator: " ") + " " + action.output
      }
    }

}
