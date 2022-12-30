//
//  ViewController.swift
//  ToDo
//
//  Created by Aaron on 12.08.2022.
//

import UIKit

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

var deletedItems = ToDoList() // массивых выполненных элементов
var allItems = [ToDoItem]() // массив всех тудушек
var lists = [ToDoList]() // массив листов
var itemsByList = [[ToDoItem]]() // массив массивов тудушек по листам

class MainViewController: UIViewController {
    
    @IBOutlet weak var TodayTableView: UITableView!
    @IBOutlet weak var ListsTableView: UITableView!
    
    private var todayItems = [ToDoItem]()
    
    private let todayTableViewIdCell = "ToDoItem"
    private let listsTableViewIdCell = "ListCell"
    private var selectedList = ToDoList()
    
    let NoItemsLabel = UILabel.init()
    let NoListsLabel = UILabel.init()
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllItems()
        getTodayItems()
        fetchLists()
        fetchAllListsItems()
        
        DispatchQueue.main.async {
            self.ListsTableView.reloadData()
        }
        
        if todayItems.count == 0 {
            NoItemsLabel.frame = CGRect(x: 10.0, y: TodayTableView.layer.position.y - 25, width: self.view.frame.width - 20.0, height: 50)
            NoItemsLabel.text = "No tasks for today"
            NoItemsLabel.font = UIFont(name: "ArialRoundedMTBold", size: 25)
            NoItemsLabel.textAlignment = .center
            NoItemsLabel.textColor = .black
            NoItemsLabel.numberOfLines = 2
            self.view.addSubview(NoItemsLabel)
        }
        
        if lists.count == 0 {
            NoListsLabel.frame = CGRect(x: 10.0, y: ListsTableView.layer.position.y - 25, width: self.view.frame.width - 20.0, height: 50)
            NoListsLabel.text = "You have no lists"
            NoListsLabel.font = UIFont(name: "ArialRoundedMTBold", size: 25)
            NoListsLabel.textAlignment = .center
            NoListsLabel.textColor = .black
            NoListsLabel.numberOfLines = 2
            self.view.addSubview(NoListsLabel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NoItemsLabel.removeFromSuperview()
        NoListsLabel.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TodayTableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: todayTableViewIdCell)
        
        ListsTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: listsTableViewIdCell)
        
        TodayTableView.delegate = self
        ListsTableView.delegate = self
        TodayTableView.dataSource = self
        ListsTableView.dataSource = self
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
                self.TodayTableView.reloadData()
                self.ListsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching ToDoItems")
        }
    }
    
    func getTodayItems() {
        for item in allItems {
            if Calendar.current.dateComponents([.day], from: item.dateToRemind ?? Date.distantPast) == Calendar.current.dateComponents([.day], from: Date.now) && !todayItems.contains(item) {
                todayItems.append(item)
            }
        }
    }
    
    func fetchLists() {
        do {
            lists = try context.fetch(ToDoList.fetchRequest())
            DispatchQueue.main.async {
                self.ListsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching lists")
        }
    }
    
    func fetchAllListsItems() {
        do {
            itemsByList = []
            for list in lists {
                itemsByList.append(try context.fetch(ToDoItem.fetchRequest()).filter {$0.list?.id == list.id})
            }
            DispatchQueue.main.async {
                self.TodayTableView.reloadData()
                self.ListsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching ListItems")
        }
    }

    func deleteItem(toDoItem: ToDoItem) {
        context.delete(toDoItem)
        do {
            DispatchQueue.main.async {
                self.TodayTableView.reloadData()
                self.ListsTableView.reloadData()
            }
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


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ListsTableView {
            selectedList = lists[indexPath.row]
            performSegue(withIdentifier: "SegueFromMainToItems", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == TodayTableView {
            return todayItems.count
        } else if tableView == ListsTableView {
            return lists.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == TodayTableView {
            let item = todayItems[indexPath.row]
            let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC+0")
            
            let cell: ToDoTableViewCell = self.TodayTableView!.dequeueReusableCell(withIdentifier: todayTableViewIdCell) as! ToDoTableViewCell
            
            cell.ListItemTextField.text = item.text
            cell.DoneButton.setBackgroundImage(image, for: .normal)
            cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
            cell.item = item
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            
            return cell
            
        } else if tableView == ListsTableView {
            
            let list = lists[indexPath.row]
            
            let cell: ListTableViewCell = self.ListsTableView.dequeueReusableCell(withIdentifier: listsTableViewIdCell) as! ListTableViewCell
            cell.ListNameLabel?.text = list.name
            cell.ItemsCountLabel?.text = "Tasks: " + String(itemsByList[lists.firstIndex(of: list) ?? 0].count)
            
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
