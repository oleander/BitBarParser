import SwiftCheck
@testable import Parser

extension Action.Script: Parsable {
  public var description: String { return output.inspected() }

  var output: String {
    return (
      ["bash=\(path.quoted())"]
      + args.enumerated().map { "param\($0.0)=\($0.1.quoted())" }
      + events.map { $0.output }
    ).joined(separator: " ")
  }

  public static func == (lhs: Action.Script, rhs: Action.Script) -> Bool {
    return lhs.path == rhs.path && lhs.args == rhs.args && lhs.events == rhs.events
  }

  static func ==== (lhs: Action.Script, rhs: Action.Script) -> Property {
    return lhs.path ==== rhs.path ^&&^ lhs.args ==== rhs.args ^&&^ lhs.events ==== rhs.events
  }

  static func ==== (script: Action.Script, params: [Raw.Param]) -> Property {
    guard params.has(.bash(script.path)) else {
      return false <?> "cannot find bash=\(script.path) in \(params)"
    }

    return script.events ==== params ^&&^ script.args ==== params
  }
}
