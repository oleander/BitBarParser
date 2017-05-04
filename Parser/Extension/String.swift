extension String {
  func inspected() -> String {
    return "\"" + replace("\n", "↵").replace("\0", "0") + "\""
  }

  func replace(_ what: String, _ with: String) -> String {
    return replacingOccurrences(of: what, with: with, options: .literal, range: nil)
  }
}
