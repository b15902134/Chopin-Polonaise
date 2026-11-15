import SwiftUI

struct PolonaiseBookView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var readingState = AudiobookReadingState()

    var body: some View {
        @Bindable var readingState = readingState

        NavigationStack {
            HStack(spacing: 0) {
                if horizontalSizeClass == .regular {
                    PeriodSidebar(
                        periods: ChopinPeriodCatalog.periods,
                        selectedPeriodID: $readingState.selectedPeriodID,
                        completedCount: readingState.completedPeriodCount,
                        completion: readingState.completion
                    )
                    .frame(minWidth: 230, idealWidth: 270, maxWidth: 300)

                    Divider()
                }

                AudiobookPages(
                    selectedPeriodID: $readingState.selectedPeriodID,
                    player: player,
                    favorites: favorites,
                    completedCount: readingState.completedPeriodCount,
                    completion: readingState.completion
                )
            }
            .background(ChopinTheme.paper.ignoresSafeArea())
            .navigationTitle("時代有聲書")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if horizontalSizeClass != .regular {
                    ToolbarItem(placement: .topBarTrailing) {
                        PeriodNavigationMenu(
                            periods: ChopinPeriodCatalog.periods,
                            selectedPeriodID: $readingState.selectedPeriodID
                        )
                    }
                }
            }
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


struct ReadingProgressSummary: View {
    let completedCount: Int
    let totalCount: Int
    let completion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label("閱讀進度", systemImage: "bookmark.fill")
                    .font(.biauKai(.caption, weight: .bold))
                Spacer()
                Text("\(completedCount)／\(totalCount) 個時期")
                    .font(.biauKai(.caption))
            }
            .foregroundStyle(ChopinTheme.burgundy)

            ProgressView(value: completion)
                .tint(ChopinTheme.burgundy)
                .accessibilityLabel("閱讀進度")
                .accessibilityValue("\(Int(completion * 100))％")
        }
    }
}

struct PeriodHistoricalTimeline: View {
    let events: [PeriodHistoricalEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EditorialSectionTitle(
                eyebrow: "CHRONOLOGY",
                title: "時代時間線",
                symbol: "point.topleft.down.to.point.bottomright.curvepath"
            )

            ForEach(events) { event in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(ChopinTheme.burgundy)
                            .frame(width: 10, height: 10)
                        Rectangle()
                            .fill(ChopinTheme.burgundy.opacity(0.2))
                            .frame(width: 1, height: 70)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(event.year)
                                .font(.biauKai(.caption, weight: .bold))
                                .foregroundStyle(ChopinTheme.burgundy)
                            Text(event.category)
                                .font(.biauKai(.caption2, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ChopinTheme.burgundy.opacity(0.1), in: Capsule())
                        }
                        Text(event.title)
                            .font(.biauKai(.headline))
                            .foregroundStyle(ChopinTheme.ink)
                        Text(event.detail)
                            .font(.biauKai(.subheadline))
                            .foregroundStyle(ChopinTheme.ink.opacity(0.78))
                            .lineSpacing(4)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AudiobookPages: View {
    @Binding var selectedPeriodID: String
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    let completedCount: Int
    let completion: Double

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPeriodID) {
                ForEach(ChopinPeriodCatalog.periods.enumerated(), id: \.element.id) { index, period in
                    CreativePeriodPage(
                        period: period,
                        chapterNumber: index + 1,
                        chapterCount: ChopinPeriodCatalog.periods.count,
                        player: player,
                        favorites: favorites,
                        completedCount: completedCount,
                        completion: completion
                    )
                    .tag(period.id)
                }
            }
            .polonaisePageStyle()

            AudiobookPageControls(
                selectedPeriodID: $selectedPeriodID,
                periods: ChopinPeriodCatalog.periods
            )
        }
    }
}

struct AudiobookPageControls: View {
    @Binding var selectedPeriodID: String
    let periods: [ChopinCreativePeriod]

    private var selectedIndex: Int {
        periods.firstIndex { $0.id == selectedPeriodID } ?? 0
    }

