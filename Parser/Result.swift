enum Result<T> {
  case error([String])
  case output(T)

  var errors: [String] {
    switch self {
    case let .error(messages):
      return messages
    default:
      return []
    }
  }
}
