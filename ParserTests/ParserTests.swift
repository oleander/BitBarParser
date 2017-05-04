import Quick
import Nimble
import SwiftCheck
@testable import Parser

func verify(menu: Menu.Head, param: Raw.Param) -> Property {
  return menu.has(param) <?> "param: \(param)"
}

func verify(menu: Menu.Head, raw: Raw.Head) -> Property {
  switch raw {
  case let .node(_, params, _):
    return params.reduce(true <?> "params") { acc, param in
      return acc ^&&^ verify(menu: menu, param: param)
    }
  case .error:
    return false <?> "got error"
  }
}

class ParserTests: QuickSpec {
  override func spec() {
    it("handles raw tail") {
      property("raw tail") <- forAll(Raw.Head.arbitrary.resize(300)) { head in
        let input = head.reduce().output
        switch Pro.parse(Pro.output, input) {
          case let .success(other):
            return verify(menu: other.reduce(), raw: head) ^&&^ other.reduce() ==== head.reduce()
          case let .failure(error):
            return (false <?> String(describing: error)).whenFail {
              print("---------------- PARSE ERROR ------------------")
            }
         }
       }
     }
  }
}
