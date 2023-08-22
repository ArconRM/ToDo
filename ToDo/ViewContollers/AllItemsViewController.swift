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
    
    private let cellId = "ToDoItem"
    private var allItems = [ToDoItem]()
    private var lists = [ToDoList]()
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: CGFloat((85 * allItems.count + 50 * lists.count)))
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: ViewHeader.frame.height, width: self.view.bounds.width, height: self.view.bounds.height - ViewHeader.frame.height)
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.frame.size = contentSize
        return contentView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private var AllItemsTableView: UITableView?
    
    private var tableViews = [UITableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allItems = ToDoItemsCoreDataManager.shared.fetchAllToDoItems()
        lists = ToDoListsCoreDataManager.shared.fetchToDoListsWithCompletedListBeingLast().dropLast()
        
        view.addGradientBackground()
        view.addBlurEffect()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 400
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        setupViewsConstraints()
        
        var listIndex = 0
        
        for list in lists {
            
            let label = UILabel(frame: CGRect(x: 20, y: barHeight - 270, width: 200, height: 40))
            label.font = .systemFont(ofSize: 30, weight: .bold)
            label.textColor = .label
            label.textAlignment = .left
            label.text = list.name
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                label.heightAnchor.constraint(equalToConstant: 40),
            ])
            
            if list.getItems().count > 0 {
                stackView.addArrangedSubview(label)
            }
            
            AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            AllItemsTableView?.backgroundColor = .clear
            AllItemsTableView?.rowHeight = 80
            AllItemsTableView?.isScrollEnabled = false
            
            AllItemsTableView!.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            
            tableViews.append(AllItemsTableView ?? UITableView())
            
            AllItemsTableView!.dataSource = self
            AllItemsTableView!.delegate = self
            
            NSLayoutConstraint.activate([
                AllItemsTableView!.widthAnchor.constraint(equalToConstant: displayWidth - 25),
                AllItemsTableView!.heightAnchor.constraint(equalToConstant: CGFloat((list.getItems().count ) * 80)),
            ])
            
            if list.getItems().count > 0 {
                stackView.addArrangedSubview(AllItemsTableView ?? UITableView())
            }
            listIndex += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension AllItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupViewsConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists[tableViews.firstIndex(of: tableView) ?? 0].getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let items = lists[tableViews.firstIndex(of: tableView) ?? 0].getItems()
        let item = items[indexPath.row]
        
        let image = item.isDone ? UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        let cell: ToDoTableViewCell = self.AllItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! ToDoTableViewCell
        
        cell.ToDoItemLabel.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
        cell.item = item
        
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 25, height: cell.bounds.height)
        
        let maskPath = UIBezierPath(roundedRect: CGRect(origin: cell.bounds.origin, size: cellSize), byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: cell.bounds.origin, size: cellSize)
        shapeLayer.path = maskPath.cgPath
        cell.layer.mask = shapeLayer
        
        return cell
    }
}
