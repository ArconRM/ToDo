//
//  ViewController.swift
//  ToDo
//
//  Created by Aaron on 12.08.2022.
//

import UIKit

// общее
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

var allItems = [ToDoItem]() // массив всех тудушек
var lists = [ToDoList]() // массив листов
var itemsByList = [[ToDoItem]]() // массив массивов тудушек по листам

func fetchToDoItems() {
    do {
        allItems = try context.fetch(ToDoItem.fetchRequest())
        
        lists = try context.fetch(ToDoList.fetchRequest())
        lists.removeAll {$0.name == "Completed"}
        
        if allItems.filter({$0.isDone == true}).count > 0 {
            var completedItems = ToDoList(context: context)
            completedItems.name = "Completed"
            lists.append(completedItems)
        }
        
        itemsByList = []
        for list in lists {
            itemsByList.append(allItems.filter {$0.list?.id == list.id})
        }
    } catch {
        fatalError("Error fetching ToDo items")
    }
}
// общее

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
        fetchToDoItems()
        getTodayItems()
        
        DispatchQueue.main.async {
            self.TodayTableView.reloadData()
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
    
    func getTodayItems() {
        todayItems = []
        for item in allItems {
            if Calendar.current.dateComponents([.day], from: item.dateToRemind ?? Date.distantPast) == Calendar.current.dateComponents([.day], from: Date.now) && item.isDone == false {
                todayItems.append(item)
            }
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
            dateFormatter.timeZone = TimeZone.current
            
            let cell: ToDoTableViewCell = self.TodayTableView!.dequeueReusableCell(withIdentifier: todayTableViewIdCell) as! ToDoTableViewCell
            
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
            borderLayer.lineWidth = 3
            borderLayer.frame = cell.bounds
            cell.layer.addSublayer(borderLayer)
            
//            cell.layer.borderWidth = 1
//            cell.layer.cornerRadius = 8
            
            return cell
            
        } else if tableView == ListsTableView {
            
            let list = lists[indexPath.row]
            
            let cell: ListTableViewCell = self.ListsTableView.dequeueReusableCell(withIdentifier: listsTableViewIdCell) as! ListTableViewCell
            cell.ListNameLabel?.text = list.name
            if list.name == "Completed" {
                cell.ItemsCountLabel?.text = "Completed tasks: " + String(allItems.filter({ $0.isDone == true }).count)
            } else {
                cell.ItemsCountLabel?.text = "Tasks: " + String(itemsByList[lists.firstIndex(of: list) ?? 0].filter({$0.isDone == false}).count)
            }
            
            let cellSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 75)
            
            let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
            
            let borderLayer = CAShapeLayer()
            borderLayer.path = maskPath.cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = UIColor.black.cgColor
            borderLayer.lineWidth = 3
            borderLayer.frame = cell.bounds
            cell.layer.addSublayer(borderLayer)
            
//            cell.layer.borderWidth = 1
//            cell.layer.cornerRadius = 8
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
