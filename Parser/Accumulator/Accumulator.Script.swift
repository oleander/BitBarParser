extension Accumulator {
  struct Script {
    var path: String?
    var args = [Int: String]()
    var events = [Event]()

    init(path: String?, args: [Int: String], events: [Event]) {
      self.path = path
      self.args = args
      self.events = events
    }

    init(foreground state: Bool) {
      if state {
        self.init(path: nil, args: [:], events: [.terminal])
      } else {
        self.init(path: nil, args: [:], events: [])
      }
    }

    init() {
      self.init(path: nil, args: [:], events: [])
    }

    init(arg: String, at index: Int) {
      self.init(path: nil, args: [index: arg], events: [])
    }

    mutating func set(path: String) {
      self.path = path
    }

    mutating func set(arg: String, at index: Int) {
      args[index] = arg
    }

    mutating func set(foreground state: Bool) {
      events.append(.terminal)
    }

    mutating func set(refresh shouldAddRefresh: Bool) {
      if shouldAddRefresh {
        events.append(.terminal)
      } else {
        events = events.filter { $0 == .terminal }
      }
    }

    internal func reduce() -> Result<Action.Script> {
      switch (args.isEmpty, events.isEmpty, path) {
      case (true, true, .none):
        return .bad([])
      case (false, true, .none):
        return .bad([.argumentsSetButNotBash(sortedArgs)])
      case (true, false, .none):
        return .bad([.eventsSetButNotBash(events)])
      case (false, false, .none):
        return .bad([.argumentsAndEventsAreSetButNotBash(sortedArgs, events)])
      case let (_, _, .some(path)):
        return .good(Action.Script(path: path, args: sortedArgs, events: events))
      }
    }

    mutating func add(event: Event) {
      events.append(event)
    }

    private var sortedArgs: [String] {
      return args.keys.sorted { a, b in a < b }.map { i in args[i]! }
    }
  }
}
