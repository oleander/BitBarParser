extension Array where Element: Equatable {
  func has(_ el1: Element) -> Bool {
    for el2 in self where el1 == el2 {
      return true
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

extension Array where Element == (String, [Raw.Param]) {
  var errors: [(String, ValueError)] {
    return reduce([]) { acc, el in
      return el.1.reduce(acc) { acc, param in
        switch param {
        case let .error(key, error):
          return acc + [(key, error)]
        default:
          return acc
        }
      }
    }
  }
}

extension Array where Element == Raw.Param {
  var image: Image? {
    return reduce(.none) { acc, param in
      switch param {
      case let .image(image):
        return .some(image)
      default:
        return acc
      }
    }
  }
}
