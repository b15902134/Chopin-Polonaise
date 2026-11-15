import SwiftUI

enum LibraryLayoutMode: String, CaseIterable, Identifiable {
    case list = "清單"
    case grid = "格狀"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .list: "list.bullet"
        case .grid: "square.grid.2x2"
        }
    }
}

struct PolonaiseLibraryView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @State private var library = PolonaiseLibrary()
    @State private var navigationPath: [PolonaiseChapter] = []
    @State private var layoutMode = LibraryLayoutMode.list

    var body: some View {
        @Bindable var library = library

        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                PeriodFilter(
                    periods: library.periods,
                    selection: $library.selectedPeriod
                )

                if library.visibleChapters.isEmpty {
                    ContentUnavailableView.search(text: library.query)
                } else if layoutMode == .list {
                    PolonaiseWorkList(
                        chapters: library.visibleChapters,
                        player: player,
                        favorites: favorites,
                        navigationPath: $navigationPath
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    PolonaiseWorkGrid(
                        chapters: library.visibleChapters,
                        player: player,
                        favorites: favorites
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.snappy(duration: 0.35), value: layoutMode)
            .navigationTitle("作品目錄")
            .searchable(text: $library.query, prompt: "搜尋曲名、作品編號或調性")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("顯示方式", selection: $layoutMode) {
                            ForEach(LibraryLayoutMode.allCases) { mode in
                                Label(mode.rawValue, systemImage: mode.systemImage)
                                    .tag(mode)
                            }
                        }
                    } label: {
                        Label("顯示方式", systemImage: layoutMode.systemImage)
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

struct PolonaiseWorkList: View {
    let chapters: [PolonaiseChapter]
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @Binding var navigationPath: [PolonaiseChapter]

    var body: some View {
        List(chapters) { chapter in
            Button {
                player.play(chapter)
                navigationPath.append(chapter)
            } label: {
                WorkRow(
                    chapter: chapter,
                    isFavorite: favorites.contains(chapter.id),
                    isPlaying: player.currentChapter?.id == chapter.id && player.isPlaying
                )
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .leading) {
                Button {
                    player.play(chapter)
                } label: {
                    Label("播放", systemImage: "play.fill")
                }
                .tint(.brown)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    favorites.toggle(chapter.id)
                } label: {
                    Label(
                        favorites.contains(chapter.id) ? "取消收藏" : "收藏",
                        systemImage: favorites.contains(chapter.id)
                            ? "heart.slash"
                            : "heart"
                    )
                }
                .tint(.red)
            }
        }
    }
}

struct PolonaiseWorkGrid: View {
    let chapters: [PolonaiseChapter]
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        let minimumWidth = horizontalSizeClass == .regular ? 210.0 : 155.0
        return [GridItem(.adaptive(minimum: minimumWidth), spacing: 14)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(chapters) { chapter in
                    NavigationLink(value: chapter) {
                        PolonaiseGalleryCard(
                            chapter: chapter,
                            isPlaying: player.currentChapter?.id == chapter.id && player.isPlaying
                        )
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            player.play(chapter)
                        }
                    )
                }
            }
            .padding()
            .padding(.bottom, 72)
        }
        .background(ChopinTheme.paper)
    }
}

struct PeriodFilter: View {
    let periods: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(periods, id: \.self) { period in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = period
                        }
                    } label: {
                        Text(period)
                            .font(.biauKai(.subheadline, weight: .bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .foregroundStyle(selection == period ? .white : .primary)
                            .background(
                                selection == period
                                    ? AnyShapeStyle(.brown)
                                    : AnyShapeStyle(.quaternary),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .background(.bar)
    }
}

struct WorkRow: View {
    let chapter: PolonaiseChapter
    let isFavorite: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.brown.opacity(0.12))
                Image(systemName: isPlaying ? "waveform" : "music.note")
                    .font(.title3)
                    .foregroundStyle(.brown)
                    .symbolEffect(.variableColor.iterative, isActive: isPlaying)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chapter.title)
                        .font(.biauKai(.headline))
                        .lineLimit(1)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                Text(verbatim: "\(chapter.year)・\(chapter.catalog)・\(chapter.key)")
                    .font(.biauKai(.caption))
                    .foregroundStyle(ChopinTheme.ink.opacity(0.76))
                Text(chapter.originalTitle)
                    .font(.biauKai(.caption2))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 5)
    }
}

enum WorkDetailSection: String, CaseIterable, Identifiable {
    case overview = "作品資料"
    case story = "作品故事"
    case appreciation = "賞析"
    case interpretation = "詮釋比較"
    case review = "樂評觀點"
    case context = "時代背景"
    case related = "同時期作品"

    var id: String { rawValue }
}

