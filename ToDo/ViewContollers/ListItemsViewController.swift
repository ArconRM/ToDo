//
//  ListItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 14.08.2022.
//

import Foundation
import UIKit

class ListItemsViewController: UIViewController {
    
    @IBOutlet weak var ItemsTableView: UITableView!
    @IBOutlet weak var ListName: UILabel!
    @IBOutlet weak var NoItemsLabel: UILabel!
    
    private var items = [ToDoItem]()
    private let cellId = "listItem"
    var selectedList = ToDoList()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBAction func AddNewTaskPressed(_ sender: UIButton) {        
        createItem(text: "fuckfuckfuck", isDone: false, date: Date.now, list: selectedList)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        <#code#>
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ListName.text = selectedList.name
        
        fetchListItems()
        
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
        
        if items.count > 0 {
            NoItemsLabel.text = ""
        }
    }
    
    func fetchListItems() {
        do {
            items = try context.fetch(ToDoItem.fetchRequest()).filter {$0.list?.name == selectedList.name}
            DispatchQueue.main.async {
                self.ItemsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching ToDoItems")
        }
    }
    
    func createItem(text: String, isDone: Bool, date: Date?, list: ToDoList?) {
        var newItem = ToDoItem(context: context)

        newItem.text = text
        newItem.isDone = isDone
        newItem.dateToRemind = date
        newItem.list = list

        do {
            try context.save()
            fetchListItems()
        } catch {
            fatalError("Error adding ToDoItem")
        }
    }
}

class CustomListItemCell: UITableViewCell {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var item = ToDoItem()
    
    @IBOutlet weak var ListItemTextField: UITextField!
    
    @IBAction func ItemIsChanging(_ sender: UITextField) {
        item.text = sender.text ?? "Error"
        
        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
    }
}

extension ListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell: CustomListItemCell = self.ItemsTableView.dequeueReusableCell(withIdentifier: cellId) as! CustomListItemCell
        cell.ListItemTextField.text = item.text
        cell.item = item
        
        return cell
    }
}

