//
//  ToDoItemWithoutDateTableViewCell.swift
//  ToDo
//
//  Created by Артемий on 26.08.2023.
//

import UIKit

class ToDoItemWithoutDateTableViewCell: UITableViewCell {
    
    var item = ToDoItem()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var ToDoItemLabel: UILabel!
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
        ToDoItemsCoreDataManager.shared.toggleItemIsDoneStatus(item: item, notificationCenter: notificationCenter)
        
        let image = item.isDone ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        
        DoneButton.setBackgroundImage(image, for: .normal)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        contentView.backgroundColor = .clear
        contentView.tintColor = .clear
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
