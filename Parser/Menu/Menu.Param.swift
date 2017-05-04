extension Menu {
  public enum Param {
    case alternate
    case checked

    static func reduce(_ params: [Raw.Param]) -> Result<[Menu.Param]> {
      return params.reduce(.output([])) { params, param in
        switch (param, params) {
        case (_, .error):
          return params
        case let (.alternate, .output(params)) where params.has(.alternate):
          return .error(["Alternate can only be defined once"])
        case let (.checked, .output(params)) where params.has(.checked):
          return .error(["Checked can only be defined once"])
        case let (.alternate(true), .output(params)):
          return .output(params + [.alternate])
        case let (.checked(true), .output(params)):
          return .output(params + [.checked])
        default:
          return params
        }
      }
    }
  }
}
