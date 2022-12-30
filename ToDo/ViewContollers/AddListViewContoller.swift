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
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createList(name: AddTextField.text ?? "Error")
        _ = navigationController?.popViewController(animated: true)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createList(name: String) {
        if name == "" || name.count > 20 {
            let alert = UIAlertController(title: "Incorrect list name", message: "List name must contain from 1 to 20 symbols.", preferredStyle: .alert)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
