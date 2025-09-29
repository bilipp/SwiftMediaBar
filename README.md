# SwiftMediaBar

A sleek macOS menu bar application that displays your currently playing media information right in your menu bar. SwiftMediaBar provides a clean, unobtrusive way to see what's playing across all your media applications.

![SwiftMediaBar Demo](https://img.shields.io/badge/Platform-macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Real-time Media Display**: Shows currently playing song, artist, and album in your menu bar
- **Universal Compatibility**: Works with Apple Music, Spotify, and other media applications
- **Album Artwork**: Displays album artwork when available
- **Playback Status**: Shows play/pause status and progress information
- **Clean Interface**: Minimalist design that doesn't clutter your menu bar
- **Lightweight**: Runs efficiently in the background with minimal resource usage
- **Auto-refresh**: Updates every 5 seconds to keep information current

## Screenshots

### Menu Bar Display

The app shows a compact view of your current media in the menu bar:

```
♪ Artist Name - Song Title
```

### Detailed Popover

Click the menu bar item to see detailed information including:

- Album artwork
- Full song title, artist, and album
- Playback status
- Additional metadata (genre, track number, source app)

## Requirements

- **macOS**: Compatible with all macOS versions including the latest macOS Sonoma
- **media-control**: Version 0.7.2 (automatically handles media information retrieval)
- **Xcode**: 15.0 or later (for building from source)

## Installation

### Option 1: Download Pre-built App (Recommended)

1. Download the latest release from the [Releases](../../releases) page
2. Unzip the downloaded file
3. Move `SwiftMediaBar.app` to your Applications folder
4. Install the required dependency (see below)

### Option 2: Build from Source

1. Clone this repository:

   ```bash
   git clone https://github.com/bilipp/SwiftMediaBar.git
   cd SwiftMediaBar
   ```

2. Open the project in Xcode:

   ```bash
   open SwiftMediaBar.xcodeproj
   ```

3. Build and run the project (⌘+R)

### Installing media-control Dependency

SwiftMediaBar requires the `media-control` command-line tool to function. Install it using Homebrew:

```bash
brew install media-control
```

**Important**: Only version 0.7.2 of media-control has been tested and confirmed to work with SwiftMediaBar. If you encounter issues, ensure you're using this specific version:

```bash
brew install media-control@0.7.2
```

## Usage

### Getting Started

1. Launch SwiftMediaBar from your Applications folder
2. The app will appear in your menu bar with a musical note (♪) icon
3. Start playing music in any supported application
4. The menu bar will update to show your current media information

### Menu Bar Display

- **No Media**: Shows "♪" when nothing is playing
- **Loading**: Shows "♪ Loading..." while fetching information
- **Playing**: Shows "♪ Artist - Song Title" (truncated to fit)
- **Error**: Shows "♪ Error" if there's an issue

### Detailed View

Click the menu bar item to open a popover with detailed information:

- Album artwork (when available)
- Full song title, artist, and album names
- Playback status (playing/paused)
- Additional metadata like genre and track number
- Source application information

### Quitting the App

Click the menu bar item and select "Quit SwiftMediaBar" from the popover.

## Supported Applications

SwiftMediaBar works with any application that provides media information through macOS's Media Remote framework, including:

- **Apple Music**
- **Spotify**
- **iTunes**
- **VLC**
- **QuickTime Player**
- **Safari** (for web-based media)
- **Chrome** (for web-based media)
- And many more!

## Configuration

SwiftMediaBar works out of the box with minimal configuration needed. The app automatically:

- Updates every 5 seconds
- Truncates long titles to fit in the menu bar
- Handles different media sources
- Manages album artwork display

### Customization Options

Currently, SwiftMediaBar focuses on simplicity and doesn't require configuration. Future versions may include:

- Custom update intervals
- Display format options
- Menu bar text length preferences

## Troubleshooting

### Common Issues

#### "No Media Playing" when music is playing

**Cause**: The media-control dependency might not be installed or accessible.

**Solutions**:

1. Verify media-control is installed:

   ```bash
   which media-control
   ```

   Should return: `/opt/homebrew/bin/media-control`

2. Test media-control directly:

   ```bash
   media-control get
   ```

3. Reinstall media-control:
   ```bash
   brew uninstall media-control
   brew install media-control
   ```

#### "Error" message in menu bar

**Cause**: Permission issues or media-control execution problems.

**Solutions**:

1. Check if media-control has proper permissions
2. Restart SwiftMediaBar
3. Ensure your media application is actually playing content

#### App doesn't appear in menu bar

**Cause**: The app might have crashed or failed to launch properly.

**Solutions**:

1. Check Activity Monitor for SwiftMediaBar process
2. Try launching from Terminal to see error messages:
   ```bash
   /Applications/SwiftMediaBar.app/Contents/MacOS/SwiftMediaBar
   ```
3. Restart your Mac if the issue persists

#### Outdated or incorrect media information

**Cause**: Caching or timing issues with media updates.

**Solutions**:

1. Wait a few seconds for the next automatic update
2. Restart SwiftMediaBar
3. Check if the source media application is responding properly

### Getting Help

If you encounter issues not covered here:

1. Check the [Issues](../../issues) page for similar problems
2. Create a new issue with:
   - Your macOS version
   - media-control version (`media-control --version`)
   - Steps to reproduce the problem
   - Any error messages

## Development

### Project Structure

```
SwiftMediaBar/
├── SwiftMediaBar/
│   ├── SwiftMediaBarApp.swift      # Main app entry point
│   ├── Managers/
│   │   └── MenuBarManager.swift    # Menu bar management
│   ├── Services/
│   │   └── MediaService.swift      # Media information service
│   ├── Models/
│   │   └── MediaInfo.swift         # Media data model
│   └── Views/
│       └── MenuView.swift          # Popover UI
├── SwiftMediaBarTests/             # Unit tests
└── SwiftMediaBarUITests/           # UI tests
```

### Key Components

- **MenuBarManager**: Handles menu bar item creation and updates
- **MediaService**: Interfaces with media-control to fetch media information
- **MediaInfo**: Data model representing current media state
- **MenuView**: SwiftUI view for the detailed popover interface

### Building and Testing

1. Open `SwiftMediaBar.xcodeproj` in Xcode
2. Select the SwiftMediaBar scheme
3. Build with ⌘+B or run with ⌘+R
4. Run tests with ⌘+U

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Dependencies

- **media-control**: Command-line tool for media information retrieval
  - Repository: [ungive/media-control](https://github.com/ungive/media-control)
  - Required version: 0.7.2
  - License: MIT

## License

This project is licensed under the MIT License.

## Acknowledgments

- [ungive/media-control](https://github.com/ungive/media-control) - Essential command-line tool that makes this app possible
- [menubar-ticker](https://github.com/serban/menubar-ticker) - General idea of a menu bar media ticker
- Apple's MediaRemote framework - Underlying technology for media information access
- The Swift and SwiftUI communities for excellent documentation and examples

## Changelog

### Version 0.1.0

- Initial release
- Basic media information display in menu bar
- Detailed popover view with album artwork
- Support for all major media applications
- Integration with media-control 0.7.2

---

**Note**: This app is not affiliated with Apple Inc. or any media application providers. It simply displays information that's already available through macOS's built-in media frameworks.
