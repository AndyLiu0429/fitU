//
//  registerEmail.swift
//  fitu
//
//  Created by 刘 田源 on 3/29/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class registerEmail: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmpwd: UITextField!
    
    
    @IBOutlet var nextButton: UIButton!
    
    @IBAction func nextTapped(sender: AnyObject) {
        let userName = username.text!
        let passWord = password.text!
        let confirm_password = confirmpwd.text!
        
        if (userName.isEmpty || passWord.isEmpty) {
            YepAlert.alertSorry(message: "Please input all measurements", inViewController: self, withDismissAction: { [weak self] in
                self?.username.becomeFirstResponder()
                })        } else if (passWord != confirm_password) {
            YepAlert.alertSorry(message: "Password does not match", inViewController: self, withDismissAction: { [weak self] in
                self?.username.becomeFirstResponder()
                })        }
      
        
        YepHUD.showActivityIndicator()
        
        validateUsername(userName, failureHandler: { (reason, errorMessage) in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)
            
            YepHUD.hideActivityIndicator()
            
            }, completion: {(avilable, message) in
                if (avilable) {
                     YepHUD.hideActivityIndicator()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        YepUserDefaults.username.value = userName
                        
                        self.performSegueWithIdentifier("registerPickGenderSegue", sender: ["username": userName, "password": passWord])
                    })

                } else {
                    println("Validate Username: \(message)")
                    
                    YepHUD.hideActivityIndicator()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        
                        YepAlert.alertSorry(message: message, inViewController: self, withDismissAction: { [weak self] in
                            self?.username.becomeFirstResponder()
                            })
                    }
                    
                }
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "registerPickGenderSegue" {
            
            if let info = sender as? [String: String] {
                let vc = segue.destinationViewController as! registerPickGender
                
                vc.username = info["username"]
                vc.password = info["password"]
            }
        }
    }

    
    
}
