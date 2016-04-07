//
//  registerPickGender.swift
//  fitu
//
//  Created by 刘 田源 on 3/29/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit



class registerPickGender: UIViewController {
    
    let BodyShape = ["Pear", "Apple", "Banana"]
    let GenderData = ["Male", "Female"]
    
    var username: String!
    var password: String!

    @IBOutlet weak var measurementLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet var genderSegment: UISegmentedControl!
    
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var bodyShapeLabel: UILabel!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var bodyShapeSegment: UISegmentedControl!
    
    var gender: String = "Male"
    var bodyShape: String = "Pear"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
          }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
   
    @IBAction func onGenderChange(sender: AnyObject) {
                gender = GenderData[genderSegment.selectedSegmentIndex]
    }
    
    
    @IBAction func onShapeChange(sender: AnyObject) {
        bodyShape = BodyShape[bodyShapeSegment.selectedSegmentIndex]
    }
    
    @IBAction func nextTapped(sender: AnyObject) {
        let heightField = heightTextField.text!
        let weightField = weightTextField.text!
        
        
        if (heightField.isEmpty || weightField.isEmpty) {
            YepAlert.alertSorry(message: "Please input all measurements", inViewController: self, withDismissAction: { [weak self] in
                self?.heightTextField.becomeFirstResponder()
                })
        }
        
//        YepUserDefaults.height.value = heightField
//        YepUserDefaults.weight.value = weightField
//        YepUserDefaults.gender.value = gender
//        YepUserDefaults.bodyShape.value = bodyShape
        
       

        registerUsername(username, password: password, height: heightField, weight: weightField, bodyShape: bodyShape, gender: gender, failureHandler: {
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
                        self.performSegueWithIdentifier("showRegisterPickAvatar", sender: nil)
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
