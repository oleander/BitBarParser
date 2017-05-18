import SwiftCheck
@testable import Parser

extension Color: Parsable, Arbitrary {
  public var description: String { return output.inspected() }
  public static var arbitrary: Gen<Color> {
    return [
      hexValue.map(Color.hex),
      Array(names.keys).any.map(Color.name)
    ].one()
  }

  var output: String {
    switch self {
    case let .hex(value):
      return "color=#\(value)"
    case let .name(name):
      return "color=\(name.quoted())"
    }
  }

  static func ==== (lhs: Color, rhs: Color) -> Property {
    switch (lhs, rhs) {
    case let (.name(s1), .name(s2)):
      return s1 ==== s2
    case let (.hex(c1), .hex(c2)):
      return c1 ==== c2
    default:
      return false <?> "no match for \(lhs), \(rhs)"
    }
  }

  static var hexColors: [String: String] {
    var store = [String: String]()
    for (key, value) in Color.names {
      store[value] = key
    }

    return store
  }
}
