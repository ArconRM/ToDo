//
//  NotificationManager.swift
//  ToDo
//
//  Created by Артемий on 12.08.2023.
//

import Foundation
import UIKit

public final class NotificationManager {
    private init() { }
    
    public static var shared = NotificationManager()
    
    public func createNotification(notificationCenter: UNUserNotificationCenter, title: String, body: String, selectedDate: Date, id: UUID) {
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                
                let content  = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                
                let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Unknown error")
                        return
                    }
                }
            }
        }
    }
    
    public func deleteNotification(notificationCenter: UNUserNotificationCenter, id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
