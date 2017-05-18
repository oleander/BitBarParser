import Foundation
import FootlessParser

extension Pro {
  private static let manager = NSFontManager.shared()
  typealias Param = Raw.Param
  /**
   Color attribute with hex or color value, i.e color=red or color=#ff00AA
   */
  static var color: P<Param> {
    return attributeWithError("color", hexColor <|> regularColor, Raw.Param.color)
  }

  /**
   Boolean ansi attribute, i.e ansi=false
   */
  static var ansi: P<Param> {
    return attributeWithoutError("ansi", bool, Param.ansi)
  }

  /**
   Boolean emojize attribute, i.e emojize=false
   */
  static var emojize: P<Param> {
    return attributeWithoutError("emojize", bool, Param.emojize)
  }

  /**
   Quote / unquoted image/templateImage attribute, i.e image="c2Rm=="
   */
  static var image: P<Param> {
    return toImage(forKey: "image", .normal) <|> toImage(forKey: "templateImage", .template)
  }

  /**
   Quote / unquoted href attribute, i.e href="http://google.com"
   */
  static var href: P<Param> {
    return attributeWithoutError("href", quoteOrWord, Param.href)
  }

  /**
   Quote / unquoted font attribute, i.e font="Monaco"
   */
  static var font: P<Param> {
    let that = { (font: String) -> Value<String> in
      let name = font.lowercased()
      let has = manager.availableFontFamilies.any {
        return $0.lowercased() == name
      }

      if has { return .left(name) }
      return .right(.font(name))
      } <^> quoteOrWord

    return attributeWithError("font", that, Raw.Param.font)
  }

  /**
   Unquoted size attribute as a positive int, i.e size=10
   */
  static var size: P<Param> {
    return attributeWithError("size", float, Param.size)
  }

  /**
   Quote / unquoted bash attribute, i.e bash="/usr/local/bin space"
   */
  static var bash: P<Param> {
    return attributeWithoutError("bash", quoteOrWord, Param.bash)
  }

  /**
   Boolean alternate attribute, i.e alternate=false
   */
  static var alternate: P<Param> {
    return attributeWithoutError("alternate", bool, Param.alternate)
  }

  /**
   Boolean checked attribute, i.e checked=true
   */
  static var checked: P<Param> {
    return attributeWithoutError("checked", bool, Param.checked)
  }

  /**
   Boolean trim attribute, i.e trim=false
   */
  static var trim: P<Param> {
    return attributeWithoutError("trim", bool, Param.trim)
  }

  /**
   Boolean dropdown attribute, i.e dropdown=false
   */
  static var dropdown: P<Param> {
    return attributeWithoutError("dropdown", bool, Param.dropdown)
  }

  /**
   Boolean refresh attribute, i.e refresh=false
   */
  static var refresh: P<Param> {
    return attributeWithoutError("refresh", bool, Param.refresh)
  }

  /**
   Boolean terminal attribute, i.e terminal=false
   */
  static var terminal: P<Param> {
    return attributeWithoutError("terminal", bool, Param.terminal)
  }

  /**
   Named param with a quoted / unquoted value, i.e param12="A value"
   */
  static var arg: P<Param> {
    return curry({ key, value in
      switch key {
      case let .left(key):
        return .argument(key, value)
      case let .right(error):
        return .error("param", error)
      }
    }) <^> ((ws *> string("param")) *> digits <* string("=")) <*> (ws *> quoteOrWord <* ws)
  }

  /**
   Int length attribute, i.e length=11
   */
  static var length: P<Param> {
    return attributeWithError("length", digits, Raw.Param.length)
  }
}
