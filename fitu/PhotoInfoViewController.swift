//
//  PhotoInfoViewController.swift
//  fitu
//
//  Created by 刘 田源 on 4/6/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    var imageData: NSData!
    
    var brand: String = "H & M"
    var size: String = "M"
    var type: String = "T-Shirt"
    
    
      @IBOutlet weak var PromptLabel: UILabel!
    
    @IBOutlet weak var urlText: UITextField!
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var myPicker: UIPickerView!
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var sizePicker: UIPickerView!
    let Brands = ["Adidas", "Nike", "Under Armor", "H & M", "Zara", "Uniqlo"]
    let SIZE = ["XS", "S", "M", "L", "XL", "XXL"]
    
    let TYPES = ["T-Shirts", "Dress", "Jeans", "Pants", "Underwears", "Coats"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        myPicker.dataSource = self
        myPicker.delegate = self
        
        typePicker.dataSource = self
        typePicker.delegate = self

        sizePicker.delegate = self
        sizePicker.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) {
            return Brands.count
        } else if (pickerView.tag == 1) {
            return SIZE.count
        } else {
            return TYPES.count
        }
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0) {
            return Brands[row]
        } else if (pickerView.tag == 1) {
            return SIZE[row]
        } else {
            return TYPES[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView.tag == 0) {
            brand = Brands[row]
        } else if (pickerView.tag == 1) {
            size = SIZE[row]
        } else if (pickerView.tag == 2) {
            type = TYPES[row]
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if (pickerView.tag == 0) {
        let titleData = Brands[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
        } else if (pickerView.tag == 1) {
            let titleData = SIZE[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
            return myTitle
  
        } else {
            let titleData = TYPES[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
            return myTitle
        }
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onFinishTap(sender: AnyObject) {
        var url: String = urlText.text!
        //var review: String = reviewText.text!
        
        self.performSegueWithIdentifier("showFakeImage", sender: ["buylink": url])
          }
   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFakeImage" {
            
            if let info = sender as? [String: String] {
                let vc = segue.destinationViewController as! FakeImageViewController
                vc.url = info["buylink"]
                           }
        }
    }
    

    

}
