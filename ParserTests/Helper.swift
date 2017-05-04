import SwiftCheck
@testable import Parser

func toString(_ gens: Gen<Character>..., size: Int = 3) -> Gen<String> {
  return Gen<Character>.one(of: gens).proliferateRange(1, size).map { String.init($0) }
}
let low: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let up: Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let upperAF: Gen<Character> = Gen<Character>.fromElements(in: "A"..."F")
let loweraf: Gen<Character> = Gen<Character>.fromElements(in: "a"..."f")
let ascii = toString(low, up, numeric)
let positive = Int.arbitrary.suchThat { $0 >= 0 }
let hexValue: Gen<String> = Gen<Int>.choose((1, 6)).flatMap {
  return toString(upperAF, loweraf, numeric, size: $0)
}
let string = String.any(min: 1, max: 15).suchThat { !$0.hasPrefix("-") }
let natural = Int.arbitrary.suchThat { $0 > 0 }
let small = Int.arbitrary.suchThat { $0 >= 0 && $0 <= 500 }
let float = Gen<(Int, Int)>.zip(small, small).map {
  Float("\($0).\($1)")
}.suchThat { $0 != nil }.map { $0! }
let bool = Bool.arbitrary

func ==== <T: Equatable>(lhs: [T], rhs: [T]) -> Property {
 for (index, el1) in lhs.enumerated() {
   guard let el2 = rhs.get(at: index) else {
     return false <?> "Could not find element \(el1) at index \(index) in \(rhs)"
   }

   if el2 != el1 {
     return false <?> "\(el1) does not equal \(el2)"
   }
 }

  if lhs.count != rhs.count {
    return false <?> "Params count does not match"
  }

  return true <?> "[Arbitrary]"
}

func + <T>(a: Gen<[T]>, b: Gen<[T]>) -> Gen<[T]> {
  return Gen<([T], [T])>.zip(a, b).flatMap {
    return Gen<[T]>.fromShufflingElements(of: $0 + $1)
  }
}

func + <T: Integer>(a: Gen<T>, b: Gen<T>) -> Gen<T> {
  return Gen<(T, T)>.zip(a, b).map { $0 + $1 }
}

let special: Gen<Character> = Gen<Character>.fromElements(of:
  ["-", ".", "_", "~", ":", "/", "?", "#",
  "[", "]", "@", "!", "$", "&", "'", "(", ")", "*", "+", ",", ";"
])

let char: Gen<Character> = Gen<Character>.one(of: [
  low,
  numeric,
  special,
  up
])

let url = Gen<(String, String, String, String)>.zip(ascii, ascii, string, string).map { "http://\($0).\($1))/\($2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/\($3.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)" }

