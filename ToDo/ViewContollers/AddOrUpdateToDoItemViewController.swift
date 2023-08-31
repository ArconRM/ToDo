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
    
    @IBOutlet weak var ToDoItemTextField: UITextField!
    @IBOutlet weak var RemindSwitch: UISwitch!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    @IBOutlet weak var DateToRemindLabel: UILabel!
    
    private let _notificationCenter = UNUserNotificationCenter.current()
    
    private var _selectedDate: Date?
    private var isSetToRemind: Bool!
    
    var selectedItem = ToDoItem()
    var selectedList = ToDoList()
    var functionOfView = FunctionOfView.unknown
    
    @IBAction func RemindSwitchChanged(_ sender: UISwitch) {
        isSetToRemind.toggle()
        
        if isSetToRemind {
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
        switch functionOfView {
        case .create:
            do {
                if isSetToRemind {
                    try ToDoItemsCoreDataManager.shared.createToDoItemWithDate(text: ToDoItemTextField.text ?? "Error",
                                                                               date: (_selectedDate ?? selectedItem.dateToRemind) ?? Date.now,
                                                                               // if date wasn't selected and item has date, date isn't changing, if date wasn't selected and item doesn't have date, setting default date
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
                if isSetToRemind {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
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
                RemindSwitch.isOn = true
                DatePickerView.date = selectedItem.dateToRemind!
                isSetToRemind = true
            } else {
                RemindSwitch.isOn = false
                isSetToRemind = false
            }
            DatePickerView.isHidden = !isSetToRemind
            DateToRemindLabel.isHidden = !isSetToRemind
        } else {
            DatePickerView.isHidden = true
            DateToRemindLabel.isHidden = true
        }
        
        ActionButton.setTitle(functionOfView.rawValue.localized(), for: .normal)
        ActionButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        ActionButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        _notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted)
            {
                print("Permission Denied")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ToDoItemTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ToDoItemTextField.resignFirstResponder()
        return true
    }
}
