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
  if texts.isEmpty && raws.count == 1 {
    guard case let ("", params) = raws[0] else {
      return false <?> "invalid text"
    }

    return params.isEmpty <?> "is empty"
  }

  if raws.isEmpty && texts.count == 1 {
    guard texts[0] == "" else {
      return false <?> "invalid text"
    }

    guard texts[0] == [] else {
      return false <?> "invalid text"
    }

    return true <?> "valid text"
  }

  for (index, text) in texts.enumerated() {
    guard case let .some((title, params)) = raws.get(at: index) else {
      return false <?> "text \(text) not found in \(raws) at location \(index)"
    }

    guard (text == params) else {
      return text ==== params
    }

    guard text == title else {
      return text ==== title
    }

  }

  for (index, (title, params)) in raws.enumerated() {
    guard let text = texts.get(at: index) else {
      return false <?> "raw params \(params) not found in \(texts) at location \(index)"
    }

    guard (text == params) else {
      return text ==== params
    }

    guard text == title else {
      return text ==== title
    }
  }

  return true <?> "texts == raws"
}
