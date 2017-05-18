extension Action {
  public struct Script: Equatable {
    public let path: String
    public let args: [String]
    internal let events: [Event]

    public var openInTerminal: Bool {
      return events.has(.terminal)
    }

    public var refreshAfterExec: Bool {
      return events.has(.refresh)
    }

    init(path: (String), args: [String], events: [Event]) {
      self.path = path
      self.args = args
      self.events = events
    }

    public static func == (lhs: Script, rhs: Script) -> Bool {
      return lhs.path == rhs.path && lhs.args == rhs.args && lhs.events == rhs.events
    }
  }
}
