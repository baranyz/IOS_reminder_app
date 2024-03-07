import SwiftUI

struct PastView: View {
    @EnvironmentObject var mainObserver: MainObserver

    var body: some View {
        
        VStack{
            
            List {
                ForEach(Array(groupedEntries.keys).sorted(by: { dateFormatter.date(from: $0)?.compare(dateFormatter.date(from: $1) ?? Date()) == .orderedDescending }), id: \.self) { date in
                    
                    let sectHead = dateNear(date: date)
                    
                    Section(header: Text(sectHead)) {
                        EntryListView(entries: groupedEntries[date]?.reversed() ?? [])
                    }
                }
            }
            .navigationTitle("Past")
        }
        .onAppear{
            
            var countPastEntry: Int = 0
            
            for entry in mainObserver.entryList {
                
                
                var dateComp1 = DateComponents()
                dateComp1 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: entry.date)
                dateComp1.second = 0
                
                var dateComp2 = DateComponents()
                dateComp2 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: Date.now)
                dateComp2.second = 0
                    
                    
                if Calendar.current.date(from: dateComp1)! <= Calendar.current.date(from: dateComp2)! && !entry.isRepeat{
                    
                    countPastEntry += 1
                }
                
            }
            mainObserver.lastPastCount = countPastEntry
            UserDefaults.standard.set(countPastEntry ,forKey: "lastPastCount")
            
            
        }
    }
    
    
    private var groupedEntries: [String: [Entry]] {
        var groups: [String: [Entry]] = [:]
        
        
        for entry in mainObserver.entryList {
            
            let groupName = dateFormatter.string(from: entry.date)
            
            var dateComp1 = DateComponents()
            dateComp1 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: entry.date)
            dateComp1.second = 0
            
            var dateComp2 = DateComponents()
            dateComp2 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: Date.now)
            dateComp2.second = 0
                
                
            if Calendar.current.date(from: dateComp1)! <= Calendar.current.date(from: dateComp2)! && !entry.isRepeat{
                
                if groups[groupName] == nil {
                    groups[groupName] = []
                }
                
                groups[groupName]?.append(entry)
                
            }
            
        }
        return groups
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private func dateNear(date: String) -> String{
        
        if date == dateFormatter.string(from: Date()){
            return "Today"
        }
        else if date == dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!){
            return "Tomorrow"
        }
        else {
            return date
        }
    }
    


}

#Preview {
    PastView()
}
