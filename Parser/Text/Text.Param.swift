fileprivate typealias Fontable = (String?, Float?)

extension Text {
  public enum Param: Equatable {
    case font(Font)
    case color(Color)
    case length(Int)
    case emojize
    case ansi
    case trim

    static func reduce(_ params: [Raw.Param]) -> Result<[Text.Param]> {
      let init1: Result<Fontable> = .good((nil, nil))
      let initState = params.reduce(init1) { acc, param in
        return acc.flatMap { (acc: Fontable) -> Result<Fontable> in
          switch (acc, param) {
          /* Valid states */
          case let ((name, .none), .size(size)):
            return .good((name, size))
          case let ((.none, size), .font(name)):
            return .good((name, size))
          /* Invalid states */
          case ((_, .some), .size):
            return .bad(["Size can't be defined twice"])
          case ((.some, _), .font):
            return .bad(["Font can't be defined twice"])
          default:
            return .good(acc)
          }
        }
      }

      let init2: Result<[Text.Param]> = initState.map { maybe -> Font? in
        switch maybe {
        case let (.some(font), .some(size)):
          return .font(font, size)
        case let (.some(name), .none):
          return .name(name)
        case let (.none, .some(size)):
          return .size(size)
        default:
          return nil
        }
      }.map { maybe in
        if let font = maybe {
          return [.font(font)]
        }

        return []
      }

      return params.reduce(init2) { acc, param in
        return acc.map { acc in
          switch param {
          case let .length(value):
            return acc + [.length(value)]
          case let .color(color):
            return acc + [.color(color)]
          case .emojize(true):
            return acc + [.emojize]
          case .ansi(true):
            return acc + [.ansi]
          case .trim(true):
            return acc + [.trim]
          default:
            return acc
          }
        }
      }
    }

    private static func initFrom(_ params: [Raw.Param]) -> [Text.Param] {
      if hasTrim(params) { return [] }
      return []
    }

    private static func hasTrim(_ params: [Raw.Param]) -> Bool {
      return params.reduce(false) { acc, param in
        if case .trim = param { return true }
        return acc
      }
    }

    public static func == (lhs: Text.Param, rhs: Text.Param) -> Bool {
      switch (lhs, rhs) {
      case let (.font(f1), .font(f2)):
        return f1 == f2
      case let (.length(l1), .length(l2)):
        return l1 == l2
      case let (.color(c1), .color(c2)):
        return c1 == c2
      case (.emojize, .emojize):
        return true
      case (.ansi, ansi):
        return true
      case (.trim, .trim):
        return true
      default:
        return false
      }
    }
  }
}
