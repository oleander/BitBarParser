import SwiftCheck
@testable import Parser

// case node(String, [Param], [Tail])
// case error([MenuTest])
extension Raw.Tail: Arbitrary, Equatable {
  public typealias Tail = Raw.Tail
  public typealias Param = Raw.Param

  public static var arbitrary: Gen<Tail> {
    return Gen<(String, [Param])>.zip(string, Param.both).map {
      return .node($0, $1, [])
    }
  }

  public static func == (lhs: Raw.Tail, rhs: Raw.Tail) -> Bool {
    preconditionFailure("should not be used")
  }

  public static func ==== (lhs: Raw.Tail, rhs: Raw.Tail) -> Property {
    preconditionFailure("should not be used")
  }
}
