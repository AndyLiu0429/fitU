//
//  PhotoInfo.swift
//  fitu
//
//  Created by 刘 田源 on 3/30/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import Foundation
import Alamofire
import FastImageCache

class PhotoInfo: NSObject, FICEntity {
    var UUID: String {
        let imageName = sourceImageURL.lastPathComponent!
        let UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName)
        return FICStringWithUUIDBytes(UUIDBytes)
    }
    
    var sourceImageUUID: String {
        return UUID
    }
    
    var photoSize: CGSize
    
    var sourceImageURL: NSURL
    var request: Alamofire.Request?
    
    init(sourceImageURL: NSURL) {
        self.sourceImageURL = sourceImageURL
        
        let random = Int(arc4random_uniform((UInt32(100))))
        self.photoSize = CGSize(width: 140, height: 50 + random)
        super.init()
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! PhotoInfo).UUID == self.UUID
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return sourceImageURL
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        
        let drawingBlock:FICEntityImageDrawingBlock = {
            (context:CGContextRef!, contextSize:CGSize) in
            var contextBounds = CGRectZero
            contextBounds.size = contextSize
            CGContextClearRect(context, contextBounds)
            
            UIGraphicsPushContext(context)
            image.drawInRect(contextBounds)
            UIGraphicsPopContext()
        }
        return drawingBlock
    }
    
    
}
