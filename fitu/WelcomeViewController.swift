//
//  WelcomeViewController.swift
//  fitu
//
//  Created by 刘 田源 on 3/29/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var logoLabel: UILabel!
    
    @IBOutlet var companyLabel: UILabel!
    
    @IBOutlet var logoText: UILabel!
    
    
    
    @IBOutlet var registerButton: BorderButton!
    
    @IBOutlet var loginButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        logoLabel.text = NSLocalizedString("FitU", comment: "")
        logoText.text = NSLocalizedString("Find the clothes best fit you", comment: "")
        
        registerButton.setTitle(NSLocalizedString("Sign Up", comment: ""), forState: .Normal)
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), forState: .Normal)
        
        companyLabel.text = NSLocalizedString("Haha Inc.", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction private func register(sender: UIButton) {
        performSegueWithIdentifier("showRegisterPickEmail", sender: nil)
    }
    
    @IBAction private func login(sender: UIButton) {
        performSegueWithIdentifier("showLoginByMobile", sender: nil)
    }

}
