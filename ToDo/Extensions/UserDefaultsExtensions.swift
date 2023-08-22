//
//  UserDefaultsExtensions.swift
//  ToDo
//
//  Created by Артемий on 08.08.2023.
//

import Foundation
import UIKit


extension UserDefaults {
    func getColor(forKey key: String) -> UIColor? {
        if let colorData = data(forKey: key),
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        {
            return color
        } else {
            return nil
        }
    }
    
    func setColor(color: UIColor, forKey key: String) {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
        {
            set(colorData, forKey: key)
        }
    }
}

