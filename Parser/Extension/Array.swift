extension Array where Element: Equatable {
  func has(_ el1: Element) -> Bool {
    for el2 in self {
      if el1 == el2 {
        return true
      }
    }

    return false
  }
}

extension Array {
  func initial() -> [Element] {
    if isEmpty { return [] }
    return (0..<(count - 1)).map { self[$0] }
  }

  func any(_ check: (Element) -> Bool) -> Bool {
    return reduce(false) { acc, el in acc || check(el) }
  }
}
