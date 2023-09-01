//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Артемий on 11.08.2023.
//

import Foundation
import UIKit
import CoreData

public final class ToDoItemsCoreDataManager: NSObject {
    private override init() { }
    
    public static let shared = ToDoItemsCoreDataManager()
    
    private var _appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var _context: NSManagedObjectContext {
        _appDelegate.persistentContainer.viewContext
    }
    
    public func fetchAllToDoItems() -> [ToDoItem] {
        do {
            return try _context.fetch(ToDoItem.fetchRequest())
        } catch {
            fatalError("Error fetching ToDo items")
        }
    }
    
    public func fetchCompletedToDoItems() -> [ToDoItem] {
        do {
            let allItems = try _context.fetch(ToDoItem.fetchRequest())
            return allItems.filter({ $0.isDone })
        } catch {
            fatalError("Error fetching ToDo items")
        }
    }
    
    public func fetchUncompletedToDoItems() -> [ToDoItem] {
        do {
            let allItems = try _context.fetch(ToDoItem.fetchRequest())
            return allItems.filter({ !$0.isDone })
        } catch {
            fatalError("Error fetching ToDo items")
        }
    }
    
    func createToDoItemWithDate(text: String, date: Date, list: ToDoList, notificationCenter: UNUserNotificationCenter) throws {
        if text == "" {
            throw InputErrors.emptyTaskError
        } else {
            let newItem = ToDoItem(context: _context)
            let notificationId = UUID()
            
            newItem.id = UUID()
            newItem.text = text
            newItem.isDone = false
            newItem.dateToRemind = date
            newItem.notificationId = notificationId
            newItem.notificationTitle = list.name
            
            ToDoListsCoreDataManager.shared.addItemToList(item: newItem, to: list)
            NotificationManager.shared.createNotification(notifId: notificationId,
                                                          title: list.name ?? "Error",
                                                          body: text,
                                                          selectedDate: date)
            
            _appDelegate.saveContext()
        }
    }
    
    func createToDoItemWithoutDate(text: String, list: ToDoList, notificationCenter: UNUserNotificationCenter) throws {
        if text == "" {
            throw InputErrors.emptyTaskError
        } else {
            let newItem = ToDoItem(context: _context)
            let notificationId = UUID()
            
            newItem.id = UUID()
            newItem.text = text
            newItem.isDone = false
            newItem.notificationId = notificationId
            newItem.notificationTitle = list.name
            
            ToDoListsCoreDataManager.shared.addItemToList(item: newItem, to: list)
            
            _appDelegate.saveContext()
        }
    }
    
    
    func updateItemTextWithUpdatingDate(item: ToDoItem, newText: String, newDate: Date, listName: String,  notificationCenter: UNUserNotificationCenter) throws {
        if newText == "" {
            throw InputErrors.emptyTaskError
        } else {
            if item.dateToRemind != nil {
                NotificationManager.shared.deleteNotification(notificationCenter: notificationCenter, id: item.notificationId!.uuidString)
            }
            
            item.text = newText
            item.dateToRemind = newDate
            
            NotificationManager.shared.createNotification(notifId: item.notificationId!,
                                                          title: listName,
                                                          body: newText,
                                                          selectedDate: newDate)
            
            _appDelegate.saveContext()
        }
    }
    
    func updateItemTextWithoutUpdatingDate(item: ToDoItem, newText: String, notificationCenter: UNUserNotificationCenter) throws {
        if newText == "" {
            throw InputErrors.emptyTaskError
        } else {
            if item.dateToRemind != nil {
                NotificationManager.shared.deleteNotification(notificationCenter: notificationCenter,
                                                              id: item.notificationId!.uuidString)
            }
            item.dateToRemind = nil
            item.text = newText
            
            _appDelegate.saveContext()
        }
    }
    
    func toggleItemIsDoneStatus(item: ToDoItem, notificationCenter: UNUserNotificationCenter) {
        item.isDone.toggle()
        
        if item.dateToRemind != nil {
            if item.isDone {
                NotificationManager.shared.deleteNotification(notificationCenter: notificationCenter,
                                                              id: item.notificationId!.uuidString)
            } else {
                NotificationManager.shared.createNotification(notifId: item.notificationId!,
                                                              title: item.notificationTitle!,
                                                              body: item.text!,
                                                              selectedDate: item.dateToRemind!)
            }
        }
        
        _appDelegate.saveContext()
    }
    
    func deleteToDoItem(item: ToDoItem, list: ToDoList, notificationCenter: UNUserNotificationCenter) {
        _context.delete(item)
        NotificationManager.shared.deleteNotification(notificationCenter: notificationCenter, id: item.notificationId?.uuidString ?? "")
        
        ToDoListsCoreDataManager.shared.removeItemFromList(item: item, list: list)
        
        _appDelegate.saveContext()
    }
}
