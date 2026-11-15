import AVFoundation
import Foundation
import MediaPlayer
import Observation

@MainActor
@Observable
final class PolonaisePlayer {
    private let player = AVPlayer()
    private var progressTask: Task<Void, Never>?
    private var completionTask: Task<Void, Never>?
    private var queue = PolonaiseCatalog.chapters.sorted { $0.year < $1.year }
    private var savedPositions: [String: TimeInterval]
    private var lastSavedSecond = -1

    private(set) var currentChapter: PolonaiseChapter?
    private(set) var isPlaying = false
    private(set) var isBuffering = false
    private(set) var elapsed: TimeInterval = 0
    private(set) var errorMessage: String?
    var isContinuousPlaybackEnabled = true

    private static let positionsKey = "polonaisePlaybackPositions"
    private static let lastChapterKey = "lastPlayedPolonaiseChapterID"

    init() {
        savedPositions = UserDefaults.standard.dictionary(forKey: Self.positionsKey) as? [String: Double] ?? [:]
        configureAudioSession()
        observeCompletion()
        configureRemoteCommands()
    }

    var duration: TimeInterval {
        currentChapter?.duration ?? 1
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(elapsed / duration, 0), 1)
    }

    var hasPrevious: Bool {
        guard let currentChapter,
              let index = queue.firstIndex(where: { $0.id == currentChapter.id }) else {
            return false
        }
        return index > 0 || elapsed > 5
    }

    var hasNext: Bool {
        guard let currentChapter,
              let index = queue.firstIndex(where: { $0.id == currentChapter.id }) else {
            return false
        }
        return index < queue.count - 1
    }

    func play(_ chapter: PolonaiseChapter) {
        if !queue.contains(where: { $0.id == chapter.id }) {
            queue = PolonaiseCatalog.chapters.sorted { $0.year < $1.year }
        }
        start(chapter)
    }

    func playQueue(_ chapters: [PolonaiseChapter], startingAt chapter: PolonaiseChapter? = nil) {
        guard !chapters.isEmpty else { return }
        queue = chapters
        start(chapter ?? chapters[0])
    }

    func togglePlayback() {
        guard currentChapter != nil else { return }

        if isPlaying {
            player.pause()
            saveCurrentPosition()
        } else {
            activateAudioSession()
            player.play()
            startProgressMonitoring()
        }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    func playPrevious() {
        guard let currentChapter else { return }

        if elapsed > 5 {
            seek(to: 0)
            return
        }

        guard let index = queue.firstIndex(where: { $0.id == currentChapter.id }),
              index > 0 else { return }
        start(queue[index - 1])
    }

    func playNext() {
        guard let currentChapter,
              let index = queue.firstIndex(where: { $0.id == currentChapter.id }),
              index < queue.count - 1 else { return }
        start(queue[index + 1])
    }

    func skip(by seconds: TimeInterval) {
        seek(to: elapsed + seconds)
    }

    func seek(to seconds: TimeInterval) {
        let target = min(max(seconds, 0), duration)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        elapsed = target
        saveCurrentPosition()
        updateNowPlayingInfo()
    }

    func retry() {
        guard let currentChapter else { return }
        start(currentChapter)
    }

    private func start(_ chapter: PolonaiseChapter) {
        guard let url = chapter.audioURL else {
            errorMessage = "找不到音訊網址。"
            return
        }

        saveCurrentPosition()
        activateAudioSession()
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        currentChapter = chapter
        elapsed = 0
        errorMessage = nil
        isBuffering = true
        lastSavedSecond = -1

        player.play()
        isPlaying = true
        UserDefaults.standard.set(chapter.id, forKey: Self.lastChapterKey)
        startProgressMonitoring()
        updateNowPlayingInfo()
    }

    private func restoreLastChapter() {
        guard let id = UserDefaults.standard.string(forKey: Self.lastChapterKey),
              let chapter = PolonaiseCatalog.chapters.first(where: { $0.id == id }) else {
            return
        }
        currentChapter = chapter
        elapsed = savedPositions[id] ?? 0
        updateNowPlayingInfo()
    }

    private func startProgressMonitoring() {
        progressTask?.cancel()
        progressTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(400))
                guard let self else { return }

                let currentTime = player.currentTime().seconds
                elapsed = currentTime.isFinite ? currentTime : 0
                isBuffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate

                if player.currentItem?.status == .failed {
                    errorMessage = "音訊載入失敗，請檢查網路後重試。"
                    isPlaying = false
                    isBuffering = false
                    return
                }

                let wholeSecond = Int(elapsed)
                if wholeSecond != lastSavedSecond, wholeSecond.isMultiple(of: 2) {
                    lastSavedSecond = wholeSecond
                    saveCurrentPosition()
                    updateNowPlayingInfo()
                }
            }
        }
    }

    private func observeCompletion() {
        completionTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: AVPlayerItem.didPlayToEndTimeNotification
            ) {
                guard let self else { return }
                savedPositions[currentChapter?.id ?? ""] = 0
                if isContinuousPlaybackEnabled, hasNext {
                    playNext()
                } else {
                    isPlaying = false
                    elapsed = duration
                    updateNowPlayingInfo()
                }
            }
        }
    }

    private func saveCurrentPosition() {
        guard let currentChapter else { return }
        savedPositions[currentChapter.id] = elapsed
        UserDefaults.standard.set(savedPositions, forKey: Self.positionsKey)
    }

    private func configureAudioSession() {
#if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            errorMessage = "無法設定背景播放。"
        }
#endif
    }

    private func activateAudioSession() {
#if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(true)
#endif
    }

    private func configureRemoteCommands() {
        let commands = MPRemoteCommandCenter.shared()

        commands.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if !self.isPlaying { self.togglePlayback() }
            }
            return .success
        }

        commands.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.isPlaying { self.togglePlayback() }
            }
            return .success
        }

        commands.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.playNext() }
            return .success
        }

        commands.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.playPrevious() }
            return .success
        }

        commands.skipForwardCommand.preferredIntervals = [15]
        commands.skipForwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skip(by: 15) }
            return .success
        }

        commands.skipBackwardCommand.preferredIntervals = [15]
        commands.skipBackwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skip(by: -15) }
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let currentChapter else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentChapter.title,
            MPMediaItemPropertyArtist: "Fryderyk Chopin",
            MPMediaItemPropertyAlbumTitle: "波蘭舞曲有聲電子書",
            MPMediaItemPropertyPlaybackDuration: currentChapter.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }
}
