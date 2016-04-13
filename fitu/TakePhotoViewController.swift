//
//  TakePhotoViewController.swift
//  fitu
//
//  Created by 刘 田源 on 3/30/16.
//  Copyright © 2016 AndyLiu. All rights reserved.
//

import UIKit
import AVFoundation
import Proposer
import Navi

class TakePhotoViewController: UIViewController {

    @IBOutlet private weak var fitsImageView: UIImageView!
    @IBOutlet private weak var cameraPreviewView: CameraPreviewView!
    
    @IBOutlet private weak var openCameraButton: BorderButton!
    
    @IBOutlet private weak var cameraRollButton: UIButton!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet private weak var retakeButton: UIButton!
    
    @IBOutlet weak var tagButton: UIButton!
    
    var tag_pos: CGPoint!
    
    private var fits = UIImage() {
        willSet {
            fitsImageView.image = newValue
        }
    }
    
    private enum PickFitsState {
        case Default
        case CameraOpen
        case Captured
        case Tagged
    }
    
    @IBAction func panTaggedButton(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        
        tag_pos = sender.view!.center
        
        //print("\(tag_pos)")
        
        sender.setTranslation(CGPointZero, inView: self.view)
        
    }
    
    private var pickFitsState: PickFitsState = .Default {
        willSet {
            switch newValue {
            case .Default:
                openCameraButton.hidden = false
                tagButton.hidden = true
                
                cameraRollButton.hidden = true
                captureButton.hidden = true
                retakeButton.hidden = true
                
                cameraPreviewView.hidden = true
                fitsImageView.hidden = false
                
                fitsImageView.image = UIImage(named: "default_avatar")
                
                
            case .CameraOpen:
                openCameraButton.hidden = true
                tagButton.hidden = true
                
                cameraRollButton.hidden = false
                captureButton.hidden = false
                retakeButton.hidden = true
                
                cameraPreviewView.hidden = false
                fitsImageView.hidden = true
                
                captureButton.setImage(UIImage(named: "button_capture"), forState: .Normal)
                
                
            case .Captured:
                openCameraButton.hidden = true
                tagButton.hidden = true
                cameraRollButton.hidden = false
                captureButton.hidden = false
                retakeButton.hidden = false
                
                cameraPreviewView.hidden = true
                fitsImageView.hidden = false
                
                captureButton.setImage(UIImage(named: "button_capture_ok"), forState: .Normal)
                
            
            case .Tagged:
                openCameraButton.hidden = true
                cameraRollButton.hidden = true
                captureButton.hidden = false
                retakeButton.hidden = true
                tagButton.hidden = false
                
                cameraPreviewView.hidden = true
                fitsImageView.hidden = false
                
                captureButton.setImage(UIImage(named: "button_capture_ok"), forState: .Normal)

                            }
        }
    }
    
    private lazy var sessionQueue: dispatch_queue_t = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
    
    private lazy var session: AVCaptureSession = {
        let _session = AVCaptureSession()
        //_session.sessionPreset = AVCaptureSessionPreset640x480
        
        return _session
    }()
    
    private let mediaType = AVMediaTypeVideo
    
    private lazy var videoDeviceInput: AVCaptureDeviceInput? = {
        guard let videoDevice = self.deviceWithMediaType(self.mediaType, preferringPosition: .Front) else {
            return nil
        }
        
        return try? AVCaptureDeviceInput(device: videoDevice)
    }()
    
    private lazy var stillImageOutput: AVCaptureStillImageOutput = {
        let _stillImageOutput = AVCaptureStillImageOutput()
        _stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        return _stillImageOutput
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.yepViewBackgroundColor()
        
        navigationItem.titleView = NavigationTitleLabel(title: NSLocalizedString("Take Photo", comment: ""))
        
        
        view.backgroundColor = UIColor.whiteColor()
        
        pickFitsState = .Default
//        
//        takePicturePromptLabel.textColor = UIColor.blackColor()
//        takePicturePromptLabel.text = NSLocalizedString("Set an avatar", comment: "")
//        
        openCameraButton.setTitle(NSLocalizedString("Open Camera", comment: ""), forState: .Normal)
        openCameraButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        openCameraButton.backgroundColor = UIColor.yepTintColor()
        
        //tagButton.backgroundColor = UIColor.yepTintColor()
        
        cameraRollButton.tintColor = UIColor.yepTintColor()
        captureButton.tintColor = UIColor.yepTintColor()
        retakeButton.setTitleColor(UIColor.yepTintColor(), forState: .Normal)
        //tagButton.tintColor = UIColor.yepTintColor()
        
        
        //let panRec = UIPanGestureRecognizer()
        
        //tagButton.addTarget(self, action: "wasDragged:event:", forControlEvents: UIControlEvents.TouchDragInside)
        //tagButton.addGestureRecognizer(panRec)
        //tagButton.userInteractionEnabled = true

    }
    
    
    
