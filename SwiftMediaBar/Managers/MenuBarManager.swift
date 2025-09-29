//
//  MenuBarManager.swift
//  SwiftMediaBar
//
//  Created by Philipp Bischoff on 29.09.25.
//

import AppKit
import Combine
import SwiftUI

class MenuBarManager: ObservableObject {
  private var statusItem: NSStatusItem?
  private var mediaService: MediaService
  private var cancellables = Set<AnyCancellable>()
  private var popover: NSPopover?

  init() {
    self.mediaService = MediaService()
    setupStatusItem()
    setupBindings()
  }

  deinit {
    cleanup()
  }

  // MARK: - Setup Methods

  private func setupStatusItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    guard let statusItem = statusItem else {
      print("Failed to create status item")
      return
    }

    // Configure the status item button
    if let button = statusItem.button {
      button.title = "♪ Loading..."
      button.action = #selector(statusItemClicked)
      button.target = self
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    setupPopover()
  }

  private func setupPopover() {
    popover = NSPopover()
    popover?.contentSize = NSSize(width: 300, height: 400)
    popover?.behavior = .transient
    popover?.contentViewController = NSHostingController(
      rootView: MenuView(mediaService: mediaService)
    )
  }

  private func setupBindings() {
    // Listen to media service updates
    mediaService.$currentMedia
      .combineLatest(mediaService.$isLoading, mediaService.$lastError)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] (media, isLoading, error) in
        self?.updateStatusItemTitle()
      }
      .store(in: &cancellables)
  }

  // MARK: - Status Item Actions

  @objc private func statusItemClicked() {
    guard let statusItem = statusItem else { return }

    if let popover = popover {
      if popover.isShown {
        popover.performClose(nil)
      } else {
        if let button = statusItem.button {
          popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

          // Activate the app to bring the popover to front
          NSApp.activate(ignoringOtherApps: true)
        }
      }
    }
  }

  // MARK: - UI Updates

  private func updateStatusItemTitle() {
    guard let button = statusItem?.button else { return }

    let title = generateStatusTitle()
    button.title = title

    // Update tooltip with full information
    button.toolTip = generateTooltip()
  }

  private func generateStatusTitle() -> String {
    if mediaService.isLoading {
      return "♪ Loading..."
    } else if let error = mediaService.lastError {
      return "♪ Error"
    } else if mediaService.hasValidMedia {
      let truncatedText = mediaService.currentMedia.truncatedMenuBarText
      return "♪ \(truncatedText)"
    } else {
      return "♪ No Media"
    }
  }

  private func generateTooltip() -> String {
    if mediaService.isLoading {
      return "SwiftMediaBar - Loading media information..."
    } else if let error = mediaService.lastError {
      return "SwiftMediaBar - Error: \(error)"
    } else if mediaService.hasValidMedia {
      let media = mediaService.currentMedia
      var tooltip = "SwiftMediaBar\n"
      tooltip += "Title: \(media.displayTitle)\n"
      tooltip += "Artist: \(media.displayArtist)\n"
      tooltip += "Album: \(media.displayAlbum)\n"

      if media.isPlaying {
        tooltip += "Status: Playing"
        // if let elapsed = media.elapsedTime, let duration = media.duration {
        //   tooltip += " (\(media.formattedElapsedTime) / \(media.formattedDuration))"
        // }
      } else {
        tooltip += "Status: Paused"
      }

      return tooltip
    } else {
      return "SwiftMediaBar - No media currently playing"
    }
  }

  // MARK: - Public Methods

  func refreshMedia() {
    mediaService.fetchCurrentMedia()
  }

  func startMonitoring() {
    mediaService.startPeriodicUpdates()
  }

  func stopMonitoring() {
    mediaService.stopPeriodicUpdates()
  }

  // MARK: - Cleanup

  private func cleanup() {
    popover?.performClose(nil)
    popover = nil

    if let statusItem = statusItem {
      NSStatusBar.system.removeStatusItem(statusItem)
    }
    statusItem = nil

    cancellables.removeAll()
    mediaService.stopPeriodicUpdates()
  }
}

// MARK: - App Lifecycle Support

extension MenuBarManager {
  func applicationDidFinishLaunching() {
    startMonitoring()

    // Initial update
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.refreshMedia()
    }
  }

  func applicationWillTerminate() {
    cleanup()
  }
}

// MARK: - Menu Bar Utilities

extension MenuBarManager {
  static func hideFromDock() {
    // This will be called from the app delegate to hide the app from dock
    NSApp.setActivationPolicy(.accessory)
  }

  static func showInDock() {
    // This can be used to show the app in dock if needed
    NSApp.setActivationPolicy(.regular)
  }
}
