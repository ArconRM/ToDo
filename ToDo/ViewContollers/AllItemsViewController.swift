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
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: CGFloat((85 * allItems.count + 50 * lists.count)))
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0.154 * UIScreen.main.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height * 0.846)
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.frame.size = contentSize
//        contentView.center.y =
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + 400
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        setupViewsConstraints()
        scrollView.layer.zPosition = -1
        
        var index = 0
        
        for list in lists {
            
            if (itemsByList[index].count == 0) {
                continue
            }
            
            let label = UILabel(frame: CGRect(x: 20, y: barHeight - 270, width: 200, height: 40))
            label.font = .systemFont(ofSize: 30, weight: .bold)
            label.textColor = .white
            label.textAlignment = .left
            label.text = list.name
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                label.heightAnchor.constraint(equalToConstant: 40),
            ])
            
            stackView.addArrangedSubview(label)
            
            AllItemsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
            AllItemsTableView?.backgroundColor = .clear
            AllItemsTableView?.rowHeight = 80
            AllItemsTableView?.isScrollEnabled = false
            
            AllItemsTableView!.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            
            tableViews.append(AllItemsTableView ?? UITableView())
            
            AllItemsTableView!.dataSource = self
            AllItemsTableView!.delegate = self
            
            NSLayoutConstraint.activate([
                AllItemsTableView!.widthAnchor.constraint(equalToConstant: displayWidth - 20),
                AllItemsTableView!.heightAnchor.constraint(equalToConstant: CGFloat(itemsByList[index].count * 80)),
            ])
            index += 1
            
            stackView.addArrangedSubview(AllItemsTableView ?? UITableView())
        }
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
        return itemsByList[tableViews.firstIndex(of: tableView) ?? 0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let items = itemsByList[tableViews.firstIndex(of: tableView) ?? 0]
        let item = items[indexPath.row]
        
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+0")
        
        let cell: ToDoTableViewCell = self.AllItemsTableView!.dequeueReusableCell(withIdentifier: cellId) as! ToDoTableViewCell
        
        cell.ListItemTextField.text = item.text
        cell.DoneButton.setBackgroundImage(image, for: .normal)
        cell.DateLabel.text = dateFormatter.string(from: item.dateToRemind ?? Date.now)
        cell.item = item
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
}
