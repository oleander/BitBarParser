extension Action {
  public struct Script {
    let path: String
    let args: [String]
    let events: [Event]

    var openInTerminal: Bool {
      return events.has(.terminal)
    }

    var refreshAfterExec: Bool {
      return events.has(.refresh)
    }
  }
}
