//
//  MediaService.swift
//  SwiftMediaBar
//
//  Created by Philipp Bischoff on 29.09.25.
//

import Combine
import Foundation

class MediaService: ObservableObject {
  @Published var currentMedia: MediaInfo = .empty
  @Published var isLoading: Bool = false
  @Published var lastError: String?

  private var timer: Timer?
  private let updateInterval: TimeInterval = 5.0

  init() {
    startPeriodicUpdates()
  }

  deinit {
    stopPeriodicUpdates()
  }

  // MARK: - Public Methods

  func startPeriodicUpdates() {
    stopPeriodicUpdates()

    // Get initial data immediately
    fetchCurrentMedia()

    // Set up timer for periodic updates
    timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
      self?.fetchCurrentMedia()
    }
  }

  func stopPeriodicUpdates() {
    timer?.invalidate()
    timer = nil
  }

  func fetchCurrentMedia() {
    guard !isLoading else { return }

    // Only show loading state if we don't have any media data yet
    let shouldShowLoading = currentMedia == .empty && lastError == nil
    if shouldShowLoading {
      isLoading = true
    }

    Task {
      do {
        let mediaInfo = try await executeMediaControlCommand()
        await MainActor.run {
          // Only update if the media info has actually changed
          if self.currentMedia != mediaInfo {
            #if DEBUG
              print("📱 MediaService: Media info changed, updating UI")
              print(
                "   Previous: \(self.currentMedia.displayTitle) - \(self.currentMedia.displayArtist)"
              )
              print("   New: \(mediaInfo.displayTitle) - \(mediaInfo.displayArtist)")
            #endif
            self.currentMedia = mediaInfo
            // Clear error only if we had one and now have valid data
            if self.lastError != nil {
              self.lastError = nil
            }
          } else {
            #if DEBUG
              print("📱 MediaService: Media info unchanged, skipping UI update")
            #endif
          }

          // Only update loading state if we were showing it
          if shouldShowLoading {
            self.isLoading = false
          }
        }
      } catch {
        await MainActor.run {
          let errorMessage = error.localizedDescription
          // Only update if the error message has changed or current media is not empty
          if self.lastError != errorMessage || self.currentMedia != .empty {
            #if DEBUG
              print("📱 MediaService: Error occurred, updating error state")
            #endif
            self.lastError = errorMessage
            self.currentMedia = .empty
          }

          // Only update loading state if we were showing it
          if shouldShowLoading {
            self.isLoading = false
          }
        }
      }
    }
  }

  // MARK: - Private Methods

  private func executeMediaControlCommand() async throws -> MediaInfo {
    return try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      let pipe = Pipe()

      process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/media-control")
      process.arguments = ["get"]
      process.standardOutput = pipe
      process.standardError = pipe

      do {
        try process.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
          // Success - parse JSON
          do {
            let mediaInfo = try parseMediaInfo(from: data)
            continuation.resume(returning: mediaInfo)
          } catch {
            continuation.resume(
              throwing: MediaServiceError.jsonParsingFailed(error.localizedDescription))
          }
        } else {
          // Command failed
          let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
          continuation.resume(throwing: MediaServiceError.commandFailed(errorString))
        }
      } catch {
        continuation.resume(
          throwing: MediaServiceError.commandExecutionFailed(error.localizedDescription))
      }
    }
  }

  private func parseMediaInfo(from data: Data) throws -> MediaInfo {
    guard !data.isEmpty else {
      throw MediaServiceError.emptyResponse
    }

    // Try to parse as JSON
    do {
      let decoder = JSONDecoder()
      let mediaInfo = try decoder.decode(MediaInfo.self, from: data)
      return mediaInfo
    } catch {
      // If JSON parsing fails, check if it's a "No media playing" message
      if let responseString = String(data: data, encoding: .utf8),
        responseString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().contains(
          "no media")
      {
        return .empty
      }
      throw error
    }
  }
}

// MARK: - Error Types

enum MediaServiceError: LocalizedError {
  case commandExecutionFailed(String)
  case commandFailed(String)
  case jsonParsingFailed(String)
  case emptyResponse
  case mediaControlNotFound

  var errorDescription: String? {
    switch self {
    case .commandExecutionFailed(let message):
      return "Failed to execute media-control command: \(message)"
    case .commandFailed(let message):
      return "media-control command failed: \(message)"
    case .jsonParsingFailed(let message):
      return "Failed to parse media information: \(message)"
    case .emptyResponse:
      return "No response from media-control command"
    case .mediaControlNotFound:
      return "media-control command not found. Please ensure it's installed and in your PATH."
    }
  }
}

// MARK: - Extensions

extension MediaService {
  var hasValidMedia: Bool {
    return currentMedia.title != nil && currentMedia.title != "No Media Playing"
      && currentMedia.isPlaying
  }

  var statusText: String {
    if isLoading {
      return "Loading..."
    } else if let error = lastError {
      return "Error: \(error)"
    } else if hasValidMedia {
      return currentMedia.truncatedMenuBarText
    } else {
      return "No Media Playing"
    }
  }
}
