@testable import Parser
import SwiftCheck

extension Array {
  var any: Gen<Element> {
    return Gen<Element>.fromElements(of: self)
  }

  func shuffle<T>() -> Gen<[T]> where Element == Gen<T> {
    return Gen<Element>.fromShufflingElements(of: self).flatMap(sequence)
  }

  func one<T>() -> Gen<T> where Element == Gen<T> {
    return Gen<T>.one(of: self)
  }

  func get(at index: Int) -> Element? {
    if count <= index { return nil }
    return self[index]
  }
}

extension Array where Element == Text.Param {
  func hasFont(name: String) -> Bool {
    for case let .font(font) in self where font == name {
      return true
    }
    return false
  }

  func hasFont(size: Float) -> Bool {
    for case let .font(font) in self where font == size {
      return true
    }
    return false
  }
}

extension Array where Element == Raw.Param {
  func has(font: Font) -> Bool {
    return font == self
  }
}
