//
//  AddToDoItemViewController.swift
//  ToDo
//
//  Created by Aaron on 23.08.2022.
//

import Foundation
import UIKit

class AddToDoItemViewController: UIViewController {
    
    var selectedList = ToDoList()
    var selectedDate = Date.now
    
    @IBOutlet weak var AddTextField: UITextField!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createItem(text: AddTextField.text ?? "Error", isDone: false, date: selectedDate, list: selectedList)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SelectedDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    
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
