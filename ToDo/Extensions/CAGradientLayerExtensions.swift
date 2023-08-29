//
//  CAGradientLayerExtensions.swift
//  ToDo
//
//  Created by Артемий on 08.08.2023.
//

import Foundation
import UIKit


extension CAGradientLayer {
    static func gradientLayer(in frame: CGRect) -> Self {
        let gradientLayer = Self()
        gradientLayer.frame = frame
        
        let topColor = UserDefaults.standard.getColor(forKey: "BackgroundPrimaryColor")?.cgColor
        var bottomColor: CGColor?
        switch topColor {
        case UIColor.red.cgColor:
            bottomColor = UIColor.cyan.cgColor
            
        case UIColor.blue.cgColor:
            bottomColor = UIColor.orange.cgColor
            
        case UIColor.green.cgColor:
            bottomColor = UIColor.blue.cgColor
            
        default:
            bottomColor = UIColor.blue.cgColor
        }
        
        gradientLayer.colors = [topColor ?? UIColor.red.cgColor, bottomColor!]
        gradientLayer.opacity = 0.1
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }
}
