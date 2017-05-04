import SwiftCheck
@testable import Parser
// case nop
// case refresh
// case script(Script)
// case href(String, [Event])

extension Action: Parsable {
  public var description: String { return output.inspected() }

  public static func == (lhs: Action, rhs: Action) -> Bool {
    switch (lhs, rhs) {
    case (.nop, nop):
      return true
    case (.refresh, .refresh):
      return true
    case let (.script(s1), .script(s2)):
      return s1 == s2
    case let (.href(u1, e1), .href(u2, e2)):
      return u1 == u2 && e1 == e2
    default:
      return false
    }
  }

  public static func ==== (lhs: Action, rhs: Action) -> Property {
    switch (lhs, rhs) {
    case (.nop, nop):
      return true <?> "nop"
    case (.refresh, .refresh):
      return true <?> "refresh"
    case let (.script(s1), .script(s2)):
      return s1 ==== s2
    case let (.href(u1, e1), .href(u2, e2)):
      return u1 ==== u2 ^&&^ e1 ==== e2
    default:
      return false <?> "no match for action \(lhs) vs \(rhs)"
    }
  }

  var output: String {
    switch self {
    case .nop:
      return ""
    case .refresh:
      return "refresh=true"
    case let .script(script):
      return script.output
    case let .href(url, events):
      return (["href=\(url.quoted())"] + events.map { $0.output }).joined(separator: " ")
    }
  }
}
