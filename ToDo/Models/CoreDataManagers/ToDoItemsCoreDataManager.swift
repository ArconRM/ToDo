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
            var allItems = try _context.fetch(ToDoItem.fetchRequest())
            return allItems.filter({ $0.isDone })
        } catch {
            fatalError("Error fetching ToDo items")
        }
    }
    
//    public func getToDoItemsByLists() {
//        for list in ToDoItemsCoreDataManager.lists {
//            CoreDataManager.itemsByLists.append(list.items?.allObjects as! [ToDoItem])
//        }
//    }
    
    func deleteToDoItem(item: ToDoItem) {
        _context.delete(item)
        _appDelegate.saveContext()
    }
    
    func createToDoItem(text: String, date: Date, list: ToDoList, notificationCenter: UNUserNotificationCenter, notificationId: UUID) throws {
        if text == "" {
            throw InputErrors.emptyTaskInputError
        } else {
            let newItem = ToDoItem(context: _context)
            
            newItem.id = UUID()
            newItem.text = text
            newItem.isDone = false
            newItem.dateToRemind = date
            newItem.notificationId = notificationId
            newItem.notificationTitle = list.name
            
            ToDoListsCoreDataManager.shared.addItemToList(item: newItem, to: list)
            
            NotificationManager.shared.createNotification(notificationCenter: notificationCenter, title: list.name ?? "Error", body: text, selectedDate: date, id: notificationId)
            
            _appDelegate.saveContext()
        }
    }

    func updateItem(list: ToDoList, toDoItem: ToDoItem, newText: String, newDate: Date, notificationCenter: UNUserNotificationCenter, notificationId: UUID) throws {
        if newText == "" {
            throw InputErrors.emptyTaskInputError
        } else {
            toDoItem.text = newText
            toDoItem.dateToRemind = newDate
            toDoItem.notificationId = notificationId
            
            NotificationManager.shared.createNotification(notificationCenter: notificationCenter, title: list.name ?? "Error", body: newText, selectedDate: newDate, id: notificationId)
            
            _appDelegate.saveContext()
        }
    }
    
    func toggleItemIsDoneStatus(item: ToDoItem, notificationCenter: UNUserNotificationCenter) {
        item.isDone.toggle()
        
        if item.isDone {
//            ToDoListsCoreDataManager.shared.addItemToCompletedList(item: item)
            NotificationManager.shared.deleteNotification(notificationCenter: notificationCenter, id: item.notificationId!.uuidString)
        } else {
//            ToDoListsCoreDataManager.shared.removeItemFromCompletedList(item: item)
            NotificationManager.shared.createNotification(notificationCenter: notificationCenter, title: item.notificationTitle!, body: item.text!, selectedDate: item.dateToRemind!, id: item.notificationId!)
        }
        
        _appDelegate.saveContext()
    }
}
