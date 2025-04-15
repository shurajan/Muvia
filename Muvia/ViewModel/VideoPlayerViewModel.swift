//
//  VideoPlayerViewModel.swift
//  Muvia
//
//  Created by Alexander Bralnin on 15.04.2025.
//

import SwiftUI
import Foundation
import AVKit
import Combine

final class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var showCloseButton = true
    @Published var errorMessage: String?

    let url: URL
    let token: String

    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var autoHideCancellable: AnyCancellable?

    private let resumeKey: String

    init(url: URL, token: String) {
        self.url = url
        self.token = token
        self.resumeKey = "resume_\(url.absoluteString)"
        loadPlayer()
    }

    private func loadPlayer() {
        Task {
            do {
                let headers = ["Authorization": token]
                let options = ["AVURLAssetHTTPHeaderFieldsKey": headers]
                let asset = AVURLAsset(url: url, options: options)
                async let isPlayable = asset.load(.isPlayable)
                _ = try await isPlayable

                let item = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: item)
                player.allowsExternalPlayback = false
                player.usesExternalPlaybackWhileExternalScreenIsActive = false

                await MainActor.run {
                    self.player = player
                    self.observePlayerStatus()
                    self.observeProgress()
                    self.seekToSavedPosition()
                    player.play()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func observePlayerStatus() {
        guard let player = player else { return }

        player.publisher(for: \AVPlayer.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }

                switch status {
                case .paused:
                    withAnimation { self.showCloseButton = true }
                    self.autoHideCancellable?.cancel()
                case .playing:
                    self.scheduleAutoHide()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func scheduleAutoHide() {
        autoHideCancellable?.cancel()

        autoHideCancellable = Just(())
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, self.player?.timeControlStatus == .playing else { return }
                withAnimation { self.showCloseButton = false }
            }
    }

    private func observeProgress() {
        guard let player  else { return }

        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 2, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = CMTimeGetSeconds(time)
            UserDefaults.standard.set(seconds, forKey: self.resumeKey)
        }
    }

    private func seekToSavedPosition() {
        guard let player else { return }
        let seconds = UserDefaults.standard.double(forKey: resumeKey)
        guard seconds > 3 else { return }
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: time)
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        cancellables.forEach { $0.cancel() }
        autoHideCancellable?.cancel()
    }
}
