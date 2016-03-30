//
//  AppDelegate.swift
//  Yep
//
//  Created by kevinzhow on 15/3/16.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//


// modified by tianyuan

import UIKit
import Fabric
import Crashlytics
import AVFoundation
import RealmSwift
import MonkeyKing
import Navi
import Appsee


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var deviceToken: NSData?
    var notRegisteredPush = true
    
    private var isFirstActive = true
    
    enum LaunchStyle {
        case Default
        case Message
    }
    var lauchStyle = Listenable<LaunchStyle>(.Default) { _ in }
    
    struct Notification {
        static let applicationDidBecomeActive = "applicationDidBecomeActive"
    }
    
    private func realmConfig() -> Realm.Configuration {
        
        // 默认将 Realm 放在 App Group 里
        
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(YepConfig.appGroupID)!
        let realmPath = directory.URLByAppendingPathComponent("db.realm").path!
        
        return Realm.Configuration(path: realmPath, schemaVersion: 25, migrationBlock: { migration, oldSchemaVersion in
        })
    }
    
    enum RemoteNotificationType: String {
        case Message = "message"
        case OfficialMessage = "official_message"
        case FriendRequest = "friend_request"
        case MessageDeleted = "message_deleted"
    }
    
    private var remoteNotificationType: RemoteNotificationType? {
        willSet {
            if let type = newValue {
                switch type {
                    
                case .Message, .OfficialMessage:
                    lauchStyle.value = .Message
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: Life Circle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        
        delay(0.5) {
            //Fabric.with([Crashlytics.self])
            Fabric.with([Crashlytics.self, Appsee.self])
            
            /*
             #if STAGING
             let apsForProduction = false
             #else
             let apsForProduction = true
             #endif
             JPUSHService.setupWithOption(launchOptions, appKey: "e521aa97cd4cd4eba5b73669", channel: "AppStore", apsForProduction: apsForProduction)
             */
            //APService.setupWithOption(launchOptions)
        }
        
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // 全局的外观自定义
        customAppearance()
        
        let isLogined = YepUserDefaults.isLogined
        
        if isLogined {
            
            // 记录启动通知类型
            if let
                notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? UILocalNotification,
                userInfo = notification.userInfo,
                type = userInfo["type"] as? String {
                remoteNotificationType = RemoteNotificationType(rawValue: type)
            }
            
        } else {
            startShowStory()
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
        println("Resign active")
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        println("Enter background")
        
//        NSNotificationCenter.defaultCenter().postNotificationName(MessageToolbar.Notification.updateDraft, object: nil)
        
        #if DEBUG
            //clearUselessRealmObjects() // only for test
        #endif
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        println("Will Foreground")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        println("Did Active")
        
        if !isFirstActive {
            syncUnreadMessages() {}
            
        } else {
            sync() // 确保该任务不是被 Remote Notification 激活 App 的时候执行
            startFaye()
        }
        
        application.applicationIconBadgeNumber = -1
        application.applicationIconBadgeNumber = 0
        
        /*
         if YepUserDefaults.isLogined {
         syncMessagesReadStatus()
         }
         */
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.applicationDidBecomeActive, object: nil)
        
        isFirstActive = false
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        
//        clearUselessRealmObjects()
    }
    
    // MARK: APNs
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("Fetch Back")
        syncUnreadMessages() {
            completionHandler(UIBackgroundFetchResult.NewData)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        defer {
            completionHandler()
        }
        
        guard #available(iOS 9, *) else {
            return
        }
        
       
        
          }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("didReceiveRemoteNotification: \(userInfo)")
        //JPUSHService.handleRemoteNotification(userInfo)
            }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        println(error.description)
    }
    
    // MARK: Open URL
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        
        if url.absoluteString.contains("/auth/success") {
            
            NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.OAuthResult, object: NSNumber(int: 1))
            
        } else if url.absoluteString.contains("/auth/failure") {
            
            NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.OAuthResult, object: NSNumber(int: 0))
            
        }
        
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        
        return false
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                    //            if let webpageURL = userActivity.webpageURL {
            //                if !handleUniversalLink(webpageURL) {
            //                    UIApplication.sharedApplication().openURL(webpageURL)
            //                }
            //            } else {
            //                return false
            //            }
        }
        
        return true
    }
    
    
    // MARK: Public
    
    func startShowStory() {
        
        let storyboard = UIStoryboard(name: "Show", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("ShowNavigationController") as! UINavigationController
        window?.rootViewController = rootViewController
    }
    
    /*
     func startIntroStory() {
     
     let storyboard = UIStoryboard(name: "Intro", bundle: nil)
     let rootViewController = storyboard.instantiateViewControllerWithIdentifier("IntroNavigationController") as! UINavigationController
     window?.rootViewController = rootViewController
     }
     */
    
    func startMainStory() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        window?.rootViewController = rootViewController
    }
    
    func sync() {
        
        guard YepUserDefaults.isLogined else {
            return
        }
       
    }
    
    func startFaye() {
        
        guard YepUserDefaults.isLogined else {
            return
        }
        
          }
    
    func registerThirdPartyPushWithDeciveToken(deviceToken: NSData, pusherID: String) {
        
        //JPUSHService.registerDeviceToken(deviceToken)
        //JPUSHService.setTags(Set(["iOS"]), alias: pusherID, callbackSelector:nil, object: nil)
//        APService.registerDeviceToken(deviceToken)
//        APService.setTags(Set(["iOS"]), alias: pusherID, callbackSelector:nil, object: nil)
    }
    
    func tagsAliasCallback(iResCode: Int, tags: NSSet, alias: NSString) {
        
        println("tagsAliasCallback \(iResCode), \(tags), \(alias)")
    }
    
    // MARK: Private
    
    private func tryReplyText(text: String, withUserInfo userInfo: [NSObject: AnyObject]) {
        
        guard let
            recipientType = userInfo["recipient_type"] as? String,
            recipientID = userInfo["recipient_id"] as? String else {
                return
        }
        
        println("try reply \"\(text)\" to [\(recipientType): \(recipientID)]")
        
       
        
    }
    
    private func syncUnreadMessages(furtherAction: () -> Void) {
        
        guard YepUserDefaults.isLogined else {
            furtherAction()
            return
        }
        
       
    }
    
    
    
    private func customAppearance() {
        
        // Global Tint Color
        
        window?.tintColor = UIColor.yepTintColor()
        window?.tintAdjustmentMode = .Normal
        
        // NavigationBar Item Style
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.yepTintColor()], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.yepTintColor().colorWithAlphaComponent(0.3)], forState: .Disabled)
        
        // NavigationBar Title Style
        
        let shadow: NSShadow = {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.lightGrayColor()
            shadow.shadowOffset = CGSizeMake(0, 0)
            return shadow
        }()
        
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.yepNavgationBarTitleColor(),
            NSShadowAttributeName: shadow,
            NSFontAttributeName: UIFont.navigationBarTitleFont()
        ]
        
        /*
         let barButtonTextAttributes = [
         NSForegroundColorAttributeName: UIColor.yepTintColor(),
         NSFontAttributeName: UIFont.barButtonFont()
         ]
         */
        
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        //UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, forState: UIControlState.Normal)
        //UINavigationBar.appearance().setBackgroundImage(UIImage(named:"white"), forBarMetrics: .Default)
        //UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().translucent = false
        
        // TabBar
        
        //UITabBar.appearance().backgroundImage = UIImage(named:"white")
        //UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().tintColor = UIColor.yepTintColor()
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        //UITabBar.appearance().translucent = false
    }
}

