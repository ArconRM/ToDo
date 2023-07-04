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
let completedName = "Completed".localized()

func fetchToDoItems() {
    do {
        allItems = try context.fetch(ToDoItem.fetchRequest())
        
        lists = try context.fetch(ToDoList.fetchRequest())
        lists.removeAll {$0.name == completedName}
        
        if allItems.filter({$0.isDone == true}).count > 0 {
            var completedItems = ToDoList(context: context)
            completedItems.name = completedName
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
    @IBOutlet weak var CreateListButton: UIButton!
    
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
            NoItemsLabel.text = "No tasks for today".localized()
            NoItemsLabel.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 25.0)
            NoItemsLabel.textAlignment = .center
            NoItemsLabel.textColor = .label
            NoItemsLabel.numberOfLines = 2
            self.view.addSubview(NoItemsLabel)
        }
        
        if lists.count == 0 {
            NoListsLabel.frame = CGRect(x: 10.0, y: ListsTableView.layer.position.y - 25, width: self.view.frame.width - 20.0, height: 50)
            NoListsLabel.text = "You have no lists".localized()
            NoListsLabel.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 25.0)
            NoListsLabel.textAlignment = .center
            NoListsLabel.textColor = .label
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
        
        view.addGradientBackground()
        view.addBlurEffect()
        
        TodayTableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: todayTableViewIdCell)
        ListsTableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: listsTableViewIdCell)
        
        TodayTableView.delegate = self
        ListsTableView.delegate = self
        TodayTableView.dataSource = self
        ListsTableView.dataSource = self
        
        CreateListButton.titleLabel?.font = UIFont(name:"Arial Rounded MT Pro Cyr", size: 20.0)
        CreateListButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        
//        arialroundedmtprocyr_bold.otf
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
            dateFormatter.dateFormat = "MMM d, HH:mm"
            dateFormatter.timeZone = TimeZone.current
            
            let cell: ToDoTableViewCell = self.TodayTableView!.dequeueReusableCell(withIdentifier: todayTableViewIdCell) as! ToDoTableViewCell
            
            cell.ToDoItemLabel.text = item.text
            cell.DoneButton.setBackgroundImage(image, for: .normal)
            cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
            cell.item = item
            
            let cellSize = CGSize(width: UIScreen.main.bounds.width - 35, height: cell.bounds.height - 0.3) 
            
            let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
            
            /// в предыдущем дизайне было нужно
//            let borderLayer = CAShapeLayer()
//            borderLayer.path = maskPath.cgPath
//            borderLayer.fillColor = UIColor.clear.cgColor
//            borderLayer.strokeColor = UIColor.black.cgColor
//            borderLayer.lineWidth = 3
//            borderLayer.frame = cell.bounds
//            cell.layer.addSublayer(borderLayer)
            
//            cell.layer.borderWidth = 1
//            cell.layer.cornerRadius = 8
            
            return cell
            
        } else if tableView == ListsTableView {
            
            let list = lists[indexPath.row]
            
            let cell: ListTableViewCell = self.ListsTableView.dequeueReusableCell(withIdentifier: listsTableViewIdCell) as! ListTableViewCell
            cell.ListNameLabel?.text = list.name
            if list.name == completedName {
                cell.ItemsCountLabel?.text = "Completed tasks: ".localized() + String(allItems.filter({ $0.isDone == true }).count)
            } else {
                cell.ItemsCountLabel?.text = "Tasks: ".localized() + String(itemsByList[lists.firstIndex(of: list) ?? 0].filter({$0.isDone == false}).count)
            }
            
            let cellSize = CGSize(width: UIScreen.main.bounds.width - 35, height: 75)
//
            let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
//
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
            shapeLayer.path = maskPath.cgPath
            cell.layer.mask = shapeLayer
            
/// в предыдущем дизайне было нужно
//            let borderLayer = CAShapeLayer()
//            borderLayer.path = maskPath.cgPath
//            borderLayer.fillColor = UIColor.clear.cgColor
//            borderLayer.strokeColor = UIColor.black.cgColor
//            borderLayer.opacity = 0.01
//            borderLayer.lineWidth = 10
//            borderLayer.frame = cell.bounds
//            cell.layer.addSublayer(borderLayer)
            
//            cell.layer.borderWidth = 1
//            cell.layer.cornerRadius = 8
            
//            cell.layer.shadowOffset = CGSize(width: 100, height: 100)
//            cell.layer.shadowRadius = 20
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension CAGradientLayer {
    static func gradientLayer(in frame: CGRect) -> Self {
        let gradientLayer = Self()
        gradientLayer.frame = frame
        
        let topColor = UIColor.red.cgColor
        let bottomColor = UIColor.blue.cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.opacity = 0.08
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }
}

extension UIView {
    func addGradientBackground() {
        self.layer.insertSublayer(CAGradientLayer.gradientLayer(in: self.bounds), at: 0)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurEffectView, at: 1)
    }
}
