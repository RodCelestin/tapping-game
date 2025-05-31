import Foundation

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let score: Int
    let date: Date
    
    init(name: String, score: Int) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.date = Date()
    }
}

class LeaderboardService {
    private static let leaderboardKey = "gameLeaderboard"
    
    static func saveScore(name: String, score: Int) {
        var entries = getLeaderboard()
        let newEntry = LeaderboardEntry(name: name, score: score)
        entries.append(newEntry)
        
        // Sort by score in descending order
        entries.sort { $0.score > $1.score }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    static func getLeaderboard() -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }
} 