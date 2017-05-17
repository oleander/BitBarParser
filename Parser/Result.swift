infix operator +|: AdditionPrecedence
infix operator +!: AdditionPrecedence

enum Result<T> {
  case bad([String])
  case good(T)

  var errors: [String] {
    switch self {
    case let .bad(messages):
      return messages
    default:
      return []
    }
  }

  func map<U>(_ block: (T) -> U) -> Result<U> {
    return flatMap { .good(block($0)) }
  }

  func flatMap<U>(_ block: (T) -> Result<U>) -> Result<U> {
    switch self {
    case let .good(value):
      return block(value)
    case let .bad(messages):
      return .bad(messages)
    }
  }
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

func +! <T, U>(lhs: Result<T>, rhs: Result<U>) -> [String] {
  return lhs.errors + rhs.errors
}

func +! <T>(lhs: Result<T>, rhs: [String]) -> [String] {
  return lhs.errors + rhs
}

func +! <T>(lhs: [String], rhs: Result<T>) -> [String] {
  return lhs + rhs.errors
}
