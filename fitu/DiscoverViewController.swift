import SwiftyJSON
import Alamofire
import UIKit
import Haneke

let baseTestURL = "http://52.23.242.123"

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var datas: [SwiftyJSON.JSON] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
               Alamofire.request(.GET, baseTestURL + "/photos/").responseJSON { response in
            if response.data != nil {
                //print(response.data!)
                //print(response.response)
                //print(response.result.value)
                
                var jsonObj = SwiftyJSON.JSON(response.result.value!)
                
                if let data = jsonObj["data"].arrayValue as [SwiftyJSON.JSON]?{
                    print(data)
                    self.datas = data
                    self.tableView.reloadData()
                }
            }
        }
        
      }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 400
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath) as UITableViewCell //1
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        
        
        let data = datas[indexPath.row]
        if let captionLabel = cell.viewWithTag(100) as? UILabel {
            if let caption = data["brand"].string {
                captionLabel.text = caption
            }
        }
        if let imageView = cell.viewWithTag(101) as? UIImageView {
            if let urlString = data["photoUrl"].string{
                let url = NSURL(string: urlString)
                //imageView.userInteractionEnabled = true
                //imageView.addGestureRecognizer(tapGestureRecognizer)
                imageView.hnk_setImageFromURL(url!)
            }
        }
    
        if let thumbsUpLabel = cell.contentView.viewWithTag(102) as? UILabel {
            thumbsUpLabel.text = String(Int(arc4random_uniform(100)))
            
        }
        
        if let thumbsDownLabel = cell.contentView.viewWithTag(103) as? UILabel {
            thumbsDownLabel.text = String(Int(arc4random_uniform(50)))
            
        }
        
        if let commentLabel = cell.contentView.viewWithTag(104) as? UILabel {
            commentLabel.text = String(Int(arc4random_uniform(100)))
            
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