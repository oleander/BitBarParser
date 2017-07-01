import SwiftCheck
@testable import Parser
// case nop
// case refresh
// case script(Script)
// case href(String, [Event])

extension Action: Parsable {
  public var description: String { return output.inspected() }

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

  static func ==== (action: Action, params: [Raw.Param]) -> Property {
    switch action {
    case .nop:
      for param in params {
        let failed = false <?> "\(param) found when \(action) was expected"
        switch param {
        case .bash:
          return failed
        case .refresh(true):
          return failed
        case .argument:
          return failed
        case .terminal(true):
          return failed
        case .href:
          return failed
        default:
          break
        }
      }
      return true <?> "action nop"
    case .refresh where !params.has(.refresh(true)):
      return false <?> "action refresh not found in \(params)"
    case let .script(script):
      return script ==== params
    case let .href(url, _) where !params.has(.href(url)):
      return false <?> "action \(action) does not exist in \(params)"
    case let .href(_, events):
      return events ==== params
    default:
      return true <?> "action in params"
    }
  }

  static func ==== (lhs: Action, rhs: Action) -> Property {
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
}
