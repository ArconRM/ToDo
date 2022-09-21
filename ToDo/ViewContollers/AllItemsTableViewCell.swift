//
//  AllItemsTableViewCell.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import UIKit

class AllItemsTableViewCell: UITableViewCell {
    
    var item = ToDoItem()
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var ListItemTextField: UITextField!
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBAction func ItemIsChanging(_ sender: UITextField) {
        item.text = sender.text ?? "Error"
        
        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