struct PolonaiseDetailView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites
    @State private var displayedChapter: PolonaiseChapter

    init(
        chapter: PolonaiseChapter,
        player: PolonaisePlayer,
        favorites: PolonaiseFavorites
    ) {
        self.player = player
        self.favorites = favorites
        _displayedChapter = State(initialValue: chapter)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    WorkDetailHeader(chapter: displayedChapter)
                        .id("detailTop")
                    WorkSectionIndex { section in
                        withAnimation {
                            proxy.scrollTo(section, anchor: .top)
                        }
                    }
                    WorkMetadataGrid(
                        year: displayedChapter.year,
                        catalog: displayedChapter.catalog,
                        key: displayedChapter.key,
                        period: displayedChapter.period
                    )
                    .id(WorkDetailSection.overview)
                    WorkIntroduction(text: displayedChapter.introduction)
                        .id(WorkDetailSection.story)
                    WorkAppreciation(text: displayedChapter.appreciation)
                        .id(WorkDetailSection.appreciation)
                    InterpretationComparisonSection(text: displayedChapter.interpretationComparison)
                        .id(WorkDetailSection.interpretation)
                    CriticalReviewSection(text: displayedChapter.criticalPerspective)
                        .id(WorkDetailSection.review)
                    EraContextSection(year: displayedChapter.year, period: displayedChapter.period)
                        .id(WorkDetailSection.context)
                    RelatedWorksSection(
                        works: displayedChapter.samePeriodWorks,
                        player: player
                    )
                    .id(WorkDetailSection.related)
                }
                .frame(maxWidth: 820)
                .padding()
                .padding(.bottom, 72)
                .frame(maxWidth: .infinity)
            }
            .background(ChopinTheme.paper)
            .navigationTitle(displayedChapter.catalog)
            .onChange(of: player.currentChapter?.id) { _, chapterID in
                guard let chapterID,
                      chapterID != displayedChapter.id,
                      let nextChapter = PolonaiseCatalog.chapters.first(where: { $0.id == chapterID }) else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.3)) {
                    displayedChapter = nextChapter
                    proxy.scrollTo("detailTop", anchor: .top)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu("段落", systemImage: "list.bullet") {
                        ForEach(WorkDetailSection.allCases) { section in
                            Button(section.rawValue) {
                                withAnimation {
                                    proxy.scrollTo(section, anchor: .top)
                                }
                            }
                        }
                    }

                    ShareLink(
                        item: "蕭邦 \(displayedChapter.title)，\(displayedChapter.catalog)，創作於 \(displayedChapter.year) 年。"
                    ) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        favorites.toggle(displayedChapter.id)
                    } label: {
                        Label(
                            favorites.contains(displayedChapter.id) ? "取消收藏" : "收藏",
                            systemImage: favorites.contains(displayedChapter.id) ? "heart.fill" : "heart"
                        )
                    }
                }
            }
        }
    }
}

struct WorkDetailHeader: View {
    let chapter: PolonaiseChapter

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [ChopinTheme.walnut, ChopinTheme.burgundy, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "music.quarternote.3")
                .font(.system(size: 145))
                .foregroundStyle(.white.opacity(0.07))
                .offset(x: 130, y: -35)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                Text(chapter.year, format: .number.grouping(.never))
                    .font(.biauKai(.caption, weight: .bold))
                    .tracking(2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.15), in: Capsule())
                Text(chapter.title)
                    .font(.biauKai(.largeTitle, weight: .bold))
                Text(chapter.originalTitle)
                    .font(.biauKai(.headline))
                    .foregroundStyle(.white.opacity(0.72))
                (
                    Text(chapter.catalog)
                        .foregroundStyle(.white)
                        .bold()
                    + Text("  ·  \(chapter.key)  ·  \(chapter.period)")
                        .foregroundStyle(.white.opacity(0.68))
                )
                .font(.biauKai(.subheadline))
            }
            .foregroundStyle(.white)
            .padding(24)
        }
        .frame(minHeight: 260)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(ChopinTheme.antiqueGold.opacity(0.42), lineWidth: 1)
        }
        .shadow(color: ChopinTheme.ink.opacity(0.24), radius: 18, y: 8)
    }
}

struct WorkMetadataGrid: View {
    let year: Int
    let catalog: String
    let key: String
    let period: String

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 138), spacing: 12)],
            spacing: 12
        ) {
            MetadataCell(label: "創作年份", value: "\(year)", symbol: "calendar")
            MetadataCell(label: "作品編號", value: catalog, symbol: "number")
            MetadataCell(label: "調性", value: key, symbol: "music.note")
            MetadataCell(label: "創作時期", value: period, symbol: "building.columns")
        }
    }
}

struct MetadataCell: View {
    let label: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: symbol)
                .font(.biauKai(.caption))
                .foregroundStyle(ChopinTheme.burgundy)
            Text(value)
                .font(.biauKai(.subheadline, weight: .bold))
                .foregroundStyle(ChopinTheme.ink)
        }
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .archiveCard()
    }
}

