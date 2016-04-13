//
//  FakeImageViewController.swift
//  fitu
//
//  Created by 刘 田源 on 4/8/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class FinalImageViewController: UIViewController {

    var tag_pos:CGPoint!
    var url: String!
    var image: NSData!
    var brand: String = "H & M"
    var size: String = "M"
    var type: String = "T-Shirt"
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var finalImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        finalImage.image = UIImage(data: image)
        
        tagButton.center = tag_pos
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onFinishTapp(sender: AnyObject) {
        
        YepHUD.showActivityIndicator()
        
        uploadFits(YepUserDefaults.username.value!, brand: "Adidas", imageData: finalImage.image!.asData(), photoUrl: url, failureHandler: { (reason, errorMessage) in
            
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
