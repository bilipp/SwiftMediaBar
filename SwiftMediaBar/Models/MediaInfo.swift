//
//  MediaInfo.swift
//  SwiftMediaBar
//
//  Created by Philipp Bischoff on 29.09.25.
//

import Foundation

struct MediaInfo: Codable, Equatable {
  let composer: String?
  let title: String?
  let duration: Double?
  let artworkData: String?
  let bundleIdentifier: String?
  let uniqueIdentifier: Int?
  let contentItemIdentifier: String?
  let isMusicApp: Bool?
  let elapsedTime: Double?
  let queueIndex: Int?
  let artworkMimeType: String?
  let mediaType: String?
  let playing: Bool?
  let timestamp: String?
  let artist: String?
  let trackNumber: Int?
  let processIdentifier: Int?
  let genre: String?
  let totalQueueCount: Int?
  let album: String?
  let playbackRate: Double?

  // Computed properties for display
  var displayTitle: String {
    return title ?? "Unknown Title"
  }

  var displayArtist: String {
    return artist ?? "Unknown Artist"
  }

  var displayAlbum: String {
    return album ?? "Unknown Album"
  }

  var menuBarText: String {
    return "\(displayArtist) - \(displayTitle)"
  }

  var truncatedMenuBarText: String {
    let maxLength = 50
    let text = menuBarText
    if text.count > maxLength {
      return String(text.prefix(maxLength - 3)) + "..."
    }
    return text
  }

  var formattedDuration: String {
    guard let duration = duration else { return "0:00" }
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }

  var formattedElapsedTime: String {
    guard let elapsedTime = elapsedTime else { return "0:00" }
    let minutes = Int(elapsedTime) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }

  var progressPercentage: Double {
    guard let duration = duration, let elapsedTime = elapsedTime, duration > 0 else { return 0.0 }
    return min(elapsedTime / duration, 1.0)
  }

  var isPlaying: Bool {
    return playing ?? false
  }

  var hasArtwork: Bool {
    return artworkData != nil && !artworkData!.isEmpty
  }

  // MARK: - Equatable Implementation

  static func == (lhs: MediaInfo, rhs: MediaInfo) -> Bool {
    return lhs.composer == rhs.composer && lhs.title == rhs.title && lhs.duration == rhs.duration
      && lhs.artworkData == rhs.artworkData && lhs.bundleIdentifier == rhs.bundleIdentifier
      && lhs.uniqueIdentifier == rhs.uniqueIdentifier
      && lhs.contentItemIdentifier == rhs.contentItemIdentifier && lhs.isMusicApp == rhs.isMusicApp
      && lhs.elapsedTime == rhs.elapsedTime && lhs.queueIndex == rhs.queueIndex
      && lhs.artworkMimeType == rhs.artworkMimeType && lhs.mediaType == rhs.mediaType
      && lhs.playing == rhs.playing && lhs.timestamp == rhs.timestamp && lhs.artist == rhs.artist
      && lhs.trackNumber == rhs.trackNumber && lhs.processIdentifier == rhs.processIdentifier
      && lhs.genre == rhs.genre && lhs.totalQueueCount == rhs.totalQueueCount
      && lhs.album == rhs.album && lhs.playbackRate == rhs.playbackRate
  }
}

// Extension for handling empty or error states
extension MediaInfo {
  static let empty = MediaInfo(
    composer: nil,
    title: "No Media Playing",
    duration: nil,
    artworkData: nil,
    bundleIdentifier: nil,
    uniqueIdentifier: nil,
    contentItemIdentifier: nil,
    isMusicApp: nil,
    elapsedTime: nil,
    queueIndex: nil,
    artworkMimeType: nil,
    mediaType: nil,
    playing: false,
    timestamp: nil,
    artist: "SwiftMediaBar",
    trackNumber: nil,
    processIdentifier: nil,
    genre: nil,
    totalQueueCount: nil,
    album: nil,
    playbackRate: nil
  )
}
