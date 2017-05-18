enum Result<T> {
  case bad([MenuError])
  case good(T)

  var errors: [MenuError] {
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
