//
//  DiscoverViewController.swift
//  fitu
//
//  Created by 刘 田源 on 3/30/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController,CollectionViewWaterfallLayoutDelegate {

    var photos = [PhotoInfo]()
    
    var photoCollectionCellIdentifier = "PhotoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 50
        layout.footerHeight = 20
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView!.registerClass(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: photoCollectionCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCollectionCellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        let sharedImageCache = FICImageCache.sharedImageCache()
        cell.imageView.image = nil
        
        let photo = photos[indexPath.row] as PhotoInfo
        if (cell.photoInfo != photo) {
            
            sharedImageCache.cancelImageRetrievalForEntity(cell.photoInfo, withFormatName: formatName)
            
            cell.photoInfo = photo
        }
        
        sharedImageCache.retrieveImageForEntity(photo, withFormatName: formatName, completionBlock: {
            (photoInfo, _, image) -> Void in
            if (photoInfo as! PhotoInfo) == cell.photoInfo {
                cell.imageView.image = image
            }
        })
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView? = nil
        
        if kind == CollectionViewWaterfallElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
            
            if let view = reusableView {
                view.backgroundColor = UIColor.redColor()
            }
        }
        else if kind == CollectionViewWaterfallElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath)
            if let view = reusableView {
                view.backgroundColor = UIColor.blueColor()
            }
        }
        
        return reusableView!
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return photos[indexPath.item].photoSize
    }


}

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    var photoInfo: PhotoInfo?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

