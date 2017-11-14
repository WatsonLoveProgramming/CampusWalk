//
//  NavigationViewController.swift
//  CampusWalk
//
//  Created by Watson Li on 10/22/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit

protocol NavigationDelegate : class {
    func dismissNavigation(from:String, to:String)
}

class NavigationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var locationPickerView: UIPickerView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var OkButton: UIButton!
    
    var completionBlock : (() -> Void)?
    var delegate : NavigationDelegate?
    var button : UIButton? = nil
    let mapModel = MapModel.sharedInstance

    
   var locations = ["User Location"]

    override func viewDidLoad() {
        super.viewDidLoad()

        locationPickerView.isHidden = true
        toolBar.isHidden = true
        OkButton.isEnabled = false
        
        for building in mapModel.allBuildings{
            locations.append(building.title!)
        }
    }
    
    @IBAction func showLocation(_ sender: UIButton) {
        self.button = sender
        toolBar.isHidden = false
        locationPickerView.isHidden = false

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NavigationViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }

    @IBAction func dismiss(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.dismissNavigation(from:fromButton.currentTitle!, to:toButton.currentTitle!)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        if let completionBlock = completionBlock {
            completionBlock()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locations.count
    }
   
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }
    
    func doneClick() {
        toolBar.isHidden = true
        locationPickerView.isHidden = true
        
        button?.setTitle(locations[locationPickerView.selectedRow(inComponent: 0)], for: .normal)
        
        if fromButton.currentTitle != "???" && toButton.currentTitle != "???"{
            OkButton.isEnabled = true
        }
    }

}
