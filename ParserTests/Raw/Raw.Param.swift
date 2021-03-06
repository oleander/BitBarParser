import SwiftCheck
@testable import Parser

extension Raw.Param: CustomStringConvertible {
  typealias Param = Raw.Param
  private static let manager = NSFontManager.shared()
  static let font_t = manager.availableFontFamilies.any.map { Param.font($0.lowercased()) }
  static let size_t = float.suchThat { $0 >= 0 }.map(Param.size)
  static let length_t = natural.map(Param.length)
  static let color_t = Color.arbitrary.map(Param.color)
  static let bash_t = string.map(Param.bash)
  static let dropdown_t = bool.map(Param.dropdown)
  static let emojize_t = bool.map(Param.emojize)
  static let ansi_t = bool.map(Param.ansi)
  static let trim_t = bool.map(Param.trim)
  static let checked_t = bool.map(Param.checked)
  static let alternate_t = bool.map(Param.alternate)
  static let refresh_t = bool.map(Param.refresh)
  static let terminal_t = bool.map(Param.terminal)
  static let href_t = url.map(Param.href)
  static let image_t: Gen<Param> = Image.arbitrary.map(Param.image)
  static let range = Gen<Int>.choose((0, 10))
  static let argument_t: Gen<[Param]> = range.flatMap { (lower: Int) in
    return range.suchThat { $0 >= lower }.flatMap { (upper: Int) in
      return (lower...upper).map { int in
        return string.map { Param.argument(int, $0) }
      }.shuffle()
    }
  }

  /* Background script, i.e bash='...', refresh=false, terminal=true, param1='...' */
  static let script = [bash_t, refresh_t, terminal_t].shuffle() + argument_t
  static let clickOrRef = [[href_t, refresh_t].one()].shuffle()

  /* An action, i.e href='..', refresh=true */
  static let action = [clickOrRef, script].one()

  static let textable = [size_t, font_t, length_t, color_t, emojize_t, ansi_t, trim_t,
    alternate_t, checked_t, dropdown_t].shuffle()
  static let textableish = [size_t, font_t, length_t, color_t, emojize_t, ansi_t, trim_t].shuffle()

  static let text = textable + action

  static let imageable = [image_t, alternate_t, checked_t, dropdown_t].shuffle()
  static let image = imageable + action

  static let both  = [text, image].one()

  var output: String {
    switch self {
    case let .font(name):
      return "font=\(name.quoted())"
    case let .size(value):
      return "size=\(value)"
    case let .length(value):
      return "length=\(value)"
    case let .emojize(state):
      return "emojize=\(state)"
    case let .ansi(state):
      return "ansi=\(state)"
    case let .trim(state):
      return "trim=\(state)"
    case let .color(color):
      return color.output
    case let .bash(path):
      return "bash=\(path.quoted())"
    case let .dropdown(state):
      return "dropdown=\(state)"
    case let .href(url):
      return "href=\(url.quoted())"
    case let .image(image):
      return image.output
    case let .terminal(state):
      return "terminal=\(state)"
    case let .refresh(state):
      return "refresh=\(state)"
    case let .alternate(state):
      return "alternate=\(state)"
    case let .checked(state):
      return "checked=\(state)"
    case let .argument(index, value):
      return "param\(index)=\(value.quoted())"
    default:
      preconditionFailure("Unknown param \(self)")
    }
  }

  public var description: String {
    return output.inspected()
  }
}
