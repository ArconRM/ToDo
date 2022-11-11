//
//  AllItemsViewController.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import Foundation
import UIKit

class AllItemsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    private let cellId = "ToDoItem"
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.frame.size = contentSize
        contentView.center.y = self.view.center.y + 150
        return contentView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    private var AllItemsTableView: UITableView?
    
    private var tableViews = [UITableView]()
    
    private var allItems = [[ToDoItem]]() // массив массивов тудушек по спискам
    private var listItems = [ToDoItem]() // массив тудушек со списка
    private var lists = [ToDoList]() // массив списков
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        scrollView.layer.zPosition = -1
        
        fetchLists()
        fetchAllListItems(lists: lists)
        
        if Double(lists.count * 55 + allItems.count * 1) > view.frame.height {
            scrollView.contentSize = CGSize(width: view.frame.width, height: Double(lists.count * 55 + allItems.count * 1) + view.frame.height)
            stackView.frame.size = CGSize(width: view.frame.width, height: Double(lists.count * 55 + allItems.count * 1) + view.frame.height)
        } else {
            scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
            stackView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        }
                
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 400
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        var index = 0
        
        for list in lists {
            
            let label = UILabel(frame: CGRect(x: 20, y: barHeight - 270, width: 200, height: 40))
            label.font = .systemFont(ofSize: 30, weight: .bold)
            label.textColor = .white
            label.textAlignment = .left
            label.text = list.name
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                label.heightAnchor.constraint(equalToConstant: 30),
            ])
            
            stackView.addArrangedSubview(label)
            
            AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            
            AllItemsTableView?.backgroundColor = .clear
            AllItemsTableView?.rowHeight = 80
            AllItemsTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            AllItemsTableView?.isScrollEnabled = false
            AllItemsTableView?.center.x = self.view.center.x
            AllItemsTableView?.translatesAutoresizingMaskIntoConstraints = false
            
            AllItemsTableView!.register(UINib(nibName: "AllItemsTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            
            tableViews.append(AllItemsTableView ?? UITableView())
            
            AllItemsTableView!.dataSource = self
            AllItemsTableView!.delegate = self
//
            NSLayoutConstraint.activate([
                AllItemsTableView!.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                AllItemsTableView!.heightAnchor.constraint(equalToConstant: CGFloat(allItems[index].count * 100)),
            ])
            index += 1
//
            stackView.addArrangedSubview(AllItemsTableView ?? UITableView())
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    }
    
//    func setupScrollView(){
//        view.addSubview(scrollView)
//
//        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    }
    
    
    func fetchLists() {
        do {
            lists = try context.fetch(ToDoList.fetchRequest())
            DispatchQueue.main.async {
                self.AllItemsTableView?.reloadData()
            }
        } catch {
            fatalError("Error fetching lists")
        }
    }
    
    func fetchAllListItems(lists: [ToDoList]) {
        do {
            for list in lists {
                self.allItems.append(try context.fetch(ToDoItem.fetchRequest()).filter {$0.list?.name == list.name})
            }
        } catch {
            fatalError("Error fetching ListItems")
        }
    }
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