struct EraContextSection: View {
    let year: Int
    let period: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EditorialSectionTitle(
                eyebrow: "HISTORICAL CONTEXT",
                title: "創作時代",
                symbol: "clock.arrow.circlepath"
            )
            Text(verbatim: "作品完成於 \(year) 年，屬於蕭邦的「\(period)」。\(contextText)")
                .lineSpacing(6)
                .foregroundStyle(ChopinTheme.ink.opacity(0.84))
        }
        .archiveCard()
    }

    private var contextText: String {
        switch period {
        case "童年時期":
            "此時的作品仍保留華沙沙龍與古典舞曲的輪廓，卻已展現異常成熟的旋律直覺。"
        case "華沙少年期", "華沙青年期", "華沙末期":
            "華沙的民族舞蹈、家庭沙龍與音樂教育共同塑造他的語言；波蘭舞曲逐漸從社交舞轉為個人表達。"
        case "維也納／巴黎初期":
            "離開波蘭後，故鄉舞曲帶上了記憶與身份象徵，炫技風格也開始面向歐洲音樂廳。"
        case "馬約卡時期":
            "旅行、健康與孤獨感交織，使音樂在外向節奏下保有更複雜的陰影。"
        case "晚期":
            "晚期作品突破固定舞曲框架，和聲、節奏與敘事變得更自由，也更接近回望一生的內在獨白。"
        default:
            "巴黎時期的蕭邦把民族舞蹈提升為大型鋼琴詩篇，結合公共姿態、私密情感與精緻音色。"
        }
    }
}

struct WorkIntroduction: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EditorialSectionTitle(
                eyebrow: "EDITORIAL NOTE",
                title: "作品故事",
                symbol: "book.closed.fill"
            )
            HStack(alignment: .top, spacing: 14) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ChopinTheme.antiqueGold,
                                ChopinTheme.antiqueGold.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)

                Text(text)
                    .font(.biauKai(.body))
                    .lineSpacing(8)
                    .foregroundStyle(ChopinTheme.ink.opacity(0.9))
                    .textSelection(.enabled)
            }
        }
        .archiveCard()
    }
}

struct CriticalReviewSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EditorialSectionTitle(
                eyebrow: "CRITICAL PERSPECTIVE",
                title: "樂評與研究觀點",
                symbol: "text.quote"
            )

            Text(text)
                .font(.biauKai(.body))
                .lineSpacing(8)
                .foregroundStyle(ChopinTheme.ink.opacity(0.9))
                .textSelection(.enabled)
        }
        .archiveCard()
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(ChopinTheme.burgundy)
                .frame(width: 3)
                .padding(.vertical, 18)
                .accessibilityHidden(true)
        }
    }
}

struct InterpretationComparisonSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EditorialSectionTitle(
                eyebrow: "INTERPRETATION",
                title: "演奏詮釋比較",
                symbol: "slider.horizontal.3"
            )

            Text(text)
                .font(.biauKai(.body))
                .lineSpacing(8)
                .foregroundStyle(ChopinTheme.ink.opacity(0.9))
                .textSelection(.enabled)
        }
        .archiveCard()
    }
}

struct WorkAppreciation: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EditorialSectionTitle(
                eyebrow: "MUSICAL APPRECIATION",
                title: "作品賞析",
                symbol: "sparkles"
            )

            HStack(spacing: 8) {
                AppreciationLens(title: "主題", symbol: "music.note")
                AppreciationLens(title: "節奏", symbol: "metronome")
                AppreciationLens(title: "和聲", symbol: "pianokeys")
                AppreciationLens(title: "情感", symbol: "heart")
            }

            OrnamentDivider()

            Text(text)
                .font(.biauKai(.body))
                .lineSpacing(8)
                .foregroundStyle(ChopinTheme.ink.opacity(0.9))
                .textSelection(.enabled)
        }
        .archiveCard()
        .overlay(alignment: .topTrailing) {
            Image(systemName: "quote.closing")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(ChopinTheme.antiqueGold.opacity(0.15))
                .padding(20)
                .accessibilityHidden(true)
        }
    }
}

struct AppreciationLens: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.biauKai(.caption2, weight: .semibold))
            .foregroundStyle(ChopinTheme.burgundy)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(ChopinTheme.burgundy.opacity(0.07), in: Capsule())
            .frame(maxWidth: .infinity)
    }
}


struct WorkSectionIndex: View {
    let select: (WorkDetailSection) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(WorkDetailSection.allCases) { section in
                    Button(section.rawValue) {
                        select(section)
                    }
                    .buttonStyle(.bordered)
                    .tint(ChopinTheme.burgundy)
                }
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("作品頁段落目錄")
    }
}

struct RelatedWorksSection: View {
    let works: [PolonaiseChapter]
    let player: PolonaisePlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EditorialSectionTitle(
                eyebrow: "RELATED WORKS",
                title: "同時期作品",
                symbol: "rectangle.stack.fill"
            )

            if works.isEmpty {
                Text("此創作時期目前沒有其他收錄作品。")
                    .font(.biauKai(.subheadline))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(works.prefix(3)) { work in
                    NavigationLink(value: work) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(work.title)
                                .font(.biauKai(.headline))
                                .foregroundStyle(ChopinTheme.ink)
                            Text(verbatim: "\(work.year) · \(work.catalog)")
                                .font(.biauKai(.caption))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            player.play(work)
                        }
                    )
                    .padding(.vertical, 5)
                }
            }
        }
        .archiveCard()
    }
}
