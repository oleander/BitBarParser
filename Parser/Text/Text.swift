public enum Text {
  case normal(String, [Param])

  static func reduce(_ title: String, _ params: [Raw.Param]) -> Result<Text> {
    return Text.Param.reduce(params).map { .normal(title, $0) }
  }

  static func reduce(_ pairs: [(String, [Raw.Param])]) -> Result<[Text]> {
    return pairs.reduce(.good([])) { acc, pair in
      acc +| Text.reduce(pair.0, pair.1)
    }
  }
}
