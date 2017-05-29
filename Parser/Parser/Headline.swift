import FootlessParser

enum Either<T, U> {
	case left(T)
	case right(U)
}

typealias Line = (level: Int, title: String, params: [Raw.Param])
typealias Value<T> = Either<T, ValueError>

extension Pro {
  fileprivate enum Custom {
    case head(Line)
    case tail(Head)
    case eof(Head)
  }
  internal static let ws = zeroOrMore(whitespace)
  typealias Head = Raw.Head
  typealias Tail = Raw.Tail

  static var output: P<Head> {
    return handle(.node([], []))
  }

  static func handle(_ outer: Head) -> P<Head> {
    let aLine = Custom.head <^> line
    let aMenu = Custom.tail <^> (string("---\n") *> menu(using: outer))
    let aNothing: P<Custom> = pure(Custom.eof(outer)) <* eof()
    return (aMenu <|> aLine <|> aNothing) >>- { custom in
      switch custom {
      case let .head(line):
        return handle(outer.append(line))
      case let .tail(head):
        return pure(head)
      case let .eof(head):
        return pure(head)
      }
    }
  }

  private static func menu(using head: Head) -> P<Head> {
    return ((head.add <^> menu) >>- menu(using:)) <|> pure(head)
  }

  // @input: --Title|param=1, output: 1, Title, {param: 1}, rest: ""
  // @input: -----\n, output: 1, ---\n, {}, rest: ""
  internal static var menu: P<(Tail, Int)> {
    return { line in
      switch line {
      case (0, "-", _):
        return (.node(line.title, line.params, []), line.level)
      case let (_, "-", params) where params.isEmpty:
        return (.node(line.title, line.params, []), line.level - 1)
      case let (_, "-", params):
        return (.error([.noParamsForSeparator(params)]), line.level - 1)
      default:
        return (.node(line.title, line.params, []), line.level)
      }
    } <^> line
  }

  internal static var line: P<Line> {
    return curry({ ($0, $1, $2) }) <^> level <*> text <*> params
  }

  // @input: Title\n, output: Title, \n
  // @input: Title|param=1, output: Title, |param1
  // @input: Title\n~~~, output: Title, \n~~~
  static var text: P<String> {
    return until(["\n", "|"], consume: false)
  }

  // @input: -----\n, output: 2, -\n
  // @input: ---\n, output: 1, -\n
  // @input: \n, output: 0, \n
  internal static var level: P<Int> {
    return { $0.count } <^> zeroOrMore(string("--"))
  }

  // @example: #ff0011
  static var hexColor: P<Value<Color>> {
    return quoteAnd({ .left(.hex($0)) } <^> (string("#") *> hex) <* ws)
  }

  // @example: red
  static var regularColor: P<Value<Color>> {
    return { name in
      if let hex = Color.names[name.lowercased()] {
        return .left(.hex(hex))
      }

      return .right(.color(name))
    } <^> quoteOrWord <* ws
  }

  static var float: P<Value<Float>> {
    let das = digitsAsString
    let maybeFloat = curry({ a, b in "\(a).\(b)" })
      <^> das <*> optional(string(".") *> das, otherwise: "0")

    return { maybe in
      if let float = Float(maybe) {
        return .left(float)
      }

      return .right(.float(maybe))
    } <^> maybeFloat
  }

  // @example: "hello" or hello
  static var quoteOrWord: P<String> {
    return quoteOr(word)
  }

  // Match everything between ' or " or the entire @parser
  // TODO: Handle escaped quotes
  static func quoteOr(_ parser: P<String>) -> P<String> {
    return quote <|> parser
  }

  // @example: "10" (as a string)
  static var digitsAsString: P<String> {
    return oneOrMore(digit)
  }

  // @example: 10
  static var digits: P<Value<Int>> {
    return { maybe in
      if let int = Int(maybe) {
        return .left(int)
      }

      return .right(.int(maybe))
    } <^> digitsAsString
  }

  // One or more characters without whitespace
  // @example: Hello
  // OK
  static var word: P<String> {
    return oneOrMore(satisfy(expect: "word") { (char: Character) in
      return String(char).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil
    })
  }

  // @example: true
  static var bool: P<Bool> {
    return truthy <|> falsy
  }

  // @example: font=10
  internal static func attributeWithError<T>(_ name: String, _ value: P<Value<T>>, _ block: @escaping (T) -> Raw.Param) -> P<Raw.Param> {
    let key = string(name) *> ws *> string("=") *> ws
    let content = { (that: Either<T, ValueError>) -> Raw.Param in
      switch that {
      case let .left(value):
        return block(value)
      case let .right(error):
        return .error(name, error)
      }
     } <^> value
    return (ws *> key *> content <* ws)
  }

  static func attributeWithoutError<T>(_ name: String, _ value: P<T>, _ block:  @escaping (T) -> Raw.Param) -> P<Raw.Param> {
    return attributeWithError(name, Either.left <^> value, block)
  }

  // @example: true
  static var truthy: P<Bool> {
    return quoteOr(string("true")) *> pure(true)
  }

  // @example: "FF00aa"
  static var hex: P<String> {
    return oneOrMore(digit <|> oneOf("ABCDEFabcdef"))
  }

  // @example: false
  static var falsy: P<Bool> {
    // FIXME: Check the value of bool within quotes. Same for truthy()
    return quoteOr(string("false")) *> pure(false)
  }

  // @example: "A B C"
  static var quote: P<String> {
    // TODO: Handle first char as escaped quote, i.e \"abc (same for quoteAnd)
    return oneOf("\"\'") >>- { (char: Character) in until(String(char)) }
  }

  /**
   Menu params, i.e | terminal=false length=10
   */
  internal static var params: P<[Raw.Param]> {
    return optional(
      ws *> string("|") *>
      ws *> zeroOrMore(ws *> param <* ws)
      <* ws, otherwise: []
    ) <* (ws <* oneOrMore(string("\n")))
  }

  static var param: P<Param> {
    return length <|>
      alternate <|>
      checked <|>
      ansi <|>
      bash <|>
      dropdown <|>
      emojize <|>
      color <|>
      font <|>
      trim <|>
      arg <|>
      href <|>
      image <|>
      refresh <|>
      size <|>
      terminal
  }

  static func quoteAnd<T>(_ parser: P<T>) -> P<T> {
    return oneOf("\"\'") >>- { (char: Character) in
      return parser <* string(String(char))
      } <|> parser
  }

  static func toImage(forKey key: String, _ type: Image.Sort) -> P<Param> {
    let img = { (raw: String) -> Value<Image> in
      if let _ = toData(base64: raw) {
        return .left(.base64(raw, type))
      } else if let _ = URL(string: raw) {
        return .left(.href(raw, type))
      }

      return .right(.base64OrHref(raw))
    } <^> quoteOrWord

    return attributeWithError(key, img, Raw.Param.image)
  }

  static func toData(base64: String) -> Data? {
    let options = Data.Base64DecodingOptions(rawValue: 0)
    return Data(base64Encoded: base64, options: options)
  }
}
