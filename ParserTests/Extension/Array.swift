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
