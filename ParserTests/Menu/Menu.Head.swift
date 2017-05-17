import SwiftCheck
@testable import Parser

// case text(Text, [Param], [Tail], Action)
// case error([String])

extension Menu.Head: Parsable, Equatable {
  public var description: String { return output.inspected() }

  var output: String {
    switch self {
    case let .text(text, tails) where tails.isEmpty:
      return text.map { $0.toString([], .nop) + "\n" }.joined()
    case let .text(text, tails):
      return text.map { $0.toString([], .nop) + "\n---\n" + tails.map { $0.output }.joined()  }.joined()
    case let .error(messages):
      return "[Error] Found \(messages.count) errors\n---\n"
        + messages.joined(separator: "\n")
        + "\n"
    }
  }

  public static func == (lhs: Menu.Head, rhs: Menu.Head) -> Bool {
    switch (lhs, rhs) {
    case let (.text(t1, p1), .text(t2, p2)):
      return t1 == t2 && p1 == p2
    case let (.error(m1), .error(m2)):
      return m1 == m2
    default:
      return false
    }
  }

  static func ==== (head: Menu.Head, raw: Raw.Head) -> Property {
    switch (head, raw) {
    case let (.text(text, tails1), .node(title, tails2)):
      return text ==== title ^&&^ tails1 ==== tails2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "\(head) != \(raw)"
    }
  }

  static func ==== (lhs: Menu.Head, rhs: Menu.Head) -> Property {
    switch (lhs, rhs) {
    case let (.text(t1, m1), .text(t2, m2)):
      return t1 ==== t2 ^&&^ m1 ==== m2
    case let (.error(m1), .error(m2)):
      return m1 ==== m2
    default:
      return false <?> "no match for \(lhs) & \(rhs)"
    }
  }
}


func ==== (texts: [Text], raws: [(String, [Raw.Param])]) -> Property {
  if texts.count != raws.count {
    return false <?> "count dont match \(texts) vs \(raws)"
  }

  for (index, text) in texts.enumerated() {
    if let (title, params) = raws.get(at: index) {
      if !(text == title) {
        return false <?> "\(text) != \(title)"
      }

      if !(text == params) {
        return false <?> "\(text) != \(params)"
      }
    } else {
      return false <?> "\(index) missing from \(raws)"
    }
  }
  
  return true <?> "texts == raws"
}
