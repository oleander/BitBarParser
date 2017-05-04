import SwiftCheck
@testable import Parser

extension Action.Script: Parsable {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .foreground(bash, args, events):
      return toString(bash, true, args, events)
    case let .background(bash, args, events):
      return toString(bash, false, args, events)
    }
  }

  private func toString(_ path: String, _ terminal: Bool, _ args: [String], _ events: [Event]) -> String {
    return (
      ["bash=\(path.quoted())", "terminal=\(terminal)"]
      + args.enumerated().map { "param\($0.0)=\($0.1.quoted())" }
      + events.map { $0.output }
    ).joined(separator: " ")
  }

  public static func == (lhs: Action.Script, rhs: Action.Script) -> Bool {
    switch (lhs, rhs) {
    case let (.foreground(b1, a1, e1), .foreground(b2, a2, e2)):
      return b1 == b2 && a1 == a2 && e1 == e2
    case let (.background(b1, a1, e1), .background(b2, a2, e2)):
      return b1 == b2 && a1 == a2 && e1 == e2
    default:
      return false
    }
  }

  public static func ==== (lhs: Action.Script, rhs: Action.Script) -> Property {
    switch (lhs, rhs) {
    case let (.foreground(b1, a1, e1), .foreground(b2, a2, e2)):
      return b1 ==== b2 ^&&^ a1 ==== a2 ^&&^ e1 ==== e2
    case let (.background(b1, a1, e1), .background(b2, a2, e2)):
      return b1 ==== b2 ^&&^ a1 ==== a2 ^&&^ e1 ==== e2
    default:
      return false <?> "no match for action script \(lhs) vs \(rhs)"
    }
  }
}
