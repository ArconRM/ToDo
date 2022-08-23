//
//  AddListViewContoller.swift
//  ToDo
//
//  Created by Aaron on 14.08.2022.
//

import Foundation
import UIKit

class AddListViewContoller: UIViewController {
    
    @IBOutlet weak var AddTextField: UITextField!
    
    @IBAction func CreatePressed(_ sender: UIButton) {
        createList(name: AddTextField.text ?? "Error")
        _ = navigationController?.popViewController(animated: true)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createList(name: String) {
        if (name != "") {
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
}
