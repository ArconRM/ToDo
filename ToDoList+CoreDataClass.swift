//
//  ToDoList+CoreDataClass.swift
//  ToDo
//
//  Created by Aaron on 12.08.2022.
//
//

import Foundation
import CoreData

@objc(ToDoList)
public class ToDoList: NSManagedObject {
    
    public func getItems() -> [ToDoItem] {
        return self.items?.array as! [ToDoItem]
    }
    
    public func getUncompletedItems() -> [ToDoItem] {
        return self.getItems().filter({ !$0.isDone })
    }
}
