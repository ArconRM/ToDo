//
//  ViewController.swift
//  ToDo
//
//  Created by Aaron on 12.08.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var TodayTableView: UITableView!
    @IBOutlet weak var ListsTableView: UITableView!
    @IBOutlet weak var CreateListButton: UIButton!
    
    private var todayItems = [ToDoItem]()
    private var allItems = [ToDoItem]()
    private var lists = [ToDoList]()
    
    private var selectedList = ToDoList()
    
    private let NoItemsLabel = UILabel.init()
    private let NoListsLabel = UILabel.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.addGradientBackground()
        view.addBlurEffect()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        allItems = ToDoItemsCoreDataManager.shared.fetchAllToDoItems()
        lists = ToDoListsCoreDataManager.shared.fetchToDoListsWithCompletedListBeingLast()
        _getTodayItems()
        
        DispatchQueue.main.async {
            self.TodayTableView.reloadData()
            self.ListsTableView.reloadData()
        }
        
        if todayItems.count == 0 {
            _addNoItemsLabel()
        }
        
        if lists.count == 0 {
            _addNoListsLabel()
        }
    }
    
    private func _getTodayItems() {
        todayItems = []
        for item in allItems {
            if Calendar.current.dateComponents([.day], from: item.dateToRemind ?? Date.distantPast) == Calendar.current.dateComponents([.day], from: Date.now) && item.isDone == false {
                todayItems.append(item)
            }
        }
    }
    
    private func _addNoItemsLabel() {
        NoItemsLabel.frame = CGRect(x: 10.0, y: TodayTableView.layer.position.y - 25, width: self.view.frame.width - 20.0, height: 50)
        NoItemsLabel.text = "No tasks for today".localized()
        NoItemsLabel.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 25.0)
        NoItemsLabel.textAlignment = .center
        NoItemsLabel.textColor = .label
        NoItemsLabel.numberOfLines = 2
        self.view.addSubview(NoItemsLabel)
    }
    
    private func _addNoListsLabel() {
        NoListsLabel.frame = CGRect(x: 10.0, y: ListsTableView.layer.position.y - 25, width: self.view.frame.width - 20.0, height: 50)
        NoListsLabel.text = "You have no lists".localized()
        NoListsLabel.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 25.0)
        NoListsLabel.textAlignment = .center
        NoListsLabel.textColor = .label
        NoListsLabel.numberOfLines = 2
        self.view.addSubview(NoListsLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _configure()
    }
    
    private func _configure() {
        TodayTableView.register(UINib(nibName: "ToDoItemWithDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithDateCellId.rawValue)
        TodayTableView.register(UINib(nibName: "ToDoItemWithoutDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue)
        
        ListsTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.listCellId.rawValue)
        
        TodayTableView.delegate = self
        ListsTableView.delegate = self
        TodayTableView.dataSource = self
        ListsTableView.dataSource = self
        
        CreateListButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 20.0)
        CreateListButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.removeBackgroundEffects()
        
        NoItemsLabel.removeFromSuperview()
        NoListsLabel.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromMainToItems") {
            let vc = segue.destination as! ListItemsViewController
            vc.selectedList = selectedList
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
            dateFormatter.dateFormat = "MMM d, HH:mm"
            dateFormatter.timeZone = TimeZone.current
            
            var cell = UITableViewCell()
            if item.dateToRemind != nil {
                let cellWithDate = self.TodayTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithDateCellId.rawValue) as! ToDoItemWithDateTableViewCell
                cellWithDate.ToDoItemLabel.text = item.text
                cellWithDate.DoneButton.setBackgroundImage(image, for: .normal)
                cellWithDate.item = item
                cellWithDate.DateLabel.text = dateFormatter.string(from: item.dateToRemind!)
                cell = cellWithDate
            } else {
                let cellWithoutDate = self.TodayTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue) as! ToDoItemWithoutDateTableViewCell
                cellWithoutDate.ToDoItemLabel.text = item.text
                cellWithoutDate.DoneButton.setBackgroundImage(image, for: .normal)
                cellWithoutDate.item = item
                cell = cellWithoutDate
            }
            
            let cellSize = CGSize(width: UIScreen.main.bounds.width - 35, height: cell.bounds.height - 0.3)
            
            let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
            
            return cell
            
        } else if tableView == ListsTableView {
            
            let list = lists[indexPath.row]
            
            let cell: ListTableViewCell = self.ListsTableView.dequeueReusableCell(withIdentifier: TableViewCellIds.listCellId.rawValue) as! ListTableViewCell
            cell.ListNameLabel?.text = list.name
            
            if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(list) {
                cell.ItemsCountLabel.text = "Tasks: ".localized() + String(allItems.filter({ $0.isDone }).count)
            } else {
                cell.ItemsCountLabel?.text = "Tasks: ".localized() + String(list.getUncompletedItems().count)
            }
            
            let cellSize = CGSize(width: UIScreen.main.bounds.width - 35, height: 75)

            let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))

            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
