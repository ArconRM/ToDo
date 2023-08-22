//
//  AddToDoItemViewController.swift
//  ToDo
//
//  Created by Aaron on 23.08.2022.
//

import Foundation
import UIKit
import UserNotifications

class AddOrUpdateToDoItemViewController: UIViewController, UITextFieldDelegate {
    
    enum Status: String {
        case unknown = "Error"
        case create = "Create"
        case update = "Update"
    }
    
    var selectedItem = ToDoItem()
    var selectedList = ToDoList()
    private var selectedDate = Date.now
    private var notificationId = UUID()
    var status = Status.unknown
    
    private let notificationCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var ToDoItemTextField: UITextField!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        ActionButton.setTitle(status.rawValue.localized(), for: .normal)
        
        switch status {
        case .create:
            createItem(text: ToDoItemTextField.text ?? "Error", date: selectedDate, list: selectedList)
        case .update:
            updateItem(toDoItem: selectedItem, newText: ToDoItemTextField.text ?? "Error", newDate: selectedDate, notificationId: notificationId)
        default:
            return
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func DidSelectDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ToDoItemTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ToDoItemTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGradientBackground()
        view.addBlurEffect()
        
        ToDoItemTextField.delegate = self
        ToDoItemTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter task".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        
        DatePickerView.locale = Locale.current
        
        if status == .update {
            ToDoItemTextField.text = selectedItem.text
            DatePickerView.date = selectedItem.dateToRemind ?? Date.now
        }
        
        ActionButton.setTitle(status.rawValue.localized(), for: .normal)
        ActionButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 24.0)
        ActionButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
    
    func updateItem(toDoItem: ToDoItem, newText: String, newDate: Date?, notificationId: UUID) {
        if newText == "" {
            let alert = UIAlertController(title: "Incorrect task".localized(), message: "It can't be empty".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            toDoItem.text = newText
            toDoItem.dateToRemind = newDate
            toDoItem.notificationId = notificationId
            
            createNotification(title: toDoItem.list?.name ?? "Error", body: newText, id: notificationId)
            
            do {
                try context.save()
            } catch {
                fatalError("Error updating ToDoItem")
            }
        }
    }
    
    func createItem(text: String, date: Date, list: ToDoList) {
        if text == "" {
            let alert = UIAlertController(title: "Incorrect task".localized(), message: "It can't be empty".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            do {
                let newItem = ToDoItem(context: context)
                
                newItem.text = text
                newItem.isDone = false
                newItem.dateToRemind = date
                newItem.list = list
                newItem.notificationId = notificationId
                
                var array = list.items?.allObjects
                array?.append(newItem)
                list.items = NSSet(array: array ?? [])
                
                createNotification(title: list.name ?? "Error", body: text, id: notificationId)
                
                try context.save()
            } catch {
                fatalError("Error adding ToDoItem")
            }
        }
    }
    
    func createNotification(title: String, body: String, id: UUID) {
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                
                let content  = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                    
                let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Unknown error")
                        return
                    }
                }
            }
        }
    }
}
