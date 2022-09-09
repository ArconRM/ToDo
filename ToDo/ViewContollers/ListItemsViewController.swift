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
    private let cellId = "ToDoItem"
    var selectedList = ToDoList()
    
    override func viewWillAppear(_ animated: Bool) {
        fetchListItems()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ListName.text = selectedList.name
        
        fetchListItems()
        
        ItemsTableView.register(UINib(nibName: "AllItemsTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
        
        if items.count == 0 {
            NoItemsLabel.text = "No tasks :("
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromItemsToAddItem") {
            let vc = segue.destination as! AddToDoItemViewController
            vc.selectedList = selectedList
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
}

class CustomListItemCell: UITableViewCell {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var item = ToDoItem()
    
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var ListItemTextField: UITextField!
    
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
        item.isDone.toggle()
        
        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
        
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        DoneButton.setBackgroundImage(image, for: .normal)
    }
    
    @IBAction func ItemIsChanging(_ sender: UITextField) {
        item.text = sender.text ?? "Error"
        
        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.y += 3
            frame.size.height -= 6
            super.frame = frame
        }
    }
}

extension ListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let cell: AllItemsTableViewCell = self.ItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! AllItemsTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
}

