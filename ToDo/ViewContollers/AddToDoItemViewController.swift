//
//  AddToDoItemViewController.swift
//  ToDo
//
//  Created by Aaron on 23.08.2022.
//

import Foundation
import UIKit

class AddToDoItemViewController: UIViewController {
    
    @IBOutlet weak var AddTextField: UITextField!
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createItem(text: AddTextField.text ?? "Error", isDone: false, date: Date.now, list: selectedList)
        _ = navigationController?.popViewController(animated: true)
    }
    
    var selectedList = ToDoList()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createItem(text: String, isDone: Bool, date: Date?, list: ToDoList?) {
        var newItem = ToDoItem(context: context)

        newItem.text = text
        newItem.isDone = isDone
        newItem.dateToRemind = date
        newItem.list = list

        do {
            try context.save()
        } catch {
            fatalError("Error adding ToDoItem")
        }
    }
}
