import SwiftUI

struct PolonaiseTimelineView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    private let chapters = PolonaiseCatalog.chapters.sorted { $0.year < $1.year }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ChopinHeroView()

                    ForEach(chapters) { chapter in
                        NavigationLink(value: chapter) {
                            TimelineChapterRow(
                                chapter: chapter,
                                isCurrent: player.currentChapter?.id == chapter.id,
                                isPlaying: player.currentChapter?.id == chapter.id && player.isPlaying
                            )
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                player.play(chapter)
                            }
                        )
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                        .padding(.horizontal)
                        .padding(.top, 28)
                }
            }
            .background(ChopinTheme.paper)
            .ignoresSafeArea(edges: .top)
            .navigationTitle("創作時間線")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: PolonaiseChapter.self) { chapter in
                PolonaiseDetailView(
                    chapter: chapter,
                    player: player,
                    favorites: favorites
                )
            }
        }
    }
}

struct ChopinHeroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                AsyncImage(url: PolonaiseCatalog.portraitURL) { phase in
                    ZStack {
                        ChopinTheme.paper

                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height,
                                    alignment: .top
                                )
                                .grayscale(1)
                                .contrast(1.12)
                                .accessibilityHidden(true)
                        } else if phase.error != nil {
                            Image(systemName: "pianokeys")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.55))
                                .accessibilityHidden(true)
                        } else {
                            ProgressView()
                                .tint(.white)
                                .accessibilityLabel("正在載入蕭邦肖像")
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .clipped()
            }

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .clear, location: 0.76),
                    .init(color: ChopinTheme.paper, location: 0.94),
                    .init(color: ChopinTheme.paper, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                Text("FRYDERYK\nCHOPIN")
                    .font(.biauKai(.largeTitle, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineSpacing(-4)

                HStack(spacing: 10) {
                    Text("1810—1849")
                    Text("•")
                    Text("WARSAW · PARIS")
                }
                .font(.biauKai(.caption, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white)

                Text("藉由波蘭舞曲以時間閱讀一位鋼琴詩人的民族記憶")
                    .font(.biauKai(.subheadline))
                    .lineSpacing(5)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 96)
            .shadow(color: .black.opacity(0.98), radius: 1, y: 1)
            .shadow(color: .black.opacity(0.72), radius: 7, y: 2)
            .allowsHitTesting(false)
        }
        .frame(height: 590)
        .clipped()
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible || reduceMotion ? 1 : 1.025)
        .onAppear {
            if reduceMotion {
                isVisible = true
            } else {
                withAnimation(.easeOut(duration: 0.8)) {
                    isVisible = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.bottom, 18)
    }
}

struct TimelineChapterRow: View {
    let chapter: PolonaiseChapter
    let isCurrent: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrent ? Color.brown : Color(red: 0.35, green: 0.23, blue: 0.16))
                    .frame(width: 14, height: 14)
                    .overlay {
                        if isPlaying {
                            Image(systemName: "waveform")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                Rectangle()
                    .fill(.brown.opacity(0.28))
                    .frame(width: 2, height: 128)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(chapter.year, format: .number.grouping(.never))
                        .font(.biauKai(.title2, weight: .bold))
                        .foregroundStyle(.brown)
                    Text(chapter.period)
                        .font(.biauKai(.caption, weight: .bold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.brown.opacity(0.1), in: Capsule())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                Text(chapter.title)
                    .font(.biauKai(.headline))
                    .foregroundStyle(.primary)
                Text("\(chapter.catalog)・\(chapter.key)")
                    .font(.biauKai(.subheadline))
                    .foregroundStyle(.secondary)
                Text(chapter.introduction)
                    .font(.biauKai(.caption))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .archiveCard()
            .padding(.bottom, 12)
        }
    }
}

