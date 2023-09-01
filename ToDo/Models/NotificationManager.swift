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
    
    public func createNotification(notifId: UUID, title: String, body: String, selectedDate: Date) {
        let notificationCenter = configureNotificationCenter()
        
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                
                let content  = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = UNNotificationCategoryIds.SetCompletedCategoryId.rawValue //ToDo: add functionality
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                
                let request = UNNotificationRequest(identifier: notifId.uuidString, content: content, trigger: trigger)
                
                notificationCenter.add(request)
            }
        }
    }
    
    private func configureNotificationCenter() -> UNUserNotificationCenter {
        let notifCenter = UNUserNotificationCenter.current()
        
        let setCompletedAction = UNNotificationAction(identifier: UNNotificationActionIds.SetCompletedActionId.rawValue,
                                                      title: "Set completed".localized(),
                                                      options: [],
                                                      icon: UNNotificationActionIcon(systemImageName: "checkmark.circle.fill"))
        
        let setCompletedCategory = UNNotificationCategory(identifier: UNNotificationCategoryIds.SetCompletedCategoryId.rawValue,
                                                          actions: [setCompletedAction],
                                                          intentIdentifiers: [])
        
        notifCenter.setNotificationCategories([setCompletedCategory])
        return notifCenter
    }
    
    public func deleteNotification(notificationCenter: UNUserNotificationCenter, id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
