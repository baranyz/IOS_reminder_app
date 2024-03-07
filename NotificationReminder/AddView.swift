import SwiftUI
import StoreKit

struct AddView: View {
    @State var textTitle: String = ""
    @State var textDescription: String = ""
    @State var selectedDate: Date = Date.now
    @State var isRepeat: Bool = false
    @State var isRemind: Bool = true
    @State var isExpanded = false
    @State var remindMeList = ["Today","Tomorrow"]
    @State private var selectionOfRemindme = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTime = Calendar.current.date(byAdding: .hour, value: 0, to: Calendar.current.date(bySetting: .minute, value: 0, of: Date()) ?? Date()) ?? Date()
    
    @EnvironmentObject var mainObserver: MainObserver

    @State private var selectionRepeatInterval: RepeatInterval = .daily


    
    var body: some View {
        
        VStack {
            
            HStack {
                Button(action:{
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                .padding()
                            
                Spacer()
                            
                Button(action:{
                    
                    if !isExpanded {
                        if selectionOfRemindme == 0{
                            selectedDate = Calendar.current.date(byAdding: .day, value: 0, to: Date.now)!
                        }
                        else{
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
                        }
                    }
                    
                    var newDate = DateComponents()
                    newDate = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
                    newDate.hour = Calendar.current.component(.hour, from: selectedTime)
                    newDate.minute = Calendar.current.component(.minute, from: selectedTime)
                    
                    let newEntry = Entry(date: Calendar.current.date(from: newDate)!, title: textTitle, description: textDescription, isRemind: isRemind, isRepeat: isRepeat, repeatInterval: selectionRepeatInterval)
                    
                    mainObserver.entryList.append(newEntry)
                    mainObserver.entryList.sort { $0.date < $1.date}
                    EntryLoadManager.shared.saveEntries(mainObserver.entryList)
                    mainObserver.entryList = EntryLoadManager.shared.loadEntries()
                    

                    if isRepeat {
                        scheduleRepeatNotification(at: Calendar.current.date(from: newDate)!,title: textTitle, description: textDescription, repeatInterval: selectionRepeatInterval, entryID: newEntry.id)
                    }
                    else{
                        scheduleNotification(at: Calendar.current.date(from: newDate)!,title: textTitle, description: textDescription, entryID: newEntry.id)
                    }
                    
                    
                    
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    
                    ZStack{
                       
                        Text("Save")
                            .foregroundColor(textDescription.count > 0 ? .blue : .gray)
                    }
                }
                .padding()
                .disabled(textDescription.count == 0)
                
                
            }
            Spacer()
                
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 10)
                    .size(CGSize(width: 300, height: 50))
                    .foregroundColor(.white)
                
                
                TextField("Title (optional)", text: $textTitle)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(.all)
                    .colorScheme(.light)
            }
            .frame(maxWidth: 300,maxHeight:50)
            .shadow(radius: 10)
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 10)
                    .size(CGSize(width: 300, height: 50))
                    .foregroundColor(.white)
                
                
                TextField("Description", text: $textDescription)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(.all)
                    .colorScheme(.light)
            }
            .frame(maxWidth: 300,maxHeight:50)
            .shadow(radius: 10)
            
            if !isExpanded{
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    //Image(systemName: "bell.circle.fill")
                    //Text("Remind me   ")
                        //.foregroundColor(.black.opacity(0.8))
                    Picker(selection: $selectionOfRemindme, label: Text("Remind me")) {
                                    ForEach(0..<2) { index in
                                        Text(self.remindMeList[index]).tag(index)
                                    }
                                }
                        .pickerStyle(PalettePickerStyle())
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Text("Time:")
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                }
                .padding(.all)
                .shadow(radius: 10)
                
                
            }
            
            
            Button(action: {
                            self.isExpanded.toggle()
                        }) {
                            HStack {
                                Text("Advanced Options")
                                    .font(.caption)
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .animation(.easeIn)
                            }
                            .padding()
                            .shadow(radius: 2)
                        }
                        
                        if isExpanded {
                            
                            if selectionRepeatInterval != .hourly{
                               
                                HStack{
                                    DatePicker("Time", selection: $selectedDate, displayedComponents: .date)
                                    
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    
                                    Text("Time:")
                                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                                    .labelsHidden()
                                    
                                }
                                .padding(.horizontal,45)
                            }
                        
                            
                             
                            HStack{
                                Spacer()
                                Spacer()

                        
                                VStack{
                                    Toggle("Repeat", isOn: $isRepeat)
                                        .frame(maxWidth:115)
                                        .padding(.all)
                                    
                                    if isRepeat{
                                        Picker(selection: $selectionRepeatInterval, label: Text("Remind")) {
                                            ForEach(RepeatInterval.allCases, id: \.self) { interval in
                                                Text(interval.rawValue).tag(interval)
                                                    }
                                                }
                                                .pickerStyle(MenuPickerStyle())
                                       
                                    }
                                    Spacer()
                                    
                                }
                                
                                Spacer()
                                
                                VStack{
                                    Toggle("Remind", isOn: $isRemind)
                                        .frame(maxWidth:115)
                                        .padding(.all)
                                    
                                        Spacer()
                                                                           
                                }
                                
                                Spacer()
                                Spacer()
                                Spacer()

                            }
                            
                           
      
                        }

            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
  
        .onAppear(){
            
            requestNotificationPermissions()
            
        }
        .onDisappear{
            
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
  

        
    func scheduleRepeatNotification(at date: Date, title: String, description: String, repeatInterval: RepeatInterval, entryID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = description
        content.sound = .default
        
        
        let trigger: UNNotificationTrigger
        switch repeatInterval {
        case .hourly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([ .minute, .second], from: date), repeats: true)
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour ,.minute, .second], from: date), repeats: true)
        case .weekly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.weekday ,.hour ,.minute, .second], from: date), repeats: true)
        case .monthly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day ,.hour ,.minute, .second], from: date), repeats: true)
        case .yearly:
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.month, .day ,.hour ,.minute, .second], from: date), repeats: true)
        }
        
        // Bildirimi planla
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim başarıyla planlandı!")
                
                DispatchQueue.main.async {
                    
                    for inx in mainObserver.entryList.indices {
                        
                        if mainObserver.entryList[inx].id == entryID{
                            
                            mainObserver.entryList[inx].notificationID = request.identifier
 
                        }
                    }
                }
            }
        }
    }
    
    func scheduleNotification(at date: Date, title: String, description: String, entryID: UUID) {
        
        if date <= Date.now {
            print("Date cannot before then now!")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = description
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year ,.month ,.day ,.hour, .minute], from: date), repeats: false)
    
        
        // Bildirimi planla
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim başarıyla planlandı!")
                
                DispatchQueue.main.async {
                    
                    for inx in mainObserver.entryList.indices {
                        
                        if mainObserver.entryList[inx].id == entryID{
                            
                            mainObserver.entryList[inx].notificationID = request.identifier

                        }
                    }
                }

            }
        }
    }
    
 




    func requestReview() {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    func requestNotificationPermissions() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permissions granted")
                } else if let error = error {
                    print("Error requesting notification permissions: \(error.localizedDescription)")
                }
            }
        }
    
}

#Preview {
    AddView()
        
}
