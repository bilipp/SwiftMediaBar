import Foundation
import Testing
@testable import SwiftMediaBar

@MainActor
struct MenuBarDisplayTests {
  @Test(arguments: zip(
    [MenuBarDisplayFormat.artistTitle, .titleArtist, .titleOnly],
    ["Example Artist - Example Song", "Example Song - Example Artist", "Example Song"]
  ))
  func formatsMenuBarText(format: MenuBarDisplayFormat, expected: String) throws {
    let media = try JSONDecoder().decode(
      MediaInfo.self,
      from: Data(#"{"title":"Example Song","artist":"Example Artist","playing":true}"#.utf8)
    )

    #expect(media.menuBarText(format: format) == expected)
    #expect(media.truncatedMenuBarText(format: format) == expected)
  }

  @Test(arguments: zip(
    [MenuBarDisplayFormat.artistTitle, .titleArtist, .titleOnly],
    [
      "Example Artist - 012345678901234567890123456789...",
      "01234567890123456789012345678901234567890123456...",
      "01234567890123456789012345678901234567890123456..."
    ]
  ))
  func preservesExistingTruncation(format: MenuBarDisplayFormat, expected: String) throws {
    let media = try JSONDecoder().decode(
      MediaInfo.self,
      from: Data(#"{"title":"012345678901234567890123456789012345678901234567890123456789","artist":"Example Artist","playing":true}"#.utf8)
    )

    #expect(media.truncatedMenuBarText(format: format) == expected)
  }

  @Test(arguments: [MenuBarDisplayFormat.artistTitle, .titleArtist, .titleOnly])
  func remembersSelectedFormat(format: MenuBarDisplayFormat) throws {
    let suiteName = "SwiftMediaBarTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let preferences = MenuBarDisplayPreferences(defaults: defaults)
    #expect(preferences.format == .artistTitle)
    preferences.format = format

    let restored = MenuBarDisplayPreferences(defaults: defaults)
    #expect(restored.format == format)
  }
}
