//
//  SwiftMediaBarTests.swift
//  SwiftMediaBarTests
//
//  Created by Philipp Bischoff on 29.09.25.
//

import Foundation
import Testing
@testable import SwiftMediaBar

@MainActor
struct SwiftMediaBarTests {
  @Test(arguments: [#"{"playing":false,"status":"stopped or not running"}"#, "null", ""])
  func showsMediaControlTrackWhenAppleScriptReportsNoPlayer(appleScriptOutput: String) async throws {
    let service = try await loadMedia(appleScriptOutput: appleScriptOutput)

    #expect(service.currentMedia.title == "Example Song")
    #expect(service.currentMedia.artist == "Example Artist")
    #expect(service.currentMedia.bundleIdentifier == "com.monk-studio.jellyfin-music")
    #expect(service.hasValidMedia)
    #expect(service.lastError == nil)
  }

  @Test func staysIdleWithoutOptionalMediaControl() async throws {
    let service = try await loadMedia(
      appleScriptOutput: #"{"playing":false,"status":"stopped or not running"}"#,
      mediaControlOutput: nil
    )

    #expect(!service.hasValidMedia)
    #expect(service.lastError == nil)
  }

  @Test(arguments: [true, false])
  func preservesAppleScriptTrack(playing: Bool) async throws {
    let service = try await loadMedia(
      appleScriptOutput: "{\"title\":\"Native track\",\"playing\":\(playing)}"
    )

    #expect(service.currentMedia.title == "Native track")
    #expect(service.currentMedia.isPlaying == playing)
    #expect(service.lastError == nil)
  }

  @Test func fallsBackWhenAppleScriptFails() async throws {
    let service = try await loadMedia(
      appleScriptOutput: "Not authorised to send Apple events",
      appleScriptExitStatus: 1
    )

    #expect(service.currentMedia.title == "Example Song")
    #expect(service.hasValidMedia)
    #expect(service.lastError == nil)
  }

  @Test func staysIdleWhenNeitherSourceHasMedia() async throws {
    let service = try await loadMedia(
      appleScriptOutput: #"{"playing":false,"status":"stopped or not running"}"#,
      mediaControlOutput: "null"
    )

    #expect(!service.hasValidMedia)
    #expect(service.lastError == nil)
  }

  @Test func reportsMediaControlFailure() async throws {
    let service = try await loadMedia(
      appleScriptOutput: #"{"playing":false,"status":"stopped or not running"}"#,
      mediaControlOutput: "Media monitoring unavailable",
      mediaControlExitStatus: 1
    )

    #expect(!service.hasValidMedia)
    #expect(service.lastError?.contains("Media monitoring unavailable") == true)
  }

  @Test(arguments: ["null", ""])
  func clearsHelperErrorAfterSuccessfulIdlePoll(output: String) async throws {
    let service = try await loadMedia(
      appleScriptOutput: #"{"playing":false,"status":"stopped or not running"}"#,
      mediaControlOutput: "Media monitoring unavailable",
      mediaControlExitStatus: 1,
      afterInitialFetch: { service, mediaControlURL in
        try #require(service.lastError?.contains("Media monitoring unavailable") == true)
        try #require(service.currentMedia == .empty)
        try writeCommand(at: mediaControlURL, output: output, exitStatus: 0)

        service.fetchCurrentMedia()
        for _ in 0..<200 {
          if service.lastError == nil { break }
          try await Task.sleep(for: .milliseconds(10))
        }
      }
    )

    #expect(service.lastError == nil)
    #expect(service.currentMedia == .empty)
    #expect(service.statusText == "No Media Playing")
  }

  private func loadMedia(
    appleScriptOutput: String,
    appleScriptExitStatus: Int = 0,
    mediaControlOutput: String? = #"{"title":"Example Song","artist":"Example Artist","bundleIdentifier":"com.monk-studio.jellyfin-music","playing":true}"#,
    mediaControlExitStatus: Int = 0,
    afterInitialFetch: ((MediaService, URL) async throws -> Void)? = nil
  ) async throws -> MediaService {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer {
      do {
        try FileManager.default.removeItem(at: directory)
      } catch {
        Issue.record(error)
      }
    }

    let osascriptURL = directory.appendingPathComponent("osascript")
    let mediaControlURL = directory.appendingPathComponent("media-control")
    try writeCommand(at: osascriptURL, output: appleScriptOutput, exitStatus: appleScriptExitStatus)
    if let mediaControlOutput {
      try writeCommand(at: mediaControlURL, output: mediaControlOutput, exitStatus: mediaControlExitStatus)
    }

    let service = MediaService(osascriptURL: osascriptURL, mediaControlURL: mediaControlURL)
    service.stopPeriodicUpdates()
    for _ in 0..<200 {
      if !service.isLoading { break }
      try await Task.sleep(for: .milliseconds(10))
    }
    try #require(!service.isLoading, "Media fetch did not finish within two seconds")
    try await afterInitialFetch?(service, mediaControlURL)
    return service
  }

  private func writeCommand(at url: URL, output: String, exitStatus: Int) throws {
    let escapedOutput = output.replacingOccurrences(of: "'", with: "'\"'\"'")
    let script = "#!/bin/sh\nprintf '%s' '\(escapedOutput)'\nexit \(exitStatus)\n"
    try script.write(to: url, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
  }
}
