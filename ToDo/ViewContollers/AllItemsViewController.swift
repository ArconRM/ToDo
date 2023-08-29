//
//  AllItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import Foundation
import UIKit

class AllItemsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var ViewHeader: UIView!
    
    private var allItems = [ToDoItem]()
    private var lists = [ToDoList]()
    private var showCompletedKey = "showCompletedItems"
    
    private var contentSize: CGSize {
        return CGSize(width: view.frame.width, height: CGFloat((85 * allItems.count + 50 * lists.count)))
    }
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var stackView = UIStackView()
    
    private var ListItemsTableView: UITableView?
    private var RightBarButton: UIBarButtonItem?
    
    private var tableViews = [UITableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        
        configureRightBarButton()
        configureSubviews()
        
        view.addGradientBackground()
        view.addBlurEffect()
    }
    
    private func fetchData() {
        if UserDefaults.standard.bool(forKey: showCompletedKey) {
            allItems = ToDoItemsCoreDataManager.shared.fetchAllToDoItems()
            lists = ToDoListsCoreDataManager.shared.fetchToDoListsWithoutCompletedList().filter({ $0.getItems().count > 0})
        } else {
            allItems = ToDoItemsCoreDataManager.shared.fetchUncompletedToDoItems()
            lists = ToDoListsCoreDataManager.shared.fetchToDoListsWithoutCompletedList().filter({ $0.getUncompletedItems().count > 0})
        }
    }
    
    private func configureRightBarButton() {
        let menuClosure = {(action: UIAction) in
            self.ShowOrHideCompletedItemsPressed()
        }
        
        let actions = UserDefaults.standard.bool(forKey: showCompletedKey) ?
        [UIAction(title: "Hide completed".localized(), image: UIImage(systemName: "eye"), state: .off, handler: menuClosure)] :
        [UIAction(title: "Show completed".localized(), image: UIImage(systemName: "eye.fill"), state: .off, handler: menuClosure)]
        
        let menu = UIMenu(title: "",  children: actions)
        RightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        
        self.navigationItem.rightBarButtonItem = RightBarButton
    }
    
    private func ShowOrHideCompletedItemsPressed() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: showCompletedKey), forKey: showCompletedKey)
        
        let menuClosure = {(action: UIAction) in
            self.ShowOrHideCompletedItemsPressed()
        }
        if UserDefaults.standard.bool(forKey: showCompletedKey) {
            RightBarButton?.menu = UIMenu(children: [
                UIAction(title: "Hide completed".localized(), image: UIImage(systemName: "eye"), state: .off, handler: menuClosure)
            ])
            
        } else {
            RightBarButton?.menu = UIMenu(children: [
                UIAction(title: "Show completed".localized(), image: UIImage(systemName: "eye.fill"), state: .off, handler: menuClosure)
            ])
        }
        
        self.reconfigureSubviews()
    }
    
    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        configureScrollView()
        configureContentView()
        configureStackView()
    }
    
    private func configureScrollView() {
        scrollView.frame = CGRect(x: 0, y: ViewHeader.frame.height, width: self.view.bounds.width, height: self.view.bounds.height - ViewHeader.frame.height)
        scrollView.contentSize = contentSize
    }
    
    private func configureContentView() {
        contentView.frame.size = contentSize
    }
    
    private func configureStackView() {
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
        
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 400
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        for list in lists {
            
            let label = configureLabel(text: list.name!)
            stackView.addArrangedSubview(label)
            
            ListItemsTableView = configureTableView(list: list)
            stackView.addArrangedSubview(ListItemsTableView!)
        }
        
        func configureLabel(text: String) -> UILabel {
            let label = UILabel(frame: CGRect(x: 20, y: barHeight - 270, width: 200, height: 40))
            label.font = .systemFont(ofSize: 30, weight: .bold)
            label.textColor = .label
            label.textAlignment = .left
            label.text = text
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                label.heightAnchor.constraint(equalToConstant: 40),
            ])
            return label
        }
        
        func configureTableView(list: ToDoList) -> UITableView {
            let tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            tableView.backgroundColor = .clear
            tableView.rowHeight = 80
            tableView.isScrollEnabled = false
            
            tableView.register(UINib(nibName: "ToDoItemWithDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithDateCellId.rawValue)
            tableView.register(UINib(nibName: "ToDoItemWithoutDateTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue)
            
            tableViews.append(tableView )
            
            tableView.dataSource = self
            tableView.delegate = self
            
            NSLayoutConstraint.activate([
                tableView.widthAnchor.constraint(equalToConstant: displayWidth - 25),
                UserDefaults.standard.bool(forKey: showCompletedKey) ?
                tableView.heightAnchor.constraint(equalToConstant: CGFloat((list.getItems().count ) * 80)) :
                tableView.heightAnchor.constraint(equalToConstant: CGFloat((list.getUncompletedItems().count ) * 80))
            ])
            return tableView
        }
    }
    
    private func reconfigureSubviews() {
        fetchData()
        
        tableViews = []
        
        contentView.removeFromSuperview()
        scrollView.removeFromSuperview()
        stackView.removeFromSuperview()
        
        stackView = UIStackView()
        
        configureSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


extension AllItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.standard.bool(forKey: showCompletedKey) ?
        lists[tableViews.firstIndex(of: tableView) ?? 0].getItems().count :
        lists[tableViews.firstIndex(of: tableView) ?? 0].getUncompletedItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let items = UserDefaults.standard.bool(forKey: showCompletedKey) ?
        lists[tableViews.firstIndex(of: tableView) ?? 0].getItems() :
        lists[tableViews.firstIndex(of: tableView) ?? 0].getUncompletedItems()
        
        let item = items[indexPath.row]
        
        let image = item.isDone ? UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        var cell = UITableViewCell()
        if item.dateToRemind != nil {
            let cellWithDate = self.ListItemsTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithDateCellId.rawValue) as! ToDoItemWithDateTableViewCell
            cellWithDate.ToDoItemLabel.text = item.text
            cellWithDate.DoneButton.setBackgroundImage(image, for: .normal)
            cellWithDate.item = item
            cellWithDate.DateLabel.text = dateFormatter.string(from: item.dateToRemind!)
            cell = cellWithDate
        } else {
            let cellWithoutDate = self.ListItemsTableView!.dequeueReusableCell(withIdentifier: TableViewCellIds.itemWithoutDateCellId.rawValue) as! ToDoItemWithoutDateTableViewCell
            cellWithoutDate.ToDoItemLabel.text = item.text
            cellWithoutDate.DoneButton.setBackgroundImage(image, for: .normal)
            cellWithoutDate.item = item
            cell = cellWithoutDate
        }
        
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 25, height: cell.bounds.height)
        
        let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
        shapeLayer.path = maskPath.cgPath
        cell.layer.mask = shapeLayer
        
        return cell
    }
}
