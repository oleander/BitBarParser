import Quick
import Nimble
import SwiftCheck
@testable import Parser

class ParserTests: QuickSpec {
  override func spec() {
    for n in 0...runs {
      it("handles raw tail (\(n)") {
        property("raw tail", arguments: args) <- forAll { (head: Raw.Head) in
          let input = head.reduce().output
          switch Pro.parse(Pro.output, input) {
          case let .success(other):
            return other.reduce() ==== head ^&&^ head.reduce() ==== other
          case let .failure(error):
            return false <?> ("warning: Parse error: " + String(describing: error))
          }
        }
      }
    }
  }
}
