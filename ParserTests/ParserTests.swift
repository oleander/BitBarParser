import Quick
import Nimble
import SwiftCheck
@testable import Parser

class ParserTests: QuickSpec {
  override func spec() {
    context("automatic") {
      it("handles raw tail") {
        property("raw tail", arguments: args) <- forAll { (head: Raw.Head) in
          let input = head.reduce().output
          switch Pro.parse(Pro.output, input) {
          case let .success(other):
            return head.reduce() ==== other ^&&^ other.reduce() ==== head
          case let .failure(error):
            return false <?> ("Parse error: " + String(describing: error))
          }
        }
      }
    }

    context("manual") {
      context("no params") {
        it("handles non empty title") {
          switch Pro.parse(Pro.output, "ABC|\n") {
          case let .success(.node(rows, params)):
            expect(rows).to(haveCount(1))
            expect(rows[0].0).to(equal("ABC"))
            expect(rows[0].1).to(equal([]))
            expect(params).to(haveCount(0))
          case let nope:
            fail("nope: \(nope)")
          }
        }

        it("handles empty title") {
          switch Pro.parse(Pro.output, "|\n") {
          case let .success(.node(rows, params)):
            expect(rows).to(haveCount(1))
            expect(rows[0].0).to(equal(""))
            expect(rows[0].1).to(equal([]))
            expect(params).to(haveCount(0))
          case let nope:
            fail("nope: \(nope)")
          }
        }

        it("handles multiply empty rows") {
          switch Pro.parse(Pro.output, "\n|\n") {
          case let .success(.node(rows, params)):
            expect(rows).to(haveCount(2))
            expect(rows[0].0).to(equal(""))
            expect(rows[0].1).to(equal([]))
            expect(params).to(haveCount(0))
          case let nope:
            fail("nope: \(nope)")
          }
        }
      }
    }
  }
}
