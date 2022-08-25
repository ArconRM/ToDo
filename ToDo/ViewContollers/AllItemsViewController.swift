//
//  AllItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import Foundation
import UIKit

class AllItemsViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var AllItemsTableView: UITableView?
    
    private var items = [ToDoItem]()
    private let cellId = "allItems"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllItems()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        AllItemsTableView?.backgroundColor = .clear
        AllItemsTableView?.rowHeight = 80
        
        AllItemsTableView!.register(UINib(nibName: "AllItemsTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        AllItemsTableView!.dataSource = self
        AllItemsTableView!.delegate = self
        self.view.addSubview(AllItemsTableView!)
    }
    
    func fetchAllItems() {
        do {
            items = try context.fetch(ToDoItem.fetchRequest())
            DispatchQueue.main.async {
                self.AllItemsTableView!.reloadData()
            }
        } catch {
            fatalError("Error fetching ToDoItems")
        }
    }
}

extension AllItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let cell: AllItemsTableViewCell = self.AllItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! AllItemsTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
}
