//
//  AllItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import Foundation
import UIKit

class AllItemsViewController: UIViewController, UITextFieldDelegate {
    
    private var AllItemsTableView: UITableView?
    
    private var tableViews = [UITableView]()
    
    private var allItems = [[ToDoItem]]() // массив массивов тудушек по спискам
    private var listItems = [ToDoItem]() // массив тудушек со списка
    private var lists = [ToDoList]() // массив списков
    
    private var padding: CGFloat = 0
    
    private let cellId = "ToDoItem"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchLists()
        
        for list in lists {
            allItems.append(fetchListItems(list: list))
        }
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 400
        let displayWidth: CGFloat = self.view.frame.width - 34
        let displayHeight: CGFloat = self.view.frame.height
        
        for list in lists {
            
            let label = UILabel(frame: CGRect(x: 20, y: barHeight - 270 + padding, width: 200, height: 40))
            //                label.center = CGPoint(x: 160, y: barHeight - 200 + padding)
            label.font = .systemFont(ofSize: 30, weight: .bold)
            label.textColor = .white
            label.textAlignment = .left
            label.text = list.name
            
            self.view.addSubview(label)
            
            AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            
            AllItemsTableView?.backgroundColor = .clear
            AllItemsTableView?.rowHeight = 80
            AllItemsTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            AllItemsTableView?.isScrollEnabled = false
            AllItemsTableView?.center.x = self.view.center.x
            AllItemsTableView?.center.y = self.view.center.y + padding
            
            AllItemsTableView!.register(UINib(nibName: "AllItemsTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            
            tableViews.append(AllItemsTableView!)
            
            AllItemsTableView!.dataSource = self
            AllItemsTableView!.delegate = self
            self.view.addSubview(AllItemsTableView!)
            
            padding += CGFloat(allItems[lists.firstIndex(of: list) ?? 0].count * 110)
            print(padding)
        }
    }
    
    func fetchLists() {
        do {
            lists = try context.fetch(ToDoList.fetchRequest())
            DispatchQueue.main.async {
                self.AllItemsTableView!.reloadData()
            }
        } catch {
            fatalError("Error fetching lists")
        }
    }
    
    func fetchListItems(list: ToDoList) -> [ToDoItem] {
        do {
            return try context.fetch(ToDoItem.fetchRequest()).filter {$0.list?.name == list.name}
        } catch {
            fatalError("Error fetching ListItems")
        }
    }
    
    //    func fetchAllItems() {
    //        do {
    //            allItems = try context.fetch(ToDoItem.fetchRequest())
    //            DispatchQueue.main.async {
    //                self.AllItemsTableView!.reloadData()
    //            }
    //        } catch {
    //            fatalError("Error fetching ToDoItems")
    //        }
    //    }
}

extension AllItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems[tableViews.firstIndex(of: tableView) ?? 0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let items = allItems[tableViews.firstIndex(of: tableView) ?? 0]
        let item = items[indexPath.row]
        
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+0")
        
        let cell: AllItemsTableViewCell = self.AllItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! AllItemsTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
}
