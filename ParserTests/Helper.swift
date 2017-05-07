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

func  ~= (lhs: [Raw.Param], rhs: [Raw.Param]) -> Bool {
  return lhs == rhs
}

func  ~= (lhs: [Raw.Tail], rhs: [Raw.Tail]) -> Bool {
  return lhs == rhs
}

func ==== (args: [String], params: [Raw.Param]) -> Property {
  if args.isEmpty {
    let noOfArgs = params.reduce(0) { acc, arg in
      switch arg {
      case .argument:
        return acc + 1
      default:
        return acc
      }
    }

    if noOfArgs != 0 {
      return false <?> "arguments missing from args in \(params)"
    }

    return true <?> "args == params"
  }

  let onlyArgs: [Raw.Param] = params.reduce([]) { (acc: [Raw.Param], param: Raw.Param) in
    switch param {
    case .argument:
      return acc + [param]
    default:
      return acc
    }
  }

  let argsToComp: [String] = onlyArgs.sorted { a, b in
    switch (a, b) {
    case let (.argument(index1, _), .argument(index2, _)):
      return index1 < index2
    default:
      preconditionFailure("\(a) or \(b) is not an argument")
    }
  }.map { argument in
    switch argument {
    case let .argument(_, arg):
      return arg
    default:
      preconditionFailure("\(argument) is not an argument")
    }
  }

  for (index, arg) in args.enumerated() {
    if argsToComp[index] != arg {
      return false <?> "param with index \(index) is missing from \(params) (\(argsToComp))"
    }
  }

  for param in params {
    switch param {
    case let .argument(_, arg) where !args.has(arg):
      return false <?> "arg param \(param) exists in raw params but not in \(args)"
    default:
      break
    }
  }

  return true <?> "args == params"
}

func ==== (events: [Event], params: [Raw.Param]) -> Property {
  for param in params {
    switch param {
    case let .refresh(state) where events.has(.refresh) != state:
      return false <?> "param \(param) missing from events list \(events)"
    default:
      break
    }
  }

  for event in events {
    switch event {
    case .refresh:
      if !params.has(.refresh(true)) {
        return false <?> "event \(event) not found in \(params)"
      }
    }
  }

  return true <?> "events == params"
}

func ==== (menuParams: [Menu.Param], rawParams: [Raw.Param]) -> Property {
  for rawParam in rawParams {
    let failed = false <?> "raw param \(rawParam) exist in raw params, but not in menu params \(menuParams)"
    switch rawParam {
    case let .alternate(state) where menuParams.has(.alternate) != state:
      return failed
    case let .checked(state) where menuParams.has(.checked) != state:
      return failed
    default:
      break
    }
  }

  for menuParam in menuParams {
    switch menuParam {
    case .alternate where !rawParams.has(.alternate(true)):
      fallthrough
    case .checked where !rawParams.has(.checked(true)):
      return false <?> "menu param \(menuParam) not found in \(rawParams)"
    default:
      break
    }
  }

  return true <?> "menu params == raw params"
}

func ==== (menuTails: [Menu.Tail], rawTails: [Raw.Tail]) -> Property {
  for (menuTail, rawTail) in zip(menuTails, rawTails) {
    switch (menuTail, rawTail) {
    case let (.text(text, params1, tails1, action), .node(title, params2, tails2)):
      if params2.has(.dropdown(false)) && tails1.isEmpty {
        return true <?> "menu dropdown = false"
      } else if params2.has(.dropdown(false)) {
        return false <?> "menu dropdown = true for menu \(menuTail) from raw \(rawTail) but has a tail"
      }

      let hasImage = params2.reduce(false) { acc, param in
        switch param {
        case .image:
          return true
        default:
          return acc
        }
      }

      if hasImage {
        return false <?> "menu \(menuTail) is marked as text, but has an image in \(params2)"
      }

      return text ==== title ^&&^ params1 ==== params2 ^&&^ tails1 ==== tails2 ^&&^ action ==== params2
    case let (.image(image, params1, tails1, action), .node(_, params2, tails2)):
      return image ==== params2 ^&&^ params1 ==== params2 ^&&^ tails1 ==== tails2 ^&&^ action ==== params2
    case let (.error(m1, _), .error(m2)):
      return m1 ==== m2
    case (.separator, .node("-", [], [])):
      return true <?> "separator"
    default:
      return false <?> "menu tails \(menuTails) != \(rawTails)"
    }
  }

  if menuTails.count == rawTails.count {
    return true <?> "menu tails count == raw tails count"
  }

  return false <?> "menu tails count doesn't add up, \(menuTails) vs \(rawTails)"
}

func ==== (textParams: [Text.Param], rawParams: [Raw.Param]) -> Property {
  for rawParam in rawParams {
    let failed = false <?> "raw param \(rawParam) is missing from text params \(textParams)"
    switch rawParam {
    case let .font(name) where !textParams.has(.font(name)):
      return failed
    case let .length(value) where !textParams.has(.length(value)):
      return failed
    case let .color(color) where !textParams.has(.color(color)):
      return failed
    case let .size(size) where !textParams.has(.size(size)):
      return failed
    case let .emojize(state) where textParams.has(.emojize) != state:
      return failed
    case let .ansi(state) where textParams.has(.ansi) != state:
      return failed
    case let .trim(state) where textParams.has(.trim) != state:
      return failed
    default:
      break
    }
  }

  for textParam in textParams {
    let failed = false <?> "text param \(textParam) not in raw params \(rawParams)"
    switch textParam {
    case let .font(name) where !rawParams.has(.font(name)):
      return failed
    case let .length(value) where !rawParams.has(.length(value)):
      return failed
    case let .color(color) where !rawParams.has(.color(color)):
      return failed
    case let .size(value) where !rawParams.has(.size(value)): fallthrough
    case .emojize where !rawParams.has(.emojize(true)): fallthrough
    case .ansi where !rawParams.has(.ansi(true)): fallthrough
    case .trim where !rawParams.has(.trim(true)):
      return failed
    default:
      break
    }
  }

  return true <?> "text params == raw params"
}

var args: CheckerArguments {
  if isTravis() {
    return CheckerArguments(
      maxAllowableSuccessfulTests: 1500,
      maxTestCaseSize: 1500
    )
  }

  return CheckerArguments(
    maxAllowableSuccessfulTests: 100,
    maxTestCaseSize: 100
  )
}

func isTravis() -> Bool {
  return ProcessInfo.processInfo.environment["TRAVIS"] != nil
}
