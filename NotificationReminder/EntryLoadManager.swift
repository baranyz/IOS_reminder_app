import Foundation

class EntryLoadManager {
    static let shared = EntryLoadManager() // Singleton instance for global access.
    private let entriesKey = "SavedEntries" // Key used to save/load the entries.
    
    // Function to save the entries to UserDefaults.
    func saveEntries(_ entries: [Entry]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(entries) // Attempt to encode the array of entries to Data.
            UserDefaults.standard.set(data, forKey: entriesKey) // Save the encoded Data to UserDefaults.
        } catch {
            print("Error saving entries: \(error)") // Error handling in case encoding fails.
        }
    }
    
    // Function to load the entries from UserDefaults.
    func loadEntries() -> [Entry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            return [] // Return an empty array if no data is found.
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([Entry].self, from: data) // Attempt to decode the Data back into an array of entries.
        } catch {
            print("Error loading entries: \(error)") // Error handling in case decoding fails.
            return [] // Return an empty array if decoding fails.
        }
    }
    
    // Function to remove an entry from the list of entries.
    func removeEntry(_ entry: Entry) {
        var entries = loadEntries() // Load the current list of entries.
        entries.removeAll(where: { $0.id == entry.id }) // Remove the entry with the specified ID.
        saveEntries(entries) // Save the updated list of entries.
    }
}
