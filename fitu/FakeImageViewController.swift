//
//  FakeImageViewController.swift
//  fitu
//
//  Created by 刘 田源 on 4/8/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class FakeImageViewController: UIViewController {

    
    var url: String!
    @IBOutlet weak var fakeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var fimage: UIImage = UIImage(named: "fake.jpg")!
        fakeImage.image = fimage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onFinishTapp(sender: AnyObject) {
        
        YepHUD.showActivityIndicator()
        
        uploadFits(YepUserDefaults.username.value!, brand: "Adidas", imageData: fakeImage.image!.asData(), photoUrl: url, failureHandler: { (reason, errorMessage) in
            
            defaultFailureHandler(reason: reason, errorMessage: errorMessage)
            
            YepHUD.hideActivityIndicator()
            
            }, completion: { photoURLString in
                YepHUD.hideActivityIndicator()
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    print("start main story")
                    
                    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                        appDelegate.startMainStory()
                    }
                    
                }
        })
        

        
    }

}