    var body: some View {
        HStack(spacing: 14) {
            Button {
                move(to: selectedIndex - 1)
            } label: {
                Label("上一章", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(selectedIndex == periods.startIndex)

            Text("\(selectedIndex + 1)／\(periods.count)")
                .font(.biauKai(.caption, weight: .bold))
                .foregroundStyle(.secondary)
                .accessibilityLabel("第 \(selectedIndex + 1) 章，共 \(periods.count) 章")

            Button {
                move(to: selectedIndex + 1)
            } label: {
                Label("下一章", systemImage: "chevron.right")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(ChopinTheme.burgundy)
            .disabled(selectedIndex == periods.index(before: periods.endIndex))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func move(to index: Int) {
        guard periods.indices.contains(index) else { return }
        withAnimation(.easeInOut) {
            selectedPeriodID = periods[index].id
        }
    }
}

struct PeriodSidebar: View {
    let periods: [ChopinCreativePeriod]
    @Binding var selectedPeriodID: String
    let completedCount: Int
    let completion: Double

    var body: some View {
        List {
            Section {
                ReadingProgressSummary(
                    completedCount: completedCount,
                    totalCount: periods.count,
                    completion: completion
                )
                .listRowBackground(Color.clear)
            }

            Section("創作時期") {
                ForEach(periods.enumerated(), id: \.element.id) { index, period in
                    PeriodSidebarRow(
                        number: index + 1,
                        title: period.title,
                        years: period.years,
                        workCount: period.works.count,
                        isSelected: selectedPeriodID == period.id
                    ) {
                        selectedPeriodID = period.id
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ChopinTheme.paper)
    }
}

struct PeriodSidebarRow: View {
    let number: Int
    let title: String
    let years: String
    let workCount: Int
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(number). \(title)")
                    .font(.biauKai(.headline))
                Text("\(years) · \(workCount) 部作品")
                    .font(.biauKai(.caption))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .listRowBackground(isSelected ? ChopinTheme.burgundy.opacity(0.12) : Color.clear)
        .accessibilityValue(isSelected ? "目前章節" : "")
    }
}

struct PeriodNavigationMenu: View {
    let periods: [ChopinCreativePeriod]
    @Binding var selectedPeriodID: String

    var body: some View {
        Menu {
            ForEach(periods.enumerated(), id: \.element.id) { index, period in
                Button {
                    withAnimation {
                        selectedPeriodID = period.id
                    }
                } label: {
                    Label(
                        "\(index + 1). \(period.title) · \(period.years)",
                        systemImage: selectedPeriodID == period.id ? "checkmark.circle.fill" : "circle"
                    )
                }
            }
        } label: {
            Label("時期目錄", systemImage: "list.bullet")
        }
        .accessibilityLabel("選擇創作時期")
    }
}

extension View {
    @ViewBuilder
    func polonaisePageStyle() -> some View {
#if os(iOS)
        tabViewStyle(.page(indexDisplayMode: .always))
#else
        self
#endif
    }
}

struct CreativePeriodPage: View {
    let period: ChopinCreativePeriod
    let chapterNumber: Int
    let chapterCount: Int
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    let completedCount: Int
    let completion: Double

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                CreativePeriodHero(
                    years: period.years,
                    title: period.title,
                    subtitle: period.subtitle,
                    workCount: period.works.count,
                    chapterNumber: chapterNumber,
                    chapterCount: chapterCount
                )
                PeriodHistoricalTimeline(events: period.historicalEvents)
                HistoricalContextSection(text: period.historicalContext)
                CreativeContextSection(text: period.creativeContext)
                InferredMindsetSection(text: period.inferredMindset)
                PeriodWorksSection(
                    works: period.works,
                    player: player,
                    favorites: favorites
                )
            }
            .frame(maxWidth: 760)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background(
            LinearGradient(
                colors: [ChopinTheme.paper, ChopinTheme.surface, ChopinTheme.paper.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct CreativePeriodHero: View {
    let years: String
    let title: String
    let subtitle: String
    let workCount: Int
    let chapterNumber: Int
    let chapterCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("第 \(chapterNumber) 章／共 \(chapterCount) 章")
                    .font(.biauKai(.caption, weight: .semibold))
                Spacer()
                Text("\(workCount) 部作品")
                    .font(.biauKai(.caption, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.72))

            Text(years)
                .font(.biauKai(.subheadline, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.88))

            Text(title)
                .font(.biauKai(.largeTitle, weight: .bold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.biauKai(.headline))
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(.white.opacity(0.35))
                .frame(width: 72, height: 1)

            Text("蕭邦波蘭舞曲創作時期")
                .font(.biauKai(.caption2, weight: .semibold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: periodColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "pianokeys")
                .font(.system(size: 92))
                .foregroundStyle(.white.opacity(0.055))
                .padding(18)
                .accessibilityHidden(true)
        }
        .shadow(color: ChopinTheme.ink.opacity(0.18), radius: 18, y: 8)
    }

    private var periodColors: [Color] {
        switch chapterNumber {
        case 1: [Color(red: 0.25, green: 0.16, blue: 0.12), Color(red: 0.43, green: 0.25, blue: 0.15)]
        case 2: [Color(red: 0.18, green: 0.23, blue: 0.24), Color(red: 0.34, green: 0.28, blue: 0.22)]
        case 3: [Color(red: 0.19, green: 0.20, blue: 0.30), Color(red: 0.39, green: 0.17, blue: 0.20)]
        case 4: [Color(red: 0.12, green: 0.17, blue: 0.24), Color(red: 0.34, green: 0.09, blue: 0.12)]
        case 5: [Color(red: 0.25, green: 0.12, blue: 0.16), Color(red: 0.45, green: 0.24, blue: 0.17)]
        case 6: [Color(red: 0.16, green: 0.22, blue: 0.20), Color(red: 0.37, green: 0.16, blue: 0.12)]
        default: [Color(red: 0.12, green: 0.12, blue: 0.16), Color(red: 0.31, green: 0.08, blue: 0.12)]
        }
    }
}

struct HistoricalContextSection: View {
    let text: String

    var body: some View {
        PeriodEditorialSection(
            eyebrow: "POLISH HISTORY",
            title: "波蘭歷史座標",
            symbol: "building.columns.fill",
            text: text
        )
    }
}

struct CreativeContextSection: View {
    let text: String

    var body: some View {
        PeriodEditorialSection(
            eyebrow: "COMPOSITION",
            title: "創作背景",
            symbol: "music.quarternote.3",
            text: text
        )
    }
}

struct PeriodEditorialSection: View {
    let eyebrow: String
    let title: String
    let symbol: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            EditorialSectionTitle(
                eyebrow: eyebrow,
                title: title,
                symbol: symbol
            )
            Text(text)
                .font(.biauKai(.body))
                .foregroundStyle(ChopinTheme.ink.opacity(0.86))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .archiveCard()
    }
}

struct InferredMindsetSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            EditorialSectionTitle(
                eyebrow: "INTERPRETATION",
                title: "心境推測",
                symbol: "quote.opening"
            )
            Text(text)
                .font(.biauKai(.body))
                .foregroundStyle(ChopinTheme.ink.opacity(0.86))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)

            Label("詮釋性推測；不等同於書信或日記中的直接自述", systemImage: "info.circle")
                .font(.biauKai(.caption))
                .foregroundStyle(ChopinTheme.burgundy)
        }
        .archiveCard()
    }
}

struct PeriodWorksSection: View {
    let works: [PolonaiseChapter]
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            EditorialSectionTitle(
                eyebrow: "AUDIO CHAPTERS",
                title: "本期作品",
                symbol: "headphones"
            )

            ForEach(works) { work in
                PeriodWorkRow(
                    work: work,
                    player: player,
                    isFavorite: favorites.contains(work.id)
                )
            }
        }
    }
}

struct PeriodWorkRow: View {
    let work: PolonaiseChapter
    let player: PolonaisePlayer
    let isFavorite: Bool

    private var isCurrent: Bool {
        player.currentChapter?.id == work.id
    }

    var body: some View {
        NavigationLink(value: work) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(work.year, format: .number.grouping(.never))
                            .font(.biauKai(.caption, weight: .bold))
                            .foregroundStyle(ChopinTheme.burgundy)
                        Text(work.catalog)
                            .font(.biauKai(.caption))
                            .foregroundStyle(.secondary)
                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundStyle(ChopinTheme.burgundy)
                        }
                    }

                    Text(work.title)
                        .font(.biauKai(.headline))
                        .foregroundStyle(ChopinTheme.ink)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Text(work.key)
                            .font(.biauKai(.caption))
                            .foregroundStyle(.secondary)

                        if isCurrent {
                            Label(
                                player.isPlaying ? "播放中" : "已暫停",
                                systemImage: player.isPlaying ? "waveform" : "pause.circle.fill"
                            )
                            .font(.biauKai(.caption2, weight: .bold))
                            .foregroundStyle(ChopinTheme.burgundy)
                        }
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(ChopinTheme.ink.opacity(0.35))
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            TapGesture().onEnded {
                player.play(work)
            }
        )
        .padding(16)
        .background(ChopinTheme.surface.opacity(0.9), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isCurrent ? ChopinTheme.burgundy.opacity(0.5) : ChopinTheme.ink.opacity(0.08),
                    lineWidth: isCurrent ? 1.5 : 1
                )
        }
    }
}
