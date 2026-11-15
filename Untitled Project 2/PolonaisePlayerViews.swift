import SwiftUI

struct MiniPlayerBar: View {
    let chapter: PolonaiseChapter
    let player: PolonaisePlayer

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "pianokeys")
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(ChopinTheme.burgundy, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(chapter.title)
                    .font(.biauKai(.subheadline, weight: .bold))
                    .lineLimit(1)
                Text(chapter.catalog)
                    .font(.biauKai(.caption2))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 2)

            MiniTransportControls(player: player)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            ProgressView(value: player.progress)
                .tint(ChopinTheme.burgundy)
                .controlSize(.mini)
                .padding(.horizontal, 12)
                .accessibilityLabel("播放進度")
                .accessibilityValue("\(Int(player.progress * 100))％")
        }
    }
}

struct MiniTransportControls: View {
    let player: PolonaisePlayer

    var body: some View {
        HStack(spacing: 10) {
            Button {
                player.playPrevious()
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .disabled(!player.hasPrevious)
            .accessibilityLabel("上一首")

            Button {
                player.togglePlayback()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(ChopinTheme.burgundy, in: Circle())
                    .contentShape(Circle())
                    .offset(x: player.isPlaying ? 0 : 0.5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(player.isPlaying ? "暫停" : "播放")
            .accessibilityAddTraits(.startsMediaSession)

            Button {
                player.playNext()
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .disabled(!player.hasNext)
            .accessibilityLabel("下一首")
        }
    }
}

struct PolonaisePlayerCard: View {
    let chapter: PolonaiseChapter
    let player: PolonaisePlayer

    private var isCurrent: Bool {
        player.currentChapter?.id == chapter.id
    }

    var body: some View {
        VStack(spacing: 18) {
            PlayerStatusHeader(
                isCurrent: isCurrent,
                isPlaying: player.isPlaying,
                isBuffering: isCurrent && player.isBuffering,
                elapsed: isCurrent ? player.elapsed : 0
            )

            ProgressView(
                value: isCurrent ? player.elapsed : 0,
                total: max(chapter.duration, 1)
            )
            .tint(ChopinTheme.burgundy)
            .accessibilityLabel("播放進度")
            .accessibilityValue("\(Int((isCurrent ? player.progress : 0) * 100))％")

            PlayerTransportControls(
                chapter: chapter,
                player: player,
                isCurrent: isCurrent
            )

            if isCurrent, let errorMessage = player.errorMessage {
                PlayerErrorMessage(message: errorMessage, retry: player.retry)
            }

            Toggle("播完自動播放下一首", isOn: Bindable(player).isContinuousPlaybackEnabled)
                .font(.biauKai(.subheadline))
        }
        .archiveCard()
    }
}

struct PlayerStatusHeader: View {
    let isCurrent: Bool
    let isPlaying: Bool
    let isBuffering: Bool
    let elapsed: TimeInterval

    var body: some View {
        HStack {
            Image(systemName: isBuffering ? "hourglass" : "waveform")
                .symbolEffect(.variableColor.iterative, isActive: isCurrent && isPlaying)
                .accessibilityHidden(true)

            Text(statusText)
                .font(.biauKai(.caption, weight: .bold))
                .tracking(1.2)

            Spacer()

            Text(timeText)
                .font(.biauKai(.caption))
                .accessibilityLabel("已播放時間")
        }
    }

    private var timeText: String {
        let total = max(Int(elapsed), 0)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }

    private var statusText: String {
        if isBuffering { return "正在載入音訊" }
        if isCurrent && isPlaying { return "正在播放" }
        if isCurrent { return "已暫停" }
        return "有聲章節"
    }
}

struct PlayerTransportControls: View {
    let chapter: PolonaiseChapter
    let player: PolonaisePlayer
    let isCurrent: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 26) {
                controls
            }

            VStack(spacing: 18) {
                HStack(spacing: 28) {
                    previousButton
                    playButton
                    nextButton
                }
                HStack(spacing: 44) {
                    backwardButton
                    forwardButton
                }
            }
        }
        .foregroundStyle(ChopinTheme.burgundy)
    }

    @ViewBuilder
    private var controls: some View {
        previousButton
        backwardButton
        playButton
        forwardButton
        nextButton
    }

    private var previousButton: some View {
        Button {
            player.playPrevious()
        } label: {
            Image(systemName: "backward.end.fill")
                .font(.title3)
        }
        .disabled(!isCurrent || !player.hasPrevious)
        .accessibilityLabel("上一首")
    }

    private var backwardButton: some View {
        Button {
            player.skip(by: -15)
        } label: {
            Image(systemName: "gobackward.15")
                .font(.title2)
        }
        .disabled(!isCurrent)
        .accessibilityLabel("倒轉十五秒")
    }

    private var playButton: some View {
        Button {
            player.play(chapter)
        } label: {
            Image(systemName: isCurrent && player.isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 66, height: 66)
                .background(ChopinTheme.burgundy, in: Circle())
                .shadow(color: ChopinTheme.burgundy.opacity(0.25), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCurrent && player.isPlaying ? "暫停" : "播放")
        .accessibilityAddTraits(.startsMediaSession)
    }

    private var forwardButton: some View {
        Button {
            player.skip(by: 15)
        } label: {
            Image(systemName: "goforward.15")
                .font(.title2)
        }
        .disabled(!isCurrent)
        .accessibilityLabel("快轉十五秒")
    }

    private var nextButton: some View {
        Button {
            player.playNext()
        } label: {
            Image(systemName: "forward.end.fill")
                .font(.title3)
        }
        .disabled(!isCurrent || !player.hasNext)
        .accessibilityLabel("下一首")
    }
}

struct PlayerErrorMessage: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.biauKai(.caption))
                .foregroundStyle(ChopinTheme.burgundy)
                .multilineTextAlignment(.center)

            Button("重新載入音訊", action: retry)
                .buttonStyle(.bordered)
                .tint(ChopinTheme.burgundy)
        }
    }
}
