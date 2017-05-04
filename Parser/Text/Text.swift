public enum Text {
  case normal(String, [Param])

  static func reduce(_ title: String, _ params: [Raw.Param]) -> Result<Text> {
    switch Text.Param.reduce(params) {
    case let .output(params):
      return .output(.normal(title, params))
    case let .error(message):
      return .error(message)
    }
  }

  static func reduce(_ params: [Raw.Param]) -> [Text.Param] {
    return params.reduce([]) { acc, param in
      switch param {
      case .trim(true):
        return acc + [.trim]
      case .ansi(true):
        return acc + [.ansi]
      case .emojize(true):
        return acc + [.emojize]
      case let .font(name):
        return acc + [.font(name)]
      case let .size(value):
        return acc + [.size(value)]
      case let .length(value):
        return acc + [.length(value)]
      case let .color(color):
        return acc + [.color(color)]
      default:
        return acc
      }
    }
  }
}
