import SwiftCheck
@testable import Parser

extension Image: Parsable, Arbitrary {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .base64(data, .template):
      return "templateImage=\(data.quoted())"
    case let .base64(data, .normal):
      return "image=\(data.quoted())"
    case let .href(url, .template):
      return "templateImage=\(url.quoted())"
    case let .href(url, .normal):
      return "image=\(url.quoted())"
    }
  }

  static let b64 = ascii.map { $0.base64 }
  static let b1 = b64.map { Image.base64($0, .template) }
  static let b2 = b64.map { Image.base64($0, .normal) }
  static let u1 = url.map { Image.href($0, .template) }
  static let u2 = url.map { Image.href($0, .normal) }

  public static var arbitrary: Gen<Image> {
    return [b1, b2, u1, u2].one()
  }
}
