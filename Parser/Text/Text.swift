public enum Text: Equatable {
  case normal(String, [Param])

  static func reduce(_ title: String, _ params: [Raw.Param]) -> Result<Text> {
    return Text.Param.reduce(params).map { .normal(title, $0) }
  }

  static func reduce(_ pairs: [(String, [Raw.Param])]) -> Result<[Text]> {
    return pairs.reduce(.good([])) { acc, pair in
      acc +| Text.reduce(pair.0, pair.1)
    }
  }

  public static func == (lhs: Text, rhs: Text) -> Bool {
    switch (lhs, rhs) {
    case let (.normal(t1, p1), .normal(t2, p2)):
      return t1 == t2 && p1 == p2
    }
  }
}
