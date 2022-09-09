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
    
    private var padding: CGFloat = 000
    
    private let cellId = "ToDoItem"

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchAllItems()
        fetchLists()
        
        for list in lists {
            allItems.append(fetchListItems(list: list))
        }
        
        for _ in lists {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label.center = CGPoint(x: 160, y: padding - 150)
                label.textAlignment = .left
                label.text = "I'm a test label"
            
            self.view.addSubview(label)
            
            let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 300
            let displayWidth: CGFloat = self.view.frame.width - 34
            let displayHeight: CGFloat = self.view.frame.height
            
            
            AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            
            AllItemsTableView?.backgroundColor = .clear
            AllItemsTableView?.rowHeight = 80
            AllItemsTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            AllItemsTableView?.center.x = self.view.center.x
            AllItemsTableView?.center.y = self.view.center.y + padding
            
            AllItemsTableView!.register(UINib(nibName: "AllItemsTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            
            tableViews.append(AllItemsTableView!)
            
            AllItemsTableView!.dataSource = self
            AllItemsTableView!.delegate = self
            self.view.addSubview(AllItemsTableView!)
            
            padding += CGFloat(allItems[tableViews.firstIndex(of: AllItemsTableView!) ?? 0].count * 100)
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
        
        let cell: AllItemsTableViewCell = self.AllItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! AllItemsTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
//        padding += 300
        
        return cell
    }
}
