//
//  loginViewController.swift
//  fitu
//
//  Created by 刘 田源 on 3/30/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {

    @IBOutlet weak var loginLabel: UILabel!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFinishTapped(sender: AnyObject) {
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if (username.isEmpty || password.isEmpty) {
            YepAlert.alertSorry(message: "Please input all measurements", inViewController: self, withDismissAction: { [weak self] in
                self?.usernameTextField.becomeFirstResponder()
                })
        }
        
//        
//        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
//            appDelegate.startMainStory()
//        }
//        
        YepHUD.showActivityIndicator()
        
        loginByUsername(username, password: password, failureHandler: { [weak self] (reason, errorMessage) in
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)
            
            YepHUD.hideActivityIndicator()
            
            if let errorMessage = errorMessage {
                dispatch_async(dispatch_get_main_queue()) {
                    self?.finishButton.enabled = false
                }
                
                YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: {
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.usernameTextField.becomeFirstResponder()
                    }
                })
            }
            
            }, completion: {loginUser in
                
                println("\(loginUser)")
                
                YepHUD.hideActivityIndicator()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    saveTokenAndUserInfoOfLoginUser(loginUser)
                    
                    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                        appDelegate.startMainStory()
                    }
                })})
        
    }

}
