import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var player = PolonaisePlayer()
    @State private var favorites = PolonaiseFavorites()
    @State private var isShowingOpening = true

    var body: some View {
        ZStack {
            PolonaiseTabView(player: player, favorites: favorites)
                .opacity(isShowingOpening ? 0 : 1)

            if isShowingOpening {
                PolonaiseOpeningView()
                    .transition(.opacity)
            }
        }
        .font(.biauKai(.body))
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            if reduceMotion {
                isShowingOpening = false
            } else {
                withAnimation(.easeInOut(duration: 0.55)) {
                    isShowingOpening = false
                }
            }
        }
    }
}

struct PolonaiseTabView: View {
    let player: PolonaisePlayer
    let favorites: PolonaiseFavorites

    var body: some View {
        TabView {
            Tab("時間線", systemImage: "timeline.selection") {
                PolonaiseTimelineView(player: player, favorites: favorites)
            }

            Tab("作品", systemImage: "music.note.list") {
                PolonaiseLibraryView(player: player, favorites: favorites)
            }

            Tab("有聲書", systemImage: "headphones") {
                PolonaiseBookView(player: player, favorites: favorites)
            }

            Tab("影像", systemImage: "play.rectangle") {
                ChopinVideoGuideView()
            }

            Tab("官方網站", systemImage: "globe") {
                ChopinWebView()
            }
        }
        .tint(ChopinTheme.burgundy)
        .tabViewStyle(.sidebarAdaptable)
        .tabViewBottomAccessory(isEnabled: player.currentChapter != nil) {
            if let chapter = player.currentChapter {
                MiniPlayerBar(chapter: chapter, player: player)
            }
        }
    }
}

struct PolonaiseOpeningView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isContentVisible = false
    @State private var isOrbiting = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.07, blue: 0.05), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            OpeningOrbit(isOrbiting: isOrbiting && !reduceMotion)
            OpeningPianoMark(reduceMotion: reduceMotion)

            OpeningTitle()
                .opacity(isContentVisible ? 1 : 0)
                .offset(y: isContentVisible || reduceMotion ? 0 : 24)
        }
        .onAppear {
            if reduceMotion {
                isContentVisible = true
                return
            }

            withAnimation(.easeOut(duration: 0.8).delay(0.15)) {
                isContentVisible = true
            }
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                isOrbiting = true
            }
        }
    }
}

struct OpeningOrbit: View {
    let isOrbiting: Bool

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.64)
                .stroke(
                    AngularGradient(
                        colors: [.clear, ChopinTheme.antiqueGold.opacity(0.8), .clear],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 250, height: 250)

            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "music.note")
                    .font(.system(size: 13 + CGFloat(index * 3)))
                    .foregroundStyle(ChopinTheme.antiqueGold.opacity(0.78))
                    .offset(y: -125)
                    .rotationEffect(.degrees(Double(index) * 120))
            }
        }
        .rotationEffect(.degrees(isOrbiting ? 360 : 0))
        .accessibilityHidden(true)
    }
}

struct OpeningPianoMark: View {
    let reduceMotion: Bool
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = 76.0

    var body: some View {
        Image(systemName: "pianokeys")
            .font(.system(size: iconSize))
            .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
            .foregroundStyle(.white, ChopinTheme.antiqueGold)
            .phaseAnimator(reduceMotion ? [false] : [false, true]) { content, lifted in
                content
                    .scaleEffect(lifted ? 1.07 : 0.96)
                    .offset(y: lifted ? -7 : 4)
                    .shadow(
                        color: ChopinTheme.antiqueGold.opacity(lifted ? 0.48 : 0.18),
                        radius: lifted ? 24 : 8
                    )
            } animation: { lifted in
                lifted ? .smooth(duration: 1.15) : .easeInOut(duration: 1.15)
            }
            .accessibilityHidden(true)
    }
}

struct OpeningTitle: View {
    var body: some View {
        VStack(spacing: 7) {
            Text("FRYDERYK CHOPIN")
                .font(.biauKai(.caption, weight: .semibold))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.65))
            Text("波蘭舞曲")
                .font(.biauKai(.largeTitle, weight: .bold))
            OrnamentDivider()
                .frame(width: 180)
            Text("有聲電子書・1817—1846")
                .font(.biauKai(.headline))
                .foregroundStyle(.white.opacity(0.72))
        }
        .foregroundStyle(.white)
        .offset(y: 92)
    }
}

#Preview {
    ContentView()
}
