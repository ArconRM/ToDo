//
//  AllItemsTableViewCell.swift
//  ToDo
//
//  Created by Aaron on 24.08.2022.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    
    var item = ToDoItem()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var ToDoItemLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var Item: UIView!
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
        item.isDone.toggle()
        
        do {
            try context.save()
        } catch {
            fatalError("Error updating ToDoItem")
        }
        
        if !item.isDone {
            createNotification(title: item.list?.name ?? "Error", body: item.text ?? "Error", id: item.notificationId!)
        } else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [item.notificationId!.uuidString])
        }
        
        let image = item.isDone ?  UIImage(systemName: "checkmark.circle.fill"): UIImage(systemName: "circle")
        
        DoneButton.setBackgroundImage(image, for: .normal)
    }
    
    func createNotification(title: String, body: String, id: UUID) {
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                
                let content  = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.item.dateToRemind ?? Date.now)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                    
                let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Unknown error")
                        return
                    }
                }
            }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
