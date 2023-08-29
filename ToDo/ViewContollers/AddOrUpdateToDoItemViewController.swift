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
    
    private let _notificationCenter = UNUserNotificationCenter.current()
    
    private var _selectedDate: Date?
    private var _isSetToRemind = true
    
    var selectedItem = ToDoItem()
    var selectedList = ToDoList()
    var functionOfView = FunctionOfView.unknown
    
    @IBOutlet weak var ToDoItemTextField: UITextField!
    @IBOutlet weak var RemindSwitch: UISwitch!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    @IBOutlet weak var DateToRemindLabel: UILabel!
    
    @IBAction func RemindSwitchChanged(_ sender: UISwitch) {
        _isSetToRemind.toggle()
        if _isSetToRemind {
            UIView.transition(with: DatePickerView, duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: {
                                 self.DatePickerView.isHidden = false
                                 self.DateToRemindLabel.isHidden = false
                              })
        } else {
            UIView.transition(with: DatePickerView, duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: {
                                 self.DatePickerView.isHidden = true
                                 self.DateToRemindLabel.isHidden = true
                              })
        }
    }
    
    @IBAction func DidSelectDate(_ sender: UIDatePicker) {
        _selectedDate = sender.date
    }
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        ActionButton.setTitle(functionOfView.rawValue.localized(), for: .normal)
        
        switch functionOfView {
        case .create:
            do {
                if _isSetToRemind {
                    try ToDoItemsCoreDataManager.shared.createToDoItemWithDate(text: ToDoItemTextField.text ?? "Error",
                                                                               date: (_selectedDate ?? selectedItem.dateToRemind) ?? Date.now, // if date wasn't selected and item has date, date isn't changing, if date wasn't selected and item doesn't have date, setting default date
                                                                               list: selectedList,
                                                                               notificationCenter: _notificationCenter)
                } else {
                    try ToDoItemsCoreDataManager.shared.createToDoItemWithoutDate(text: ToDoItemTextField.text ?? "Error",
                                                                                  list: selectedList,
                                                                                  notificationCenter: _notificationCenter)
                }
            }
            catch InputErrors.emptyTaskError {
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
                if _isSetToRemind {
                    try ToDoItemsCoreDataManager.shared.updateItemTextWithDate(list: selectedList,
                                                                               item: selectedItem,
                                                                               newText: ToDoItemTextField.text ?? "Error",
                                                                               newDate: (_selectedDate ?? selectedItem.dateToRemind) ?? Date.now,
                                                                               notificationCenter: _notificationCenter)
                } else {
                    try ToDoItemsCoreDataManager.shared.updateItemTextWithoutDate(list: selectedList,
                                                                                  item: selectedItem,
                                                                                  newText: ToDoItemTextField.text ?? "Error",
                                                                                  notificationCenter: _notificationCenter)
                }
            }
            catch InputErrors.emptyTaskError {
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
            if selectedItem.dateToRemind != nil {
                DatePickerView.date = selectedItem.dateToRemind!
            } else {
                RemindSwitch.isOn = false
                DatePickerView.removeFromSuperview()
            }
        }
        
        ActionButton.setTitle(functionOfView.rawValue.localized(), for: .normal)
        ActionButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 24.0)
        ActionButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        _notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
}
