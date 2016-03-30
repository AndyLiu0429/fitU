//
//  registerPickGender.swift
//  fitu
//
//  Created by 刘 田源 on 3/29/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class registerPickGender: UIViewController {
    
    var username: String!
    var password: String!

      @IBOutlet weak var measurementLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    
    
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var bodyShapeLabel: UILabel!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var bodyShapeSegment: UISegmentedControl!
    
    @IBAction func nextTapped(sender: AnyObject) {
        let heightField = heightTextField.text!
        let weightField = weightTextField.text!
        
        if (heightField.isEmpty || weightField.isEmpty) {
            YepAlert.alertSorry(message: "Please input all measurements", inViewController: self, withDismissAction: { [weak self] in
                self?.heightTextField.becomeFirstResponder()
                })
        }
        
        YepUserDefaults.height.value = heightField
        YepUserDefaults.weight.value = weightField
        YepUserDefaults.gender.value = String(genderSegment.selectedSegmentIndex)
        YepUserDefaults.bodyShape.value = String(bodyShapeSegment.selectedSegmentIndex)
        
        registerUsername(username, password: password, height: heightField, weight: weightField, bodyShape: bodyShapeSegment.selectedSegmentIndex, gender: genderSegment.selectedSegmentIndex, failureHandler: {
            (reason, errorMessage) in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)
            
            if let errorMessage = errorMessage {
                YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: { [weak self] in
                    self?.heightTextField.becomeFirstResponder()
                    })
            }
            
            }, completion: {
                created in
                
                if created {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("registerPickGender", sender: nil)
                    })
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.nextButton.enabled = false
                        
                        YepAlert.alertSorry(message: "register User failed", inViewController: self, withDismissAction: { [weak self] in
                            self?.heightTextField.becomeFirstResponder()
                            })
                    })
                }
                
        })
    
    }
}
