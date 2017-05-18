extension Action {
  public struct Script {
    public let path: String
    public let args: [String]
    private let events: [Event]

    public var openInTerminal: Bool {
      return events.has(.terminal)
    }

    public var refreshAfterExec: Bool {
      return events.has(.refresh)
    }
  }
}
