import Foundation

class MainObserver: ObservableObject{
    
    @Published var entryList: [Entry] = EntryLoadManager.shared.loadEntries()
    
    func deleteEntry(_ entry: Entry) {
        // Mevcut listeden kaldır
        entryList.removeAll { $0.id == entry.id }
        // Güncellenmiş listeyi UserDefaults'a kaydet
        EntryLoadManager.shared.saveEntries(entryList)
    }
    
    

    @Published var lastPastCount: Int = UserDefaults.standard.integer(forKey: "lastPastCount")
}
