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
    
    private var listItems = [ToDoItem]()
    private let cellId = "ToDoItem"
    var selectedList = ToDoList()
    
    let NoItemsLabel = UILabel.init()
    
    override func viewWillAppear(_ animated: Bool) {
        fetchListItems()
        
        if listItems.count == 0 {
            NoItemsLabel.frame = CGRect(x: 10.0, y: self.view.frame.height / 2, width: self.view.frame.width - 20.0, height: 50)
            NoItemsLabel.text = "No tasks here :("
            NoItemsLabel.font = UIFont(name: "ArialRoundedMTBold", size: 35)
            NoItemsLabel.textAlignment = .center
            NoItemsLabel.textColor = .white
            self.view.addSubview(NoItemsLabel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NoItemsLabel.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ListName.text = selectedList.name
        
        fetchListItems()
        
        ItemsTableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromItemsToAddItem") {
            let vc = segue.destination as! AddToDoItemViewController
            vc.selectedList = selectedList
        }
    }
    
    func fetchListItems() {
        do {
            listItems = try context.fetch(ToDoItem.fetchRequest()).filter {$0.list?.name == selectedList.name}
            DispatchQueue.main.async {
                self.ItemsTableView.reloadData()
            }
        } catch {
            fatalError("Error fetching ToDoItems")
        }
    }
}

//class CustomListItemCell: UITableViewCell {
//
//    var item = ToDoItem()
//
//    @IBOutlet weak var DoneButton: UIButton!
//    @IBOutlet weak var ListItemTextField: UITextField!
//
//
//    @IBAction func DoneButtonPressed(_ sender: UIButton) {
//        item.isDone.toggle()
//
//        do {
//            try context.save()
//        } catch {
//            fatalError("Error updating ToDoItem")
//        }
//
//        let image = item.isDone ? UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
//
//        DoneButton.setBackgroundImage(image, for: .normal)
//    }
//
//    @IBAction func ItemIsChanging(_ sender: UITextField) {
//        item.text = sender.text ?? "Error"
//
//        do {
//            try context.save()
//        } catch {
//            fatalError("Error updating ToDoItem")
//        }
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//    }
//
//    override var frame: CGRect {
//        get {
//            return super.frame
//        }
//        set (newFrame) {
//            var frame = newFrame
//            frame.origin.y += 3		
//            frame.size.height -= 6
//            super.frame = frame
//        }
//    }
//}

extension ListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = listItems[indexPath.row]
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+0")
        
        let cell: ToDoTableViewCell = self.ItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! ToDoTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
}

