extension Menu {
  public enum Param {
    case alternate
    case checked

    static func reduce(_ params: [Raw.Param]) -> Result<[Menu.Param]> {
      return params.reduce(.good([])) { params, param in
        return params.flatMap { params in
          switch param {
          case .alternate where params.has(.alternate):
            return .bad(["Alternate can only be defined once"])
          case .checked where params.has(.checked):
            return .bad(["Checked can only be defined once"])
          case .alternate(true):
            return .good(params + [.alternate])
          case .checked(true):
            return .good(params + [.checked])
          default:
            return .good(params)
          }
        }
      }
    }
  }
}
