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
    
    func setRemind(_ plant: Plant, remindDict: [ReminderType: Int]) {
        
        for (key, value) in remindDict {
            if value == 0 { continue }
            let content = UNMutableNotificationContent()
            content.title = "\(key.rawValue)提醒"
            content.body = "\(plant.name)要\(key.rawValue)囉！"
            
            let date = Date(timeIntervalSinceNow: TimeInterval(36000 * value))
            
            let dailyTrigger = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dailyTrigger,
                                                        repeats: true)
            
            let request = UNNotificationRequest(identifier: "\(plant.id): \(key.rawValue)notification",
                                                content: content,
                                                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard let error = error
                else {
                    print("Success remind")
                    return
                }
                
                print(error)
            }
        }
    }
}
