extension Action {
  public enum Script {
    case foreground(String, [String], [Event])
    case background(String, [String], [Event])
  }
}
