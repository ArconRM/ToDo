//
//  AddListViewContoller.swift
//  ToDo
//
//  Created by Aaron on 14.08.2022.
//

import Foundation
import UIKit

class AddListViewContoller: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var AddTextField: UITextField!
    @IBOutlet weak var CreateButton: UIButton!
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createList(name: AddTextField.text ?? "Error")
        _ = navigationController?.popViewController(animated: true)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createList(name: String) {
        if name == "" || name.count > 20 || lists.contains(where: { list in list.name == name }) {
            let alert = UIAlertController(title: "Incorrect list name".localized(), message: "List name must be unique and contain from 1 to 20 symbols".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            var newList = ToDoList(context: context)
            
            newList.name = name
            newList.items = []
            
            do {
                try context.save()
            } catch {
                fatalError("Error adding ToDoItem")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AddTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGradientBackground()
        view.addBlurEffect()
        
        AddTextField.delegate = self
        AddTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter list".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        CreateButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 24.0)
        CreateButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
