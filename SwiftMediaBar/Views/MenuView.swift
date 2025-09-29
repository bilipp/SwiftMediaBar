//
//  MenuView.swift
//  SwiftMediaBar
//
//  Created by Philipp Bischoff on 29.09.25.
//

import AppKit
import SwiftUI

struct MenuView: View {
  @ObservedObject var mediaService: MediaService

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if mediaService.isLoading {
        loadingView
      } else if let error = mediaService.lastError {
        errorView(error: error)
      } else if mediaService.hasValidMedia {
        mediaInfoView
      } else {
        noMediaView
      }

      Divider()

      quitButton
    }
    .padding(16)
    .frame(width: 300)
  }

  // MARK: - Loading View

  private var loadingView: some View {
    HStack {
      ProgressView()
        .scaleEffect(0.8)
      Text("Loading media information...")
        .font(.system(size: 13))
        .foregroundColor(.secondary)
    }
    .frame(height: 40)
  }

  // MARK: - Error View

  private func errorView(error: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "exclamationmark.triangle")
          .foregroundColor(.orange)
        Text("Error")
          .font(.headline)
          .foregroundColor(.orange)
      }

      Text(error)
        .font(.system(size: 12))
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(height: 60)
  }

  // MARK: - No Media View

  private var noMediaView: some View {
    VStack(spacing: 8) {
      Image(systemName: "music.note")
        .font(.system(size: 24))
        .foregroundColor(.secondary)

      Text("No Media Playing")
        .font(.headline)
        .foregroundColor(.secondary)

      Text("Start playing music to see details here")
        .font(.system(size: 12))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(height: 80)
  }

  // MARK: - Media Info View

  private var mediaInfoView: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Album artwork and basic info
      HStack(alignment: .top, spacing: 12) {
        albumArtworkView

        VStack(alignment: .leading, spacing: 4) {
          Text(mediaService.currentMedia.displayTitle)
            .font(.headline)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)

          Text(mediaService.currentMedia.displayArtist)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)

          Text(mediaService.currentMedia.displayAlbum)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
        }

        Spacer()
      }

      // Playback progress
      // playbackProgressView - temporary disabled as media-control has a wrong elapsed time

      // Additional metadata
      metadataView
    }
  }

  // MARK: - Album Artwork

  private var albumArtworkView: some View {
    Group {
      if let artworkImage = loadArtworkImage() {
        Image(nsImage: artworkImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      } else {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.secondary.opacity(0.3))
          .frame(width: 60, height: 60)
          .overlay(
            Image(systemName: "music.note")
              .font(.system(size: 20))
              .foregroundColor(.secondary)
          )
      }
    }
  }

  // MARK: - Playback Progress

  private var playbackProgressView: some View {
    VStack(spacing: 4) {
      HStack {
        Text(mediaService.currentMedia.formattedElapsedTime)
          .font(.caption)
          .foregroundColor(.secondary)

        Spacer()

        playbackStatusIcon

        Spacer()

        Text(mediaService.currentMedia.formattedDuration)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      ProgressView(value: mediaService.currentMedia.progressPercentage)
        .progressViewStyle(LinearProgressViewStyle())
        .frame(height: 4)
    }
  }

  private var playbackStatusIcon: some View {
    Image(systemName: mediaService.currentMedia.isPlaying ? "play.fill" : "pause.fill")
      .font(.system(size: 10))
      .foregroundColor(mediaService.currentMedia.isPlaying ? .green : .orange)
  }

  // MARK: - Metadata

  private var metadataView: some View {
    VStack(alignment: .leading, spacing: 2) {
      if let genre = mediaService.currentMedia.genre {
        metadataRow(label: "Genre", value: genre)
      }

      if let trackNumber = mediaService.currentMedia.trackNumber {
        metadataRow(label: "Track", value: "\(trackNumber)")
      }

      if let bundleIdentifier = mediaService.currentMedia.bundleIdentifier {
        let appName =
          bundleIdentifier.components(separatedBy: ".").last?.capitalized ?? bundleIdentifier
        metadataRow(label: "Source", value: appName)
      }
    }
  }

  private func metadataRow(label: String, value: String) -> some View {
    HStack {
      Text("\(label):")
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 50, alignment: .leading)

      Text(value)
        .font(.caption)
        .lineLimit(1)
    }
  }

  // MARK: - Quit Button

  private var quitButton: some View {
    Button(action: {
      NSApplication.shared.terminate(nil)
    }) {
      HStack {
        Image(systemName: "power")
        Text("Quit SwiftMediaBar")
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.small)
  }

  // MARK: - Helper Methods

  private func loadArtworkImage() -> NSImage? {
    guard let artworkData = mediaService.currentMedia.artworkData,
      !artworkData.isEmpty
    else {
      return nil
    }

    // Handle base64 encoded image data
    let cleanedData = artworkData.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
      .replacingOccurrences(of: "data:image/png;base64,", with: "")

    guard let imageData = Data(base64Encoded: cleanedData) else {
      return nil
    }

    return NSImage(data: imageData)
  }
}

// MARK: - Preview

#Preview {
  MenuView(
    mediaService: {
      let service = MediaService()
      // Mock data for preview
      service.currentMedia = MediaInfo(
        composer: "Karl Schumann, Konrad Betcher & Flo August",
        title: "Wenn ich tot bin, fang ich wieder an",
        duration: 176.57,
        artworkData: nil,
        bundleIdentifier: "com.apple.Music",
        uniqueIdentifier: 1_830_505_417,
        contentItemIdentifier: "27033::27040",
        isMusicApp: true,
        elapsedTime: 45.0,
        queueIndex: 1,
        artworkMimeType: "image/jpeg",
        mediaType: "MRMediaRemoteMediaTypeMusic",
        playing: true,
        timestamp: "2025-09-29T11:39:53Z",
        artist: "Kraftklub",
        trackNumber: 1,
        processIdentifier: 1591,
        genre: "Rock",
        totalQueueCount: 24,
        album: "Wenn ich tot bin, fang ich wieder an - Single",
        playbackRate: 1
      )
      return service
    }())
}
