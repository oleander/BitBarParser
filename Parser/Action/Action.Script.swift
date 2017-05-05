extension Action {
  public enum Script {
    case foreground(String, [Event])
    case background(String, [String], [Event])
  }
}
