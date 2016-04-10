//
//  PhotoTableViewCell.swift
//  fitu
//
//  Created by 刘 田源 on 4/7/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import Foundation
import UIKit

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var bkImageView: UIImageView!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}