import SwiftyJSON
import Alamofire
import UIKit
import Haneke

class FeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var datas: [SwiftyJSON.JSON] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var currentUrl = baseTestURL + "/photos/" + YepUserDefaults.username.value! + "/"
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        Alamofire.request(.GET,currentUrl).responseJSON { response in
            if response.data != nil {
                //print(response.data!)
                //print(response.response)
                //print(response.result.value)
                
                var jsonObj = SwiftyJSON.JSON(response.result.value!)
                
                if let data = jsonObj["data"].arrayValue as [SwiftyJSON.JSON]?{
                    //print(data)
                    self.datas = data
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 520
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 520
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyPhotoCell", forIndexPath: indexPath) as UITableViewCell //1
        //        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        print("here")
        
        let data = datas[indexPath.row]
        if let captionLabel = cell.contentView.viewWithTag(200) as? UILabel {
            if let caption = data["brand"].string {
                captionLabel.text = caption
            }
        }
        if let imageView = cell.contentView.viewWithTag(201) as? UIImageView {
            if let urlString = data["photoUrl"].string{
                let url = NSURL(string: urlString)
                //imageView.userInteractionEnabled = true
                //imageView.addGestureRecognizer(tapGestureRecognizer)
                imageView.hnk_setImageFromURL(url!)
            }
        }
        
        if let thumbsUpLabel = cell.contentView.viewWithTag(202) as? UILabel {
            thumbsUpLabel.text = String(Int(arc4random_uniform(10)))

        }
        
        if let thumbsDownLabel = cell.contentView.viewWithTag(203) as? UILabel {
            thumbsDownLabel.text = String(Int(arc4random_uniform(5)))
            
        }
        
        if let commentLabel = cell.contentView.viewWithTag(204) as? UILabel {
            commentLabel.text = String(Int(arc4random_uniform(10)))
            
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //NSLog("You selected cell number: \(indexPath.row)!")
        var data = datas[indexPath.row]
        
        if let url = NSURL(string: data["buylink"].string!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}