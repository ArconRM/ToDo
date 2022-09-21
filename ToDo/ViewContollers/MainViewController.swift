//
//  ViewController.swift
//  ToDo
//
//  Created by Aaron on 12.08.2022.
//

import UIKit

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

var deletedItems = ToDoList()

var allItems = [ToDoItem]()

class MainViewController: UIViewController {
    
    @IBOutlet weak var todayTableView: UITableView!
    @IBOutlet weak var listsTableView: UITableView!
    
    private var lists = [ToDoList]()
    
    private let todayTableViewIdCell = "todayCell"
    private let listsTableViewIdCell = "listsCell"
    private var selectedList = ToDoList()
    
    var count = 0
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllItems()
        fetchLists()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchAllItems()
//        fetchLists()
        
        todayTableView.delegate = self
        listsTableView.delegate = self
        todayTableView.dataSource = self
        listsTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromMainToItems") {
            let vc = segue.destination as! ListItemsViewController
            vc.selectedList = selectedList
        }
    }
    
    func fetchAllItems() {
        do {
            allItems = try context.fetch(ToDoItem.fetchRequest())
            DispatchQueue.main.async {
                self.todayTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching ToDoItems")
        }
    }
    
    func fetchLists() {
        do {
            lists = try context.fetch(ToDoList.fetchRequest())
            DispatchQueue.main.async {
                self.listsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching lists")
        }
    }

    func deleteItem(toDoItem: ToDoItem) {
        context.delete(toDoItem)

        do {
            try context.save()
        } catch {
            fatalError("Error deleting ToDoItem")
        }
    }

    func changeItem(toDoItem: ToDoItem, newText: String, newIsDone: Bool, newDate: Date?, newList: ToDoList?) {
        toDoItem.text = newText
        toDoItem.isDone = newIsDone
        toDoItem.dateToRemind = newDate
        toDoItem.list = newList

        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
    }
}


class CustomToDoItemCell: UITableViewCell {
    @IBOutlet weak var toDoItemCellLabel: UILabel!
}

class CustomToDoListCell: UITableViewCell {
    @IBOutlet weak var toDoListCellLabel: UILabel!
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == listsTableView {
            selectedList = lists[indexPath.row]
            performSegue(withIdentifier: "SegueFromMainToItems", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == todayTableView {
            return allItems.count
        } else if tableView == listsTableView {
            return lists.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == todayTableView {
            
            let item = allItems[indexPath.row]
            
            let cell: CustomToDoItemCell = self.todayTableView.dequeueReusableCell(withIdentifier: todayTableViewIdCell) as! CustomToDoItemCell
            cell.toDoItemCellLabel?.text = item.text
            
            return cell
        } else if tableView == listsTableView {
            
            let list = lists[indexPath.row]
            
            let cell: CustomToDoListCell = self.listsTableView.dequeueReusableCell(withIdentifier: listsTableViewIdCell) as! CustomToDoListCell
            cell.toDoListCellLabel?.text = list.name
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
