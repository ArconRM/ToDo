//
//  UIViewExtensions.swift
//  ToDo
//
//  Created by Артемий on 08.08.2023.
//

import Foundation
import UIKit

extension UIView {
    func addGradientBackground() {
        self.layer.insertSublayer(CAGradientLayer.gradientLayer(in: self.bounds), at: 0)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurEffectView, at: 1)
    }
    
    func removeBackgroundEffects() {
        self.layer.sublayers?.remove(at: 0)
        self.subviews[0].removeFromSuperview()
    }
}
