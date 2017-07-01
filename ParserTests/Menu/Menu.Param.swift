import SwiftCheck
@testable import Parser
// case alternate
// case checked

extension Menu.Param: Parsable {
  public var description: String { return output.inspected() }
  var output: String {
    switch self {
    case .checked:
      return "checked=true"
    case .alternate:
      return "alternate=true"
    }
  }

  static func ==== (lhs: Menu.Param, rhs: Menu.Param) -> Property {
    switch (lhs, rhs) {
    case (.alternate, .alternate):
      return true <?> "alternate"
    case (.checked, .checked):
      return true <?> "checked"
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }
}
