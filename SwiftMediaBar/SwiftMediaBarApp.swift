//
//  SwiftMediaBarApp.swift
//  SwiftMediaBar
//
//  Created by Philipp Bischoff on 29.09.25.
//

import AppKit
import SwiftUI

@main
struct SwiftMediaBarApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  private var menuBarManager: MenuBarManager?

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Hide from dock and disable window creation
    MenuBarManager.hideFromDock()

    // Initialize menu bar manager
    menuBarManager = MenuBarManager()
    menuBarManager?.applicationDidFinishLaunching()

    // Prevent the app from terminating when the last window is closed
    NSApp.setActivationPolicy(.accessory)
  }

  func applicationWillTerminate(_ notification: Notification) {
    menuBarManager?.applicationWillTerminate()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // Don't terminate when windows are closed - we're a menu bar app
    return false
  }
}
