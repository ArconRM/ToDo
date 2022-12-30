//
//  AddToDoItemViewController.swift
//  ToDo
//
//  Created by Aaron on 23.08.2022.
//

import Foundation
import UIKit
import UserNotifications

class AddToDoItemViewController: UIViewController {
    
    var selectedList = ToDoList()
    var selectedDate = Date.now
    
    let notificationCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var AddTextField: UITextField!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createItem(text: AddTextField.text ?? "Error", date: selectedDate, list: selectedList)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SelectedDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
    
    func createItem(text: String, date: Date?, list: ToDoList?) {
        if text == "" || text.count > 20 {
            let alert = UIAlertController(title: "Incorrect list name", message: "List name must contain from 1 to 20 symbols.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            let newItem = ToDoItem(context: context)
            
            newItem.text = text
            newItem.isDone = false
            newItem.dateToRemind = date
            newItem.list = list
            
            do {
                try context.save()
            } catch {
                fatalError("Error adding ToDoItem")
            }
            
            createNotification(title: list?.name ?? "Error", body: text)
        }
    }
    
    func createNotification(title: String, body: String) {
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                
                let content  = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                    
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
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