    // MARK: Helpers
    
    private func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first as? AVCaptureDevice
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
    // MARK: Actions
    
    @IBAction private func tryOpenCamera(sender: UIButton) {
        proposeToAccess(.Camera, agreed: {
            self.openCamera()
            
            }, rejected: {
                self.alertCanNotOpenCamera()
        })
    }
    
    private func openCamera() {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.pickFitsState = .CameraOpen
        }
        
        dispatch_async(sessionQueue) {
            
            if self.session.canAddInput(self.videoDeviceInput) {
                self.session.addInput(self.videoDeviceInput)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.cameraPreviewView.session = self.session
                    let orientation = AVCaptureVideoOrientation(rawValue: UIInterfaceOrientation.Portrait.rawValue)!
                    (self.cameraPreviewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientation
                }
            }
            
            if self.session.canAddOutput(self.stillImageOutput){
                self.session.addOutput(self.stillImageOutput)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.session.startRunning()
            }
        }
    }
    
    @IBAction private func tryOpenCameraRoll(sender: UIButton) {
        
        let openCameraRoll: ProposerAction = { [weak self] in
            
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                self?.alertCanNotAccessCameraRoll()
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            //imagePicker.allowsEditing = true
            
            self?.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        proposeToAccess(.Photos, agreed: openCameraRoll, rejected: {
            self.alertCanNotAccessCameraRoll()
        })
    }
    
    
    @IBAction private func captureOrFinish(sender: UIButton) {
        if pickFitsState == .Captured {
            navigationItem.titleView = NavigationTitleLabel(title: NSLocalizedString("Please Tag Photo", comment: ""))
            
            //self.fitsImageView.addSubview(tagButton)
            //self.fitsImageView.bringSubviewToFront(tagButton)
            self.pickFitsState = .Tagged
            
            } else if pickFitsState == .Tagged {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("addPhotoInfo", sender: nil)
            })
            
        } else {
            dispatch_async(sessionQueue) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                guard let captureConnection = strongSelf.stillImageOutput.connectionWithMediaType(strongSelf.mediaType) else {
                    return
                }
                
                strongSelf.stillImageOutput.captureStillImageAsynchronouslyFromConnection(captureConnection, completionHandler: { imageDataSampleBuffer, error in
                    if error == nil {
                        let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        var image = UIImage(data: data)!
                        
                        if let CGImage = image.CGImage {
                            image = UIImage(CGImage: CGImage, scale: image.scale, orientation: .LeftMirrored)
                            //image = UIImage(CGImage: CGImage)
                        }
//                        
//                        image = image.fixRotation().navi_centerCropWithSize(YepConfig.avatarMaxSize())!
                        
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }
                            
                            strongSelf.fits = image
                            strongSelf.pickFitsState = .Captured
                        }
                    }
                })
            }
        }
    }
    
    @IBAction private func retake(sender: UIButton) {
        pickFitsState = .CameraOpen
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPhotoInfo" {
//            let image = fits.largestCenteredSquareImage().resizeToTargetSize(YepConfig.avatarMaxSize())
//            
//        
//            
//            let imageData = UIImageJPEGRepresentation(image, 1)
            
            let vc = segue.destinationViewController as! PhotoInfoViewController
                
            vc.tag_pos = tag_pos
            vc.imageData = fits.asData()
        }
    }
    

}

// MARK: UIImagePicker

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.fits = image
            self?.pickFitsState = .Captured
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    
}
