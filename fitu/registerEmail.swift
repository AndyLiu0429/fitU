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
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if (userName != confirm_password) {
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Passwords doesn't Match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        YepHUD.showActivityIndicator()
        
        validateUsername(userName, failureHandler: { (reason, errorMessage) in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)
            
            YepHUD.hideActivityIndicator()
            
            }, completion: {(avilable, message) in
                if (avilable) {
                    YepUserDefaults.username.value = userName
                    self.performSegueWithIdentifier("registerPickGender", sender: ["username": userName, "password": passWord])
                    
                } else {
                    println("Validate Username: \(message)")
                    
                    YepHUD.hideActivityIndicator()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.nextButton.enabled = false
                        
                        YepAlert.alertSorry(message: message, inViewController: self, withDismissAction: { [weak self] in
                            self?.username.becomeFirstResponder()
                            })
                    }
                    
                }
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "registerPickGender" {
            
            if let info = sender as? [String: String] {
                let vc = segue.destinationViewController as! registerPickGender
                
                vc.username = info["username"]
                vc.password = info["password"]
            }
        }
    }

    
    
}
