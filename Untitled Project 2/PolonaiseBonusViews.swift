import SwiftUI

struct PolonaiseGalleryView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let chapters = PolonaiseCatalog.chapters.sorted {
        if $0.year == $1.year { return $0.id < $1.id }
        return $0.year < $1.year
    }

    private var columns: [GridItem] {
        let minimum = horizontalSizeClass == .regular ? 210.0 : 155.0
        return [GridItem(.adaptive(minimum: minimum), spacing: 14)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    PolonaiseArchiveHeader(workCount: chapters.count)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(chapters) { chapter in
                            NavigationLink(value: chapter) {
                                PolonaiseGalleryCard(
                                    chapter: chapter,
                                    isPlaying: player.currentChapter?.id == chapter.id && player.isPlaying
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 72)
            }
            .background(ChopinTheme.paper)
            .navigationTitle("作品典藏")
            .navigationDestination(for: PolonaiseChapter.self) { chapter in
                PolonaiseDetailView(chapter: chapter, player: player, favorites: favorites)
            }
        }
    }
}

struct PolonaiseArchiveHeader: View {
    let workCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THE POLONAISE ARCHIVE")
                .font(.biauKai(.caption, weight: .bold))
                .tracking(2.4)
                .foregroundStyle(ChopinTheme.burgundy)
            Text("蕭邦波蘭舞曲典藏索引")
                .font(.biauKai(.title, weight: .bold))
                .foregroundStyle(ChopinTheme.ink)
            Text("依創作年份編排的 \(workCount) 個播放章節。每張檔案卡保留作品編號、調性與原文題名，點選即可進入完整賞析。")
                .font(.biauKai(.subheadline))
                .foregroundStyle(ChopinTheme.ink.opacity(0.76))
                .lineSpacing(5)
        }
        .padding(.vertical, 8)
    }
}

struct PolonaiseGalleryCard: View {
    let chapter: PolonaiseChapter
    let isPlaying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(chapter.year, format: .number.grouping(.never))
                    .font(.biauKai(.title2, weight: .bold))
                Spacer()
                Image(systemName: isPlaying ? "waveform" : "music.note")
                    .symbolEffect(.variableColor.iterative, isActive: isPlaying && !reduceMotion)
            }
            .foregroundStyle(ChopinTheme.burgundy)

            Rectangle()
                .fill(ChopinTheme.burgundy.opacity(0.24))
                .frame(height: 1)

            Spacer(minLength: 8)

            Text(chapter.title)
                .font(.biauKai(.headline, weight: .bold))
                .foregroundStyle(ChopinTheme.ink)
                .lineLimit(3)

            Text(verbatim: "\(chapter.catalog) · \(chapter.key)")
                .font(.biauKai(.caption))
                .foregroundStyle(ChopinTheme.burgundy)

            Text(chapter.originalTitle)
                .font(.biauKai(.caption2))
                .foregroundStyle(ChopinTheme.ink.opacity(0.58))
                .lineLimit(2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 225, alignment: .leading)
        .background(ChopinTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(ChopinTheme.burgundy.opacity(0.16))
        }
        .overlay(alignment: .bottomTrailing) {
            Text(chapter.id)
                .font(.biauKai(.largeTitle, weight: .bold))
                .foregroundStyle(ChopinTheme.burgundy.opacity(0.055))
                .padding(12)
                .accessibilityHidden(true)
        }
        .shadow(color: ChopinTheme.ink.opacity(0.06), radius: 10, y: 4)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible || reduceMotion ? 0 : 16)
        .onAppear {
            if reduceMotion {
                isVisible = true
            } else {
                withAnimation(.easeOut(duration: 0.45)) {
                    isVisible = true
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

}

struct ChopinVideoGuideView: View {
    private let chapters = PolonaiseCatalog.chapters.sorted {
        if $0.year == $1.year { return $0.id < $1.id }
        return $0.year < $1.year
    }

    var body: some View {
        NavigationStack {
            List(chapters) { chapter in
                NavigationLink {
                    WorkVideoGuideView(chapter: chapter)
                } label: {
                    VideoGuideRow(chapter: chapter)
                }
                .listRowBackground(ChopinTheme.paper)
            }
            .scrollContentBackground(.hidden)
            .background(ChopinTheme.paper)
            .navigationTitle("影像導讀")
        }
    }
}

struct VideoGuideRow: View {
    let chapter: PolonaiseChapter

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "play.rectangle.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(ChopinTheme.burgundy, in: RoundedRectangle(cornerRadius: 13))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title)
                    .font(.biauKai(.headline))
                    .foregroundStyle(ChopinTheme.ink)
                    .lineLimit(2)
                Text(verbatim: "\(chapter.year) · \(chapter.catalog) · \(chapter.key)")
                    .font(.biauKai(.caption))
                    .foregroundStyle(.secondary)
                Text("開啟本曲演奏影像")
                    .font(.biauKai(.caption2))
                    .foregroundStyle(ChopinTheme.burgundy)
            }
        }
        .padding(.vertical, 5)
    }
}
