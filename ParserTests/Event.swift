import SwiftCheck
@testable import Parser

extension Event: CustomStringConvertible {
  public var description: String { return output.inspected() }
  var output: String {
    switch self {
    case .refresh:
      return "refresh=true"
    }
  }

  public static func ==== (lhs: Event, rhs: Event) -> Property {
    switch (lhs, rhs) {
    case (.refresh, .refresh):
      return true <?> "refresh"
    }
  }
}
