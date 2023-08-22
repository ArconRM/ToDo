//
//  SettingsViewController.swift
//  ToDo
//
//  Created by Артемий on 31.07.2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var ColorSegmentedControl: UISegmentedControl!
    
    @IBAction func colorToggle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.setColor(color: .red, forKey: "BackgroundPrimaryColor")
        case 1:
            UserDefaults.standard.setColor(color: .blue, forKey: "BackgroundPrimaryColor")
        case 2:
            UserDefaults.standard.setColor(color: .green, forKey: "BackgroundPrimaryColor")
        default:
            fatalError("Error in Segmented Control")
        }
        
        view.removeBackgroundEffects()
        view.addGradientBackground()
        view.addBlurEffect()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _configure()
    }
    
    private func _configure() {
        view.addGradientBackground()
        view.addBlurEffect()

        ColorSegmentedControl.setTitle("Red".localized(), forSegmentAt: 0)
        ColorSegmentedControl.setTitle("Blue".localized(), forSegmentAt: 1)
        ColorSegmentedControl.setTitle("Green".localized(), forSegmentAt: 2)
        
        _setCurrentSelectedIndex()
    }
    
    private func _setCurrentSelectedIndex() {
        switch UserDefaults.standard.getColor(forKey: "BackgroundPrimaryColor") {
        case UIColor.red:
            ColorSegmentedControl.selectedSegmentIndex = 0
        case UIColor.blue:
            ColorSegmentedControl.selectedSegmentIndex = 1
        case UIColor.green:
            ColorSegmentedControl.selectedSegmentIndex = 2
        default:
            ColorSegmentedControl.selectedSegmentIndex = 0
        }
    }
}
