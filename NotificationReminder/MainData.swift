import Foundation

struct Entry: Codable, Identifiable, Hashable{
    
    var id = UUID()
    var date: Date
    var title: String
    var description: String
    var isRemind: Bool
    var isRepeat: Bool
    var notificationID: String = ""
    var repeatInterval: RepeatInterval?
}


enum RepeatInterval: String, Codable, CaseIterable {
    
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}
