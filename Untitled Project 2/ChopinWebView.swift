import AVKit
import SwiftUI
import WebKit

struct ChopinWebView: View {
    @Environment(\.openURL) private var openURL
    @State private var page = WebPage()
    @State private var isStarting = true
    @State private var errorMessage: String?

    private let websiteURL = URL(string: "https://chopin.nifc.pl/en/chopin/kompozycje")

    var body: some View {
        NavigationStack {
            ZStack {
                WebView(page)
                    .webViewBackForwardNavigationGestures(.enabled)

                if isStarting || page.isLoading {
                    WebsiteLoadingView(progress: page.estimatedProgress)
                }

                if let errorMessage {
                    WebsiteErrorView(
                        message: errorMessage,
                        retry: loadWebsite,
                        openInSafari: openInSafari
                    )
                }
            }
            .background(ChopinTheme.paper)
            .navigationTitle("蕭邦作品網站")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if page.url == nil {
                    await loadWebsite()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("重新載入", systemImage: "arrow.clockwise") {
                        Task {
                            await loadWebsite()
                        }
                    }
                }
            }
        }
    }

    @MainActor
    private func loadWebsite() async {
        guard let websiteURL else {
            errorMessage = "官方網站網址無效。"
            isStarting = false
            return
        }

        errorMessage = nil
        isStarting = true

        do {
            for try await _ in page.load(websiteURL) {}
            isStarting = false
        } catch is CancellationError {
            isStarting = false
        } catch {
            errorMessage = "目前無法連上蕭邦研究院網站，請檢查網路後重試。"
            isStarting = false
        }
    }

    private func loadWebsite() {
        Task {
            await loadWebsite()
        }
    }

    private func openInSafari() {
        guard let websiteURL else { return }
        openURL(websiteURL)
    }
}

struct WebsiteLoadingView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 220)

            Text("正在連線至蕭邦研究院…")
                .font(.biauKai(.subheadline, weight: .medium))
                .foregroundStyle(ChopinTheme.ink)
        }
        .padding(28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct WebsiteErrorView: View {
    let message: String
    let retry: () -> Void
    let openInSafari: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(ChopinTheme.burgundy)

            Text("網頁載入失敗")
                .font(.biauKai(.title3, weight: .bold))
                .foregroundStyle(ChopinTheme.ink)

            Text(message)
                .font(.biauKai(.subheadline))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button("重新載入", action: retry)
                    .buttonStyle(.borderedProminent)
                    .tint(ChopinTheme.burgundy)

                Button("用 Safari 開啟", action: openInSafari)
                    .buttonStyle(.bordered)
            }
        }
        .padding(28)
        .frame(maxWidth: 420)
        .background(ChopinTheme.paper, in: RoundedRectangle(cornerRadius: 24))
        .padding()
    }
}

struct WorkVideoGuideView: View {
    let chapter: PolonaiseChapter
    @State private var videoPlayer: AVPlayer?
    @State private var isMissingVideo = false

    var body: some View {
        VStack(spacing: 18) {
            if let videoPlayer {
                VideoPlayer(player: videoPlayer)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(ChopinTheme.ink.opacity(0.12))
                    }
            } else if isMissingVideo {
                ContentUnavailableView(
                    "找不到本機影片",
                    systemImage: "video.slash",
                    description: Text("請確認此影片已加入 App 資源。")
                )
            } else {
                ProgressView("正在準備本機影片…")
                    .font(.biauKai(.subheadline))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(chapter.title)
                    .font(.biauKai(.title2, weight: .bold))
                    .foregroundStyle(ChopinTheme.ink)
                Text(verbatim: "\(chapter.year) · \(chapter.catalog) · \(chapter.key)")
                    .font(.biauKai(.subheadline))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .archiveCard()

            Spacer()
        }
        .padding()
        .background(ChopinTheme.paper)
        .navigationTitle("\(chapter.catalog) 影像導讀")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: prepareVideo)
        .onDisappear {
            videoPlayer?.pause()
        }
    }

    private func prepareVideo() {
        guard videoPlayer == nil else { return }
        guard let videoURL = Bundle.main.url(
            forResource: chapter.id,
            withExtension: "mp4",
            subdirectory: "VideoGuides"
        ) ?? Bundle.main.url(forResource: chapter.id, withExtension: "mp4") else {
            isMissingVideo = true
            return
        }

        let player = AVPlayer(url: videoURL)
        videoPlayer = player
        player.play()
    }
}
