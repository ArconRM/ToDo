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
        do {
            try ToDoListsCoreDataManager.shared.createList(name: AddTextField.text ?? "Error")
        }
        catch {
            presentAlert()
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Incorrect list name".localized(), message: "List name must be unique and contain from 1 to 20 symbols".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _configure()
    }
    
    private func _configure() {
        view.addGradientBackground()
        view.addBlurEffect()
        
        AddTextField.delegate = self
        AddTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter list name".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        CreateButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 24.0)
        CreateButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AddTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
