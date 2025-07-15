
import Foundation
import SwiftUI

class TehillimViewModel: ObservableObject {
    
    @AppStorage("sortTehilimCriterion") private var sortCriterionRaw: String = SortCriterion.day.rawValue

    @Published private var allTehillimEpisode: [TehillimEpisode] = []
    @Published var episodeGroups: [EpisodeGroup] = []
    @Published var searchText: String = "" {
        didSet { updateSortAndFilter() }
    }
    
    init() {
        allTehillimEpisode = loadEpisodes()
        updateSortAndFilter()
    }
    
    var sortCriterion: SortCriterion {
        get { SortCriterion(rawValue: sortCriterionRaw) ?? .day }
        set { sortCriterionRaw = newValue.rawValue; updateSortAndFilter() }
    }
    
    enum SortCriterion: String {
        case day, book, favorite
    }
    
    func saveEpisodes() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(allTehillimEpisode)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filePath = paths[0].appendingPathComponent("tehilim.json")
            
            try data.write(to: filePath, options: .atomicWrite)
            
            print("Saved successfully to \(filePath)")
        } catch {
            print("Error encoding or saving: \(error)")
        }
    }
    
    func loadEpisodes() -> [TehillimEpisode] {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("tehilim.json")
        
        if let data = try? Data(contentsOf: filePath) {
            let decoder = JSONDecoder()
            if let episodes = try? decoder.decode([TehillimEpisode].self, from: data) {
                print("Loaded successfully from \(filePath)")
                return episodes
            }
        }
        
        if let bundledPath = Bundle.main.path(forResource: "tehilim", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: bundledPath)) {
            let decoder = JSONDecoder()
            if let episodes = try? decoder.decode([TehillimEpisode].self, from: data) {
                print("Loaded fresh json from \(bundledPath)")
                return episodes
            }
        }
        
        return []
    }
    
    func updateSortAndFilter() {
        switch sortCriterion {
        case .day:
            let groupRanges = TehillimGroups().days
            episodeGroups = groupRanges.map { group in
                EpisodeGroup(title: group.title, episodes: Array(allTehillimEpisode[group.range]))
            }
            
        case .book:
            let groupRanges = TehillimGroups().books
            episodeGroups = groupRanges.map { group in
                EpisodeGroup(title: group.title, episodes: Array(allTehillimEpisode[group.range]))
            }
            
        case .favorite:
            let favoriteEpisodes = allTehillimEpisode.filter { $0.isFavorite }
            let sortedFavorites = favoriteEpisodes.sorted(by: { $0.id < $1.id })
            episodeGroups = [EpisodeGroup(title: "FAVORITES_LOC_STRING", episodes: sortedFavorites)]
        }
        
        if !searchText.isEmpty {
            episodeGroups = episodeGroups.map { group in
                let filteredEpisodes = group.episodes.filter { $0.name.contains(searchText) || String($0.id).contains(searchText) }
                return EpisodeGroup(title: group.title, episodes: filteredEpisodes)
            }.filter { !$0.episodes.isEmpty }
        }
    }
    
    func isFavorite(episodeId: Int) -> Bool {
        return allTehillimEpisode.first(where: { $0.id == episodeId })?.isFavorite ?? false
    }
    
    func toggleFavorite(for episodeId: Int) {
        if let index = allTehillimEpisode.firstIndex(where: { $0.id == episodeId }) {
            allTehillimEpisode[index].isFavorite.toggle()
            saveEpisodes()
        }
    }
}

struct TehillimEpisode: Identifiable, Hashable, Decodable, Encodable {
    var id: Int
    var name: String
    var isFavorite: Bool
}

struct EpisodeGroup: Identifiable, Hashable {
    var id = UUID()
    let title: String
    let episodes: [TehillimEpisode]
}

struct TehillimGroups {
    var days = [
        (title: "Day-1", range: 0..<29),
        (title: "Day-2", range: 29..<50),
        (title: "Day-3", range: 50..<72),
        (title: "Day-4", range: 72..<89),
        (title: "Day-5", range: 89..<106),
        (title: "Day-6", range: 106..<119),
        (title: "Day-7", range: 119..<150),
    ]
    
    var books = [
        (title: "Book-1", range: 0..<41),
        (title: "Book-2", range: 41..<72),
        (title: "Book-3", range: 72..<89),
        (title: "Book-4", range: 89..<106),
        (title: "Book-5", range: 106..<150),
    ]
}

func hebrewGematria(_ hebrew: String) -> Int {
    let letterValues: [Character: Int] = [
        "א": 1, "ב": 2, "ג": 3, "ד": 4, "ה": 5, "ו": 6, "ז": 7, "ח": 8, "ט": 9, "י": 10,
        "כ": 20, "ך": 20, "ל": 30, "מ": 40, "ם": 40, "נ": 50, "ן": 50, "ס": 60, "ע": 70, "פ": 80,
        "ף": 80, "צ": 90, "ץ": 90, "ק": 100, "ר": 200, "ש": 300, "ת": 400
    ]
    return hebrew.reduce(0) { $0 + (letterValues[$1] ?? 0) }
}
