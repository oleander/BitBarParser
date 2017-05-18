import SwiftCheck
@testable import Parser

func == (lhs: [(String, [Raw.Param])], rhs: [(String, [Raw.Param])]) -> Bool {
  for (index, item1) in lhs.enumerated() {
    let item2 = rhs[index]
    if item1.0 != item2.0 {
      return false
    }

    if item1.1 != item2.1 {
      return false
    }
  }
  return lhs.count == rhs.count
}

func ==== (texts: [Text], raws: [(String, [Raw.Param])]) -> Property {
  for (index, text) in texts.enumerated() {
    if case let .some((_, params)) = raws.get(at: index) {
      if !(text == params) { return text ==== params }
    } else {
      return false <?> "text \(text) not found in \(raws) at location \(index)"
    }
  }

  for (index, (_, params)) in raws.enumerated() {
    if let text = texts.get(at: index) {
      if !(text == params) { return text ==== params }
    } else {
      return false <?> "raw params \(params) not found in \(texts) at location \(index)"
    }
  }


  return true <?> "texts == raws"
}
