import SwiftCheck

protocol Parsable: CustomStringConvertible {
  var output: String { get }
}
