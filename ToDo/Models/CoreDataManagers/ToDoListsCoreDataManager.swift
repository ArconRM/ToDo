//
//  ToDoListsCoreDataManager.swift
//  ToDo
//
//  Created by Артемий on 12.08.2023.
//

import Foundation
import UIKit
import CoreData

public final class ToDoListsCoreDataManager: NSObject {
    private override init() { }
    
    public static let shared = ToDoListsCoreDataManager()
    
    private static var completedListIdKey = "CompletedListId"
    
    private var _appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var _context: NSManagedObjectContext {
        _appDelegate.persistentContainer.viewContext
    }
    
    private func encodeCompletedListId(id: UUID) {
        if let encoded = try? JSONEncoder().encode(id) {
            UserDefaults.standard.set(encoded, forKey: ToDoListsCoreDataManager.completedListIdKey)
        }
    }
    
    private func decodeCompletedListId() -> UUID {
        if let data = UserDefaults.standard.object(forKey: ToDoListsCoreDataManager.completedListIdKey) as? Data,
           let id = try? JSONDecoder().decode(UUID.self, from: data) {
            return id
        }
        fatalError()
    }
    
    public func createList(name: String, items: NSOrderedSet = NSOrderedSet()) throws {
        if !_checkListName(name: name) {
            throw InputErrors.invalidListNameError
        } else {
            var newList = ToDoList(context: _context)
            
            newList.id = UUID()
            newList.name = name
            newList.items = items
            
            _appDelegate.saveContext()
        }
    }
    
    private func _checkListName(name: String) -> Bool {
        let lists = fetchToDoLists()
        return name != "" && name.count <= 20 && !lists.contains(where: { list in list.name == name })
    }
    
    
    public func fetchToDoLists() -> [ToDoList] {
        do {
            var lists = try _context.fetch(ToDoList.fetchRequest())
            
            if _isFirstLaunch() {
                let completedList = ToDoList(context: _context)
                completedList.id = UUID()
                completedList.name = "Completed".localized()
                
                lists.append(completedList)
                _appDelegate.saveContext()
                encodeCompletedListId(id: completedList.id!)
            }
            return lists
        } catch {
            fatalError("Error fetching ToDo lists")
        }
    }
    
    func fetchToDoListsWithCompletedListBeingLast() -> [ToDoList] {
        do {
            var lists = try _context.fetch(ToDoList.fetchRequest())
            
            if _isFirstLaunch() {
                let completedList = ToDoList(context: _context)
                completedList.id = UUID()
                completedList.name = "Completed".localized()
                
                lists.append(completedList)
                _appDelegate.saveContext()
                encodeCompletedListId(id: completedList.id!)
            }
            
            lists = _moveCompletedListToEnd(array: lists)
            return lists
        } catch {
            fatalError("Error fetching ToDo lists")
        }
    }
    
    private func _isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            return false
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return true
        }
    }
    
    private func _moveCompletedListToEnd(array lists: [ToDoList]) -> [ToDoList] {
        var result = lists.filter({ !checkIfListIsCompleted($0) })
        let completedList = lists.first(where: { checkIfListIsCompleted($0) })!
        result.append(completedList)
        return result
    }
    
    
    //    public func getCompletedOrUncompletedItemsDependingOnList(list: ToDoList) -> [ToDoItem] {
    //        if list.id == decodeCompletedListId() {
    //            var allItems = ToDoItemsCoreDataManager.shared.fetchAllToDoItems()
    //            return allItems.filter({ $0.isDone })
    //        } else {
    //            return list.getUncompletedItems()
    //        }
    //    }
    
    
    public func updateListName(list: ToDoList, newName: String) throws {
        if !_checkListName(name: newName)
        {
            throw InputErrors.invalidListNameError
        }
        list.name = newName
        
        _appDelegate.saveContext()
    }
    
    public func addItemToList(item: ToDoItem, to list: ToDoList) {
        var array = list.getItems()
        array.append(item)
        list.items = NSOrderedSet(array: array )
        
        _appDelegate.saveContext()
    }
    
    //    public func addItemToCompletedList(item: ToDoItem) {
    //        var completedList = fetchToDoLists().first(where: { $0.id == decodeCompletedListId() })
    //        var array = completedList?.getItems()
    //        array?.append(item)
    //        completedList?.items = NSOrderedSet(array: array ?? [])
    //
    //        _appDelegate.saveContext()
    //    }
    
    //    public func removeItemFromCompletedList(item: ToDoItem) {
    //        var completedList = fetchToDoLists().first(where: { $0.id == decodeCompletedListId() })
    //        var array = completedList!.getItems()
    //        if let index = array.firstIndex(where: { $0.id == item.id }) {
    //            array.remove(at: index)
    //        }
    //        completedList?.items = NSOrderedSet(array: array )
    //
    //        _appDelegate.saveContext()
    //    }
    
    public func deleteList(_ list: ToDoList) {
        for item in list.getItems() {
            _context.delete(item)
        }
        _context.delete(list)
        
        _appDelegate.saveContext()
    }
    
    
    public func checkIfListIsCompleted(_ list: ToDoList) -> Bool {
        return list.id == decodeCompletedListId()
    }
}