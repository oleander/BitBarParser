extension Accumulator {
  enum Script {
    case foreground(String?, [Event])
    case background(String?, [Int: String], [Event])

    init(foreground state: Bool) {
      if state {
        self = .foreground(.none, [])
      } else {
        self = .background(.none, [:], [])
      }
    }

    init(path: String) {
      self = .background(path, [:], [])
    }

    init(path: String, events: [Event]) {
      self = .background(path, [:], events)
    }

    init(arg: String, at index: Int) {
      self = .background(.none, [index: arg], [])
    }

    internal func set(path: String) -> Result<Script> {
      switch self {
      case let .foreground(.none, events):
        return .output(.foreground(path, events))
      case let .background(.none, args, events):
        return .output(.background(path, args, events))
      default:
        return .error(["Path has already been set"])
      }
    }

    internal func set(arg: String, at index: Int) -> Result<Script> {
      switch self {
      case .foreground:
        return .output(Script.foreground(path, events))
      case .background where has(index):
        return .error(["param\(index)='...' has already been set"])
      case .background:
        return .output(.background(path, set(index: index, value: arg), events))
      }
    }

    internal func set(foreground state: Bool) -> Result<Script> {
      switch (self, state) {
      case let (.background(path, args, events), true) where args.isEmpty:
        return .output(.foreground(path, events))
      case (.background, true):
        return .error(["paramx='...' not allowed when terminal=true"])
      case (.foreground, true):
        return .output(self)
      case (.background, false):
        return .output(self)
      case let (.foreground(path, events), false):
        return .output(.background(path, args, events))
      }
    }

    internal func set(refresh: Bool) -> Result<Script> {
      switch (self, refresh) {
        /* Bad */
      case (.foreground, true) where has(.refresh): fallthrough
      case (.background, true) where has(.refresh):
        return .error(["Refresh has already been set"])

        /* refresh: true */
      case (.foreground, true):
        return .output(.foreground(path, events + [.refresh]))
      case (.background, true):
        return .output(.background(path, args, events + [.refresh]))

        /* refresh: false */
      case (.foreground, false):
        return .output(.foreground(path, remove(.refresh)))
      case (.background, false):
        return .output(.background(path, args, remove(.refresh)))
      }
    }

    internal func reduce() -> Result<Action.Script> {
      switch self {
      case let .foreground(.some(path), events):
        return .output(Action.Script.foreground(path, events))
      case let .background(.some(path), args, events):
        return .output(.background(path, sort(args), events))
      default:
        return .error(["The bash param is not set: \(self)"])
      }
    }

    private func sort(_ args: [Int: String]) -> [String] {
      return args.keys.sorted { a, b in a < b }.map { i in args[i]! }
    }

    private func has(_ event: Event) -> Bool {
      return events.any { e in e == event }
    }

    private func has(_ index: Int) -> Bool {
      return args[index] != nil
    }

    private func remove(_ event: Event) -> [Event] {
      return events.filter { e in e != event }
    }

    func add(event: Event) -> Result<Script> {
      switch self {
      case let .background(path, args, events) where !has(event):
        return .output(.background(path, args, events + [event]))
      case let .foreground(path, events) where !has(event):
        return .output(.foreground(path, events + [event]))
      default:
        return .error(["Duplicate events, \(event) already exists in \(self)"])
      }
    }

    func set(index: Int, value: String) -> [Int: String] {
      var args_ = args
      args_[index] = value
      return args_
    }

    private var args: [Int: String] {
      switch self {
      case let .background(_, args, _):
        return args
      case .foreground:
        preconditionFailure("[Bug] foreground doesn't have any args")
      }
    }

    private var events: [Event] {
      switch self {
      case let .background(_, _, events):
        return events
      case let .foreground(_, events):
        return events
      }
    }

    private var path: String? {
      switch self {
      case let .background(path, _, _):
        return path
      case let .foreground(path, _):
        return path
      }
    }
  }
}
