//
//  RemindManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit
import UserNotifications

class RemindManager {
    
    static let shared = RemindManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    func setRemind(_ plant: Plant, remindDict: [ReminderType: (Int, Date?)]) {
        
        for (key, value) in remindDict {
            if value.0 == 0 {
                center.removePendingNotificationRequests(withIdentifiers: ["\(plant.id): \(key.rawValue)notification"])
                continue
            }
            
            let content = UNMutableNotificationContent()
            
            content.title = "\(key.rawValue)提醒"
            
            content.body = "\(plant.name)要\(key.rawValue)囉！"
            
            guard let settingDate = value.1 else { continue }
            
            let date = settingDate.addingTimeInterval(TimeInterval(value.0 * 24 * 60 * 60))
            
//            let testDate = settingDate.addingTimeInterval(TimeInterval(5))
            
            let dailyTrigger = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dailyTrigger,
                                                        repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(plant.id): \(key.rawValue)notification",
                                                content: content,
                                                trigger: trigger)
            
            center.add(request) { error in
                
                guard let error = error
                else {
                    print("Success remind")
                    return
                }
                
                print(error)
            }
        }
    }
    
    func deleteReminder(plantID: String) {
        for reminderType in ReminderType.allCases {
            center.removePendingNotificationRequests(
                withIdentifiers: ["\(plantID): \(reminderType.rawValue)notification"])
        }
    }
}
