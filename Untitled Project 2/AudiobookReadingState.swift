import Foundation
import Observation

@MainActor
@Observable
final class AudiobookReadingState {
    private static let selectedPeriodKey = "audiobookSelectedPeriodID"
    private static let readPeriodsKey = "audiobookReadPeriodIDs"
    private static let lastWorkKey = "audiobookLastWorkID"

    var selectedPeriodID: String {
        didSet {
            UserDefaults.standard.set(selectedPeriodID, forKey: Self.selectedPeriodKey)
            markCurrentPeriodRead()
        }
    }

    private(set) var readPeriodIDs: Set<String>
    private(set) var lastWorkID: String?

    init() {
        selectedPeriodID = UserDefaults.standard.string(forKey: Self.selectedPeriodKey) ?? "childhood"
        readPeriodIDs = Set(
            UserDefaults.standard.stringArray(forKey: Self.readPeriodsKey) ?? []
        )
        lastWorkID = UserDefaults.standard.string(forKey: Self.lastWorkKey)
    }

    var completedPeriodCount: Int {
        readPeriodIDs.count
    }

    var completion: Double {
        guard !ChopinPeriodCatalog.periods.isEmpty else { return 0 }
        return Double(completedPeriodCount) / Double(ChopinPeriodCatalog.periods.count)
    }

    var selectedPeriod: ChopinCreativePeriod {
        ChopinPeriodCatalog.periods.first { $0.id == selectedPeriodID }
            ?? ChopinPeriodCatalog.periods[0]
    }

    var lastWork: PolonaiseChapter? {
        guard let lastWorkID else { return nil }
        return PolonaiseCatalog.chapters.first { $0.id == lastWorkID }
    }

    func markCurrentPeriodRead() {
        readPeriodIDs.insert(selectedPeriodID)
        UserDefaults.standard.set(Array(readPeriodIDs), forKey: Self.readPeriodsKey)
    }

    func recordOpenedWork(_ work: PolonaiseChapter) {
        lastWorkID = work.id
        UserDefaults.standard.set(work.id, forKey: Self.lastWorkKey)
    }
}
