import SwiftCheck
@testable import Parser

extension Action.Script: Parsable {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .foreground(path, events):
      return toString(path, true, [], events)
    case let .background(path, args, events):
      return toString(path, false, args, events)
    }
  }

  public static func == (lhs: Action.Script, rhs: Action.Script) -> Bool {
    switch (lhs, rhs) {
    case let (.foreground(b1, e1), .foreground(b2, e2)):
      return b1 == b2 && e1 == e2
    case let (.background(b1, a1, e1), .background(b2, a2, e2)):
      return b1 == b2 && a1 == a2 && e1 == e2
    default:
      return false
    }
  }

  static func ==== (lhs: Action.Script, rhs: Action.Script) -> Property {
    switch (lhs, rhs) {
    case let (.foreground(b1, e1), .foreground(b2, e2)):
      return b1 ==== b2 ^&&^ e1 ==== e2
    case let (.background(b1, a1, e1), .background(b2, a2, e2)):
      return b1 ==== b2 ^&&^ a1 ==== a2 ^&&^ e1 ==== e2
    default:
      return false <?> "no match for action script \(lhs) vs \(rhs)"
    }
  }

  static func ==== (script: Action.Script, params: [Raw.Param]) -> Property {
    switch script {
    case let .foreground(path, events):
      return params.has(.bash(path)) ^&&^ events ==== params
    case let .background(path, args, events):
      return params.has(.bash(path)) ^&&^ events ==== params ^&&^ args ==== params
    }
  }

  private func toString(_ path: String, _ terminal: Bool, _ args: [String], _ events: [Event]) -> String {
    return (
      ["bash=\(path.quoted())", "terminal=\(terminal)"]
      + args.enumerated().map { "param\($0.0)=\($0.1.quoted())" }
      + events.map { $0.output }
    ).joined(separator: " ")
  }
}
