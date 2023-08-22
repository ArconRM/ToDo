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
    
    enum FunctionOfView: String {
        case unknown = "Error"
        case create = "Create"
        case update = "Update"
    }
    
    private var _selectedDate = Date.now
    private var _notificationId = UUID()
    
    var selectedItem = ToDoItem()
    var selectedList = ToDoList()
    var functionOfView = FunctionOfView.unknown
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var ToDoItemTextField: UITextField!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        ActionButton.setTitle(functionOfView.rawValue.localized(), for: .normal)
        
        switch functionOfView {
        case .create:
            do {
                try ToDoItemsCoreDataManager.shared.createToDoItem(text: ToDoItemTextField.text ?? "Error", date: _selectedDate, list: selectedList, notificationCenter: notificationCenter, notificationId: _notificationId)
            }
            catch InputErrors.emptyTaskInputError {
                let alert = UIAlertController(title: "Incorrect task".localized(), message: "It can't be empty".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            catch {
                let alert = UIAlertController(title: "Incorrect task".localized(), message: "Unknown error".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        case .update:
            do {
                try ToDoItemsCoreDataManager.shared.updateItem(list: selectedList, toDoItem: selectedItem, newText: ToDoItemTextField.text ?? "Error", newDate: _selectedDate, notificationCenter: notificationCenter, notificationId: _notificationId)
            }
            catch InputErrors.emptyTaskInputError {
                let alert = UIAlertController(title: "Incorrect task".localized(), message: "It can't be empty".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            catch {
                let alert = UIAlertController(title: "Incorrect task".localized(), message: "Unknown error".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            return
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func DidSelectDate(_ sender: UIDatePicker) {
        _selectedDate = sender.date
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
        
        _configure()
    }
    
    private func _configure() {
        view.addGradientBackground()
        view.addBlurEffect()
        
        ToDoItemTextField.delegate = self
        ToDoItemTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter task".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        
        DatePickerView.locale = Locale.current
        
        if functionOfView == .update {
            ToDoItemTextField.text = selectedItem.text
            DatePickerView.date = selectedItem.dateToRemind ?? Date.now
        }
        
        ActionButton.setTitle(functionOfView.rawValue.localized(), for: .normal)
        ActionButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 24.0)
        ActionButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
}
