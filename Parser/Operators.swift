infix operator +|: AdditionPrecedence
infix operator +!: AdditionPrecedence

func ~= (lhs: [String], rhs: [String]) -> Bool {
  return lhs == rhs
}

func + <T>(lhs: Result<[T]>, rhs: Result<[T]>) -> Result<[T]> {
  switch (lhs, rhs) {
  case let (.bad(m1), .bad(m2)):
    return .bad(m1 + m2)
  case let (o1, o2):
    return o1.flatMap { array1 in
      return o2.flatMap { array2 in .good(array1 + array2) }
    }
  }
}

func +| <T>(lhs: Result<[T]>, rhs: Result<T>) -> Result<[T]> {
  return lhs + rhs.map { [$0] }
}

func +! <T, U>(lhs: Result<T>, rhs: Result<U>) -> [MenuError] {
  return lhs.errors + rhs.errors
}

func +! <T>(lhs: Result<T>, rhs: [MenuError]) -> [MenuError] {
  return lhs.errors + rhs
}

func +! <T>(lhs: [MenuError], rhs: Result<T>) -> [MenuError] {
  return lhs + rhs.errors
}

public func reduce(_ data: String) -> Menu.Head {
  switch Pro.parse(Pro.output, data) {
    case let .success(raw):
      return raw.reduce()
    case let .failure(error):
      return .error([.parseError(error)])
   }
}
