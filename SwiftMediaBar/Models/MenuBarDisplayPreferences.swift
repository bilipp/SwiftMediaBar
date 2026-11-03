import Combine
import Foundation

@MainActor
final class MenuBarDisplayPreferences: ObservableObject {
  @Published var format: MenuBarDisplayFormat {
    didSet {
      defaults.set(format.rawValue, forKey: "menuBarDisplayFormat")
    }
  }

  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    let storedFormat = defaults.string(forKey: "menuBarDisplayFormat")
    self.format = storedFormat.flatMap(MenuBarDisplayFormat.init(rawValue:)) ?? .artistTitle
  }
}
