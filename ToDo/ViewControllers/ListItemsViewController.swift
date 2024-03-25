//
//  ListItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 14.08.2022.
//

import Foundation
import UIKit

class ListItemsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ItemsTableView: UITableView!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var ListNameTextField: UITextField!
    
    private var _lists = [ToDoList]()
    private var _listItems = [ToDoItem]()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var selectedList = ToDoList()
    var selectedItem = ToDoItem()
    
    let NoItemsLabel = UILabel.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _lists = ToDoListsCoreDataManager.shared.fetchToDoLists()
        
        if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(selectedList) {
            _listItems = ToDoItemsCoreDataManager.shared.fetchCompletedToDoItems()
        } else {
            _listItems = selectedList.getUncompletedItems()
        }
        
        DispatchQueue.main.async {
            self.ItemsTableView.reloadData()
        }
        
        if _listItems.count == 0 {
            _addNoItemsLabel()
        }
    }
    
    private func _addNoItemsLabel() {
        NoItemsLabel.frame = CGRect(x: 10.0, y: self.view.frame.height / 2, width: self.view.frame.width - 20.0, height: 50)
        NoItemsLabel.text = "No tasks here :(".localized()
        NoItemsLabel.font = .systemFont(ofSize: 25, weight: .bold)
        NoItemsLabel.textAlignment = .center
        NoItemsLabel.textColor = .label
        self.view.addSubview(NoItemsLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NoItemsLabel.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ListNameTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _configure()
    }
    
    private func _configure() {
        view.addGradientBackground()
        view.addBlurEffect()
        
        ListNameTextField.delegate = self
        ListNameTextField.text = selectedList.name
        NoItemsLabel.font = .systemFont(ofSize: 44, weight: .bold)
        
        ItemsTableView.register(UINib(nibName: "ToDoItemWithDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithDateCellId.rawValue)
        ItemsTableView.register(UINib(nibName: "ToDoItemWithoutDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue)
        
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
        
        if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(selectedList) {
            AddButton.removeFromSuperview()
        }
        NoItemsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        AddButton.contentEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueFromItemsToAddItem") {
            let vc = segue.destination as! AddOrUpdateToDoItemViewController
            vc.selectedList = selectedList
            vc.functionOfView = .create
        } else if (segue.identifier == "SegueFromItemsToUpdateItem") {
            let vc = segue.destination as! AddOrUpdateToDoItemViewController
            vc.selectedList = selectedList
            vc.selectedItem = selectedItem
            vc.functionOfView = .update
        }
    }
    
    
    @IBAction func ListNameBeganChanging(_ sender: UITextField) {
        if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(selectedList) {
            let alert = UIAlertController(title: "Forbidden".localized(), message: "You can't change this list name.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func ListNameEndedChanging(_ sender: UITextField) {
        do {
            try ToDoListsCoreDataManager.shared.updateListName(list: selectedList, newName: sender.text ?? "Error")
        }
        catch {
            presentIncorrectListAlert()
        }
    }
    
    @IBAction func DeleteListPressed(_ sender: Any) {
        if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(selectedList) {
            let alert = UIAlertController(title: "Forbidden".localized(), message: "You can't delete this list.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Are you sure?".localized(), message: "You are going to delete this list.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { action in
                ToDoListsCoreDataManager.shared.deleteList(self.selectedList)
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentIncorrectListAlert() {
        let alert = UIAlertController(title: "Incorrect list name".localized(), message: "List name must be unique and contain from 1 to 20 symbols.".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !ToDoListsCoreDataManager.shared.checkIfListIsCompleted(selectedList) {
            selectedItem = _listItems[indexPath.row]
            performSegue(withIdentifier: "SegueFromItemsToUpdateItem", sender: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = _listItems[indexPath.row]
        let image = item.isDone ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        var cell = UITableViewCell()
        if item.dateToRemind != nil {
            let cellWithDate = self.ItemsTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithDateCellId.rawValue) as! ToDoItemWithDateTableViewCell
            cellWithDate.ToDoItemLabel.text = item.text
            cellWithDate.DoneButton.setBackgroundImage(image, for: .normal)
            cellWithDate.item = item
            cellWithDate.DateLabel.text = dateFormatter.string(from: item.dateToRemind!)
            cell = cellWithDate
        } else {
            let cellWithoutDate = self.ItemsTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue) as! ToDoItemWithoutDateTableViewCell
            cellWithoutDate.ToDoItemLabel.text = item.text
            cellWithoutDate.DoneButton.setBackgroundImage(image, for: .normal)
            cellWithoutDate.item = item
            cell = cellWithoutDate
        }
        
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 30, height: cell.bounds.height)
        
        let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
        shapeLayer.path = maskPath.cgPath
        cell.layer.mask = shapeLayer
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized()) {
            (action, sourceView, completionHandler) in
            
            UIView.transition(with: self.view,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: {
                                self._deleteItemWithTableUpdate(item: self._listItems[indexPath.row])
                            })
            completionHandler(true)
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
        
    }
    
    private func _deleteItemWithTableUpdate(item: ToDoItem) {
        ToDoItemsCoreDataManager.shared.deleteToDoItem(item: item, list: self.selectedList, notificationCenter: self.notificationCenter)
        
        if ToDoListsCoreDataManager.shared.checkIfListIsCompleted(self.selectedList) {
            self._listItems = ToDoItemsCoreDataManager.shared.fetchCompletedToDoItems()
        } else {
            self._listItems = self.selectedList.getUncompletedItems()
        }
        
        DispatchQueue.main.async {
            self.ItemsTableView.reloadData()
        }
    }
}
