//
//  ListItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 14.08.2022.
//

import Foundation
import UIKit

class ListItemsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ItemsTableView: UITableView!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var ListNameTextField: UITextField!
    
    private var listItems = [ToDoItem]()
    private let cellId = "ToDoItem"
    var selectedList = ToDoList()
    var selectedItem = ToDoItem()
    
    let NoItemsLabel = UILabel.init()
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchToDoItems()
        fetchListItems()
        
        if listItems.count == 0 {
            NoItemsLabel.frame = CGRect(x: 10.0, y: self.view.frame.height / 2, width: self.view.frame.width - 20.0, height: 50)
            NoItemsLabel.text = "No tasks here :(".localized()
            NoItemsLabel.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 25.0)
            NoItemsLabel.textAlignment = .center
            NoItemsLabel.textColor = .white
            self.view.addSubview(NoItemsLabel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NoItemsLabel.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ListNameTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ListNameTextField.delegate = self
        ListNameTextField.text = selectedList.name
        ListNameTextField.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 44.0)
        
        ItemsTableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
        
        if selectedList.name == completedName {
            AddButton.removeFromSuperview()
        }
        AddButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 20.0)
        AddButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromItemsToAddItem") {
            let vc = segue.destination as! AddToDoItemViewController
            vc.selectedList = selectedList
            vc.status = .create
        } else if (segue.identifier == "SegueFromItemsToUpdateItem") {
            let vc = segue.destination as! AddToDoItemViewController
            vc.selectedList = selectedList
            vc.selectedItem = selectedItem
            vc.status = .update
        }
    }
    
    func fetchListItems() {
        do {
            if selectedList.name == completedName {
                listItems = allItems.filter {$0.isDone == true}
            } else {
                listItems = allItems.filter {$0.list?.id == selectedList.id && !$0.isDone}
            }
            DispatchQueue.main.async {
                self.ItemsTableView.reloadData()
            }
        }
    }

    func deleteItem(toDoItem: ToDoItem) {
        context.delete(toDoItem)
        do {
            DispatchQueue.main.async {
                self.ItemsTableView.reloadData()
            }
            try context.save()
        } catch {
            fatalError("Error deleting ToDoItem")
        }
    }
    
    @IBAction func ListNameBeganChanging(_ sender: UITextField) {
        if selectedList.name == completedName {
            let alert = UIAlertController(title: "Forbidden", message: "You can't change this list name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func ListNameEndedChanging(_ sender: UITextField) {
        if sender.text != "" && !lists.contains(where: {$0.name == sender.text}) && sender.text!.count <= 20 {
            selectedList.name = sender.text
            
            do {
                try context.save()
            } catch {
                fatalError("Error updating ToDoItem")
            }
            
        } else {
            let alert = UIAlertController(title: "Incorrect list name", message: "List name must be unique and contain from 1 to 20 symbols.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func DeleteListPressed(_ sender: Any) {
        if selectedList.name == completedName {
            let alert = UIAlertController(title: "Forbidden", message: "You can't delete this list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Are you sure?", message: "You are going to delete this list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                do {
                    for item in self.selectedList.items?.allObjects as! [ToDoItem] {
                        context.delete(item)
                    }
                    context.delete(self.selectedList)
                    try context.save()
                    
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                }
                catch {
                    fatalError("Error deleting list and it's items.")
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedList.name != completedName {
            selectedItem = listItems[indexPath.row]
            performSegue(withIdentifier: "SegueFromItemsToUpdateItem", sender: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = listItems[indexPath.row]
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        let cell: ToDoTableViewCell = self.ItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! ToDoTableViewCell
        
        cell.ToDoItemLabel.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
        cell.item = item
        
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 30, height: cell.bounds.height)
        
        let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
        shapeLayer.path = maskPath.cgPath
        cell.layer.mask = shapeLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.lineWidth = 4
        borderLayer.frame = cell.bounds
        cell.layer.addSublayer(borderLayer)
        
//        cell.layer.borderWidth = 1 // сбрасывается при свайпе
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            self.deleteItem(toDoItem: self.listItems[indexPath.row])
            fetchToDoItems()
            self.fetchListItems()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
        
    }
    
}

