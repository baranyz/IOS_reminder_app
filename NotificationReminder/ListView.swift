import SwiftUI


struct ListView: View {
    @State var isAddSheet: Bool = false
    @StateObject var mainObserver = MainObserver()
    @State var pastSawCount: Int = 0
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func loadAndSortEntries() {
        let allEntries = EntryLoadManager.shared.loadEntries()
        let sortedEntries = allEntries.sorted { $0.date < $1.date }
        self.mainObserver.entryList = sortedEntries
    }

    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(Array(groupedEntries.keys).sorted(by: { dateFormatter.date(from: $0)?.compare(dateFormatter.date(from: $1) ?? Date()) == .orderedAscending }), id: \.self) { date in
                        
                        let sectHead = dateNear(date: date)
                        
                        Section(header: Text(sectHead)) {
                            EntryListView(entries: groupedEntries[date] ?? [])
                                .environmentObject(mainObserver)
                        }
                    }
                }
                .navigationTitle("Upcoming")
                .navigationBarItems(leading:
                                        
                                        NavigationLink(destination: PastView()
                                            .environmentObject(mainObserver)
                                            .onDisappear{
                                                updateEntriesDate()
                                                pastCountEntry()
                                            }) {
                                            ZStack(alignment: .topTrailing) {
                                                Image(systemName: "clock.arrow.circlepath")
                                                    .font(.system(size: 20))
                                                    .font(.largeTitle)
                                                    .foregroundColor(.blue)
                                                    .padding(.all)

                                                
                                                if pastSawCount > 0 {
                                                    Text(String(pastSawCount))
                                                        .font(.caption2)
                                                        .foregroundColor(.white)
                                                        .padding(4)
                                                        .background(Color.red)
                                                        .clipShape(Circle())
                                                        .offset(x: -10, y: 10)
                                                }
                                            }
                                        }
,
                                    trailing:
                                        
                                        NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .padding(.all)
                    
                }
                )
                
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isAddSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 45))
                                .foregroundColor(.red)
                                .padding()
                                .shadow(radius: 1)
                        }
                    }
                }
                .padding()
                .edgesIgnoringSafeArea(.bottom)
            }
            .sheet(isPresented: $isAddSheet) {
                AddView()
                    .presentationDetents([.fraction(0.6)])
                    .presentationCornerRadius(40)
                    .shadow(radius: 3)
                    .environmentObject(mainObserver)
                    .onDisappear{
                        updateEntriesDate()
                        pastCountEntry()
                    }
                
            }
        }
        .onAppear{
            
            
            updateEntriesDate()
            
            loadAndSortEntries()
            
            pastCountEntry()
            
            
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
            
            
            if Calendar.current.date(from: dateComp1)! > Calendar.current.date(from: dateComp2)!{
                
                if groups[groupName] == nil {
                    groups[groupName] = []
                }
                
                groups[groupName]?.append(entry)
                
            }
      
            
        }
        return groups
    }
    
    private func pastCountEntry() {
        
        var countPastEntry: Int = 0
        
        for entry in mainObserver.entryList {
            
            
            var dateComp1 = DateComponents()
            dateComp1 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: entry.date)
            dateComp1.second = 0
            
            var dateComp2 = DateComponents()
            dateComp2 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: Date.now)
            dateComp2.second = 0
            
            
            if Calendar.current.date(from: dateComp1)! <= Calendar.current.date(from: dateComp2)!{
                
                countPastEntry += 1
            }
            
        }
        
        pastSawCount = countPastEntry - UserDefaults.standard.integer(forKey: "lastPastCount")
    }
    
    private func updateEntriesDate(){
        
        for inx in mainObserver.entryList.indices {
            
            let entry = mainObserver.entryList[inx]
            
            var dateComp1 = DateComponents()
            dateComp1 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: entry.date)
            dateComp1.second = 0
            
            var dateComp2 = DateComponents()
            dateComp2 = Calendar.current.dateComponents([.year ,.month ,.day, .hour, .minute], from: Date.now)
            dateComp2.second = 0
                
                
            if Calendar.current.date(from: dateComp1)! <= Calendar.current.date(from: dateComp2)! && entry.isRepeat{
                
                
                if entry.repeatInterval == .hourly {
                    
                    var dateComp = DateComponents()
                    dateComp = Calendar.current.dateComponents([.year ,.month ,.day, .hour], from: Date.now)
                    dateComp.minute = Calendar.current.component(.minute, from: entry.date)
                    dateComp.second = Calendar.current.component(.second, from: entry.date)
                    
                    var targetDate = Calendar.current.date(from: dateComp)
                    if targetDate! < Date.now{
                        
                        targetDate = Calendar.current.date(byAdding: .hour, value: 1, to: targetDate!)
                    }
                                            
                    let newEntry = Entry(date: targetDate!, title: entry.title, description: entry.description, isRemind: entry.isRemind, isRepeat: entry.isRepeat, notificationID: entry.notificationID, repeatInterval: entry.repeatInterval)
                    mainObserver.entryList.append(newEntry)
                    
                    mainObserver.entryList[inx].isRemind = false
                    mainObserver.entryList[inx].isRepeat = false
                    mainObserver.entryList[inx].notificationID = ""
                    mainObserver.entryList[inx].repeatInterval = nil
 
                }
                else if entry.repeatInterval == .daily {
                    
                    var dateComp = DateComponents()
                    dateComp = Calendar.current.dateComponents([.year ,.month ,.day], from: Date.now)
                    dateComp.hour = Calendar.current.component(.hour, from: entry.date)
                    dateComp.minute = Calendar.current.component(.minute, from: entry.date)
                    dateComp.second = Calendar.current.component(.second, from: entry.date)
                    
                    var targetDate = Calendar.current.date(from: dateComp)
                    if targetDate! < Date.now {
                        
                        targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate!)
                    }

                    let newEntry = Entry(date: targetDate!, title: entry.title, description: entry.description, isRemind: entry.isRemind, isRepeat: entry.isRepeat, notificationID: entry.notificationID, repeatInterval: entry.repeatInterval)
                    mainObserver.entryList.append(newEntry)
                    
                    mainObserver.entryList[inx].isRemind = false
                    mainObserver.entryList[inx].isRepeat = false
                    mainObserver.entryList[inx].notificationID = ""
                    mainObserver.entryList[inx].repeatInterval = nil
 
                }
                else if entry.repeatInterval == .weekly {
                    
                    var dateComp = DateComponents()
                    dateComp = Calendar.current.dateComponents([.year ,.month], from: Date.now)
                    dateComp.day = Calendar.current.component(.day, from: entry.date)
                    dateComp.hour = Calendar.current.component(.hour, from: entry.date)
                    dateComp.minute = Calendar.current.component(.minute, from: entry.date)
                    dateComp.second = Calendar.current.component(.second, from: entry.date)
                    
                    var targetDate = Calendar.current.date(from: dateComp)
                    if targetDate! < Date.now {
                        
                        targetDate = Calendar.current.date(byAdding: .day, value: 7, to: targetDate!)
                    }
                  
                    let newEntry = Entry(date: targetDate!, title: entry.title, description: entry.description, isRemind: entry.isRemind, isRepeat: entry.isRepeat, notificationID: entry.notificationID, repeatInterval: entry.repeatInterval)
                    mainObserver.entryList.append(newEntry)
                    
                    mainObserver.entryList[inx].isRemind = false
                    mainObserver.entryList[inx].isRepeat = false
                    mainObserver.entryList[inx].notificationID = ""
                    mainObserver.entryList[inx].repeatInterval = nil
 
                }
                else if entry.repeatInterval == .monthly {
                    
                    var dateComp = DateComponents()
                    dateComp = Calendar.current.dateComponents([.year, .month], from: Date.now)
                    dateComp.day = Calendar.current.component(.day, from: entry.date)
                    dateComp.hour = Calendar.current.component(.hour, from: entry.date)
                    dateComp.minute = Calendar.current.component(.minute, from: entry.date)
                    dateComp.second = Calendar.current.component(.second, from: entry.date)
                    
                    var targetDate = Calendar.current.date(from: dateComp)
                    if targetDate! < Date.now {
                        
                        targetDate = Calendar.current.date(byAdding: .month, value: 1, to: targetDate!)
                    }
                  
                    let newEntry = Entry(date: targetDate!, title: entry.title, description: entry.description, isRemind: entry.isRemind, isRepeat: entry.isRepeat, notificationID: entry.notificationID, repeatInterval: entry.repeatInterval)
                    mainObserver.entryList.append(newEntry)
                    
                    mainObserver.entryList[inx].isRemind = false
                    mainObserver.entryList[inx].isRepeat = false
                    mainObserver.entryList[inx].notificationID = ""
                    mainObserver.entryList[inx].repeatInterval = nil
 
                }
                else if entry.repeatInterval == .yearly {
                    
                    var dateComp = DateComponents()
                    dateComp = Calendar.current.dateComponents([.year], from: Date.now)
                    dateComp.month = Calendar.current.component(.month, from: entry.date)
                    dateComp.day = Calendar.current.component(.day, from: entry.date)
                    dateComp.hour = Calendar.current.component(.hour, from: entry.date)
                    dateComp.minute = Calendar.current.component(.minute, from: entry.date)
                    dateComp.second = Calendar.current.component(.second, from: entry.date)
                    
                    var targetDate = Calendar.current.date(from: dateComp)
                    if targetDate! < Date.now{
                        
                        targetDate = Calendar.current.date(byAdding: .year, value: 1, to: targetDate!)
                    }
                  
                    let newEntry = Entry(date: targetDate!, title: entry.title, description: entry.description, isRemind: entry.isRemind, isRepeat: entry.isRepeat, notificationID: entry.notificationID, repeatInterval: entry.repeatInterval)
                    mainObserver.entryList.append(newEntry)
                    
                    mainObserver.entryList[inx].isRemind = false
                    mainObserver.entryList[inx].isRepeat = false
                    mainObserver.entryList[inx].notificationID = ""
                    mainObserver.entryList[inx].repeatInterval = nil
 
                }
                
                
                
                mainObserver.entryList.sort { $0.date < $1.date}
                EntryLoadManager.shared.saveEntries(mainObserver.entryList)
                mainObserver.entryList = EntryLoadManager.shared.loadEntries()
            }
            
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
        
    }
}


struct EntryListView: View {
    var entries: [Entry]
    @State private var expandedEntryId: UUID?
    @EnvironmentObject var mainObserver: MainObserver

    
    var body: some View {
        ForEach(entries) { entry in
            
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack{
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack {
                        Text(entry.date.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                        
                        HStack (spacing:1){
                            if entry.isRemind {
                                Image(systemName: "bell.circle.fill")
                                    .font(.system(size: 12))
                            }
                            if entry.isRepeat {
                                Image(systemName: "repeat.circle.fill")
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
                
                
                Text(entry.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(expandedEntryId == entry.id ? nil : 3)
                
            }
            .onTapGesture {
                withAnimation(.smooth) {
                    
                    expandedEntryId = (expandedEntryId == entry.id ? nil : entry.id)
                }
            }
            .swipeActions {
                Button(role: .destructive) {
                    let notfID = entry.notificationID
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notfID])
                    mainObserver.deleteEntry(entry)
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            
            
            
        }
        
    }
}
