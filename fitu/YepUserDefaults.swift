//
//  YepUserDefaults.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import RealmSwift

let v1AccessTokenKey = "v1AccessToken"
let userIDKey = "userID"
let usernameKey = "username"
let introductionKey = "introduction"
let avatarURLStringKey = "avatarURLString"
let badgeKey = "badge"
let heightKey = "height"
let weightKey = "weight"
let bodyShapeKey = "bodyShape"
let genderKey = "gender"

let discoveredUserSortStyleKey = "discoveredUserSortStyle"
let feedSortStyleKey = "feedSortStyle"


enum Gender:Int {
    case Male = 0
    case Female
}

enum BodyShape:Int {
    case slim = 0
    case normal
    case overweight
}

struct Listener<T>: Hashable {
    let name: String
    
    typealias Action = T -> Void
    let action: Action
    
    var hashValue: Int {
        return name.hashValue
    }
}

func ==<T>(lhs: Listener<T>, rhs: Listener<T>) -> Bool {
    return lhs.name == rhs.name
}

class Listenable<T> {
    var value: T {
        didSet {
            setterAction(value)
            
            for listener in listenerSet {
                listener.action(value)
            }
        }
    }
    
    typealias SetterAction = T -> Void
    var setterAction: SetterAction
    
    var listenerSet = Set<Listener<T>>()
    
    func bindListener(name: String, action: Listener<T>.Action) {
        let listener = Listener(name: name, action: action)
        
        listenerSet.insert(listener)
    }
    
    func bindAndFireListener(name: String, action: Listener<T>.Action) {
        bindListener(name, action: action)
        
        action(value)
    }
    
    func removeListenerWithName(name: String) {
        for listener in listenerSet {
            if listener.name == name {
                listenerSet.remove(listener)
                break
            }
        }
    }
    
    func removeAllListeners() {
        listenerSet.removeAll(keepCapacity: false)
    }
    
    init(_ v: T, setterAction action: SetterAction) {
        value = v
        setterAction = action
    }
}

class YepUserDefaults {
    
    static let defaults = NSUserDefaults(suiteName: YepConfig.appGroupID)!
    
    static var isLogined: Bool {
        
        if let _ = YepUserDefaults.v1AccessToken.value {
            return true
        } else {
            return false
        }
    }
    
    // MARK: ReLogin
    
    class func cleanAllUserDefaults() {
        
        v1AccessToken.removeAllListeners()
        userID.removeAllListeners()
        
        username.removeAllListeners()
        introduction.removeAllListeners()
        avatarURLString.removeAllListeners()
        badge.removeAllListeners()
       
        discoveredUserSortStyle.removeAllListeners()
        feedSortStyle.removeAllListeners()
                height.removeAllListeners()
        weight.removeAllListeners()
        bodyShape.removeAllListeners()
        gender.removeAllListeners()
        
        defaults.removeObjectForKey(v1AccessTokenKey)
        defaults.removeObjectForKey(userIDKey)
        defaults.removeObjectForKey(usernameKey)
        defaults.removeObjectForKey(introductionKey)
        defaults.removeObjectForKey(avatarURLStringKey)
        defaults.removeObjectForKey(badgeKey)
        defaults.removeObjectForKey(discoveredUserSortStyleKey)
        defaults.removeObjectForKey(feedSortStyleKey)
        
        defaults.removeObjectForKey(heightKey)
        defaults.removeObjectForKey(weightKey)
        defaults.removeObjectForKey(bodyShapeKey)
        defaults.removeObjectForKey(genderKey)
        
        defaults.synchronize()
    }
    
    class func userNeedRelogin() {
        
        if let _ = v1AccessToken.value {
            
            cleanRealmAndCaches()
            
            cleanAllUserDefaults()
            
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if let rootViewController = appDelegate.window?.rootViewController {
                    YepAlert.alert(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("User authentication error, you need to login again!", comment: ""), dismissTitle: NSLocalizedString("Relogin", comment: ""), inViewController: rootViewController, withDismissAction: { () -> Void in
                        
                    
                    })
                }
            }
        }
    }
    
    static var v1AccessToken: Listenable<String?> = {
        let v1AccessToken = defaults.stringForKey(v1AccessTokenKey)
        
        return Listenable<String?>(v1AccessToken) { v1AccessToken in
            defaults.setObject(v1AccessToken, forKey: v1AccessTokenKey)
            
            }
    }()
    
    static var userID: Listenable<String?> = {
        let userID = defaults.stringForKey(userIDKey)
        
        return Listenable<String?>(userID) { userID in
            defaults.setObject(userID, forKey: userIDKey)
        }
    }()
    
    static var height: Listenable<String?> = {
        let height = defaults.stringForKey(heightKey)
        
        return Listenable<String?>(height) {height in
            defaults.setObject(height, forKey: heightKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                height = height,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.height = (height as NSString).floatValue
                }
            }
            
        }
    }()
    
    static var weight: Listenable<String?> = {
        let weight = defaults.stringForKey(weightKey)
        
        return Listenable<String?>(weight) {weight in
            defaults.setObject(weight, forKey: weightKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                weight = weight,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.weight = (weight as NSString).floatValue
                }
            }
            
        }
    }()
    
    static var bodyShape: Listenable<String?> = {
        let bodyShape = defaults.stringForKey(bodyShapeKey)
        
        return Listenable<String?>(bodyShape) {bodyShape in
            defaults.setObject(bodyShape, forKey: bodyShapeKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                bodyShape = bodyShape,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.bodyShape = Int(bodyShape)!            }
            }
            
        }
    }()
    
    static var gender: Listenable<String?> = {
        let gender = defaults.stringForKey(genderKey)
        
        return Listenable<String?>(gender) {bodyShape in
            defaults.setObject(gender, forKey: genderKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                gender = gender,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.gender = Int(gender)!            }
            }
            
        }
    }()

    
    
    static var username: Listenable<String?> = {
        let username = defaults.stringForKey(usernameKey)
        
        return Listenable<String?>(username) { username in
            defaults.setObject(username, forKey: usernameKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                username = username,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.username = username
                }
            }
        }
    }()
    
    static var introduction: Listenable<String?> = {
        let introduction = defaults.stringForKey(introductionKey)
        
        return Listenable<String?>(introduction) { introduction in
            defaults.setObject(introduction, forKey: introductionKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                introduction = introduction,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.introduction = introduction
                }
            }
        }
    }()
    
    static var avatarURLString: Listenable<String?> = {
        let avatarURLString = defaults.stringForKey(avatarURLStringKey)
        
        return Listenable<String?>(avatarURLString) { avatarURLString in
            defaults.setObject(avatarURLString, forKey: avatarURLStringKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                avatarURLString = avatarURLString,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.avatarURLString = avatarURLString
                }
            }
        }
    }()
    
    static var badge: Listenable<String?> = {
        let badge = defaults.stringForKey(badgeKey)
        
        return Listenable<String?>(badge) { badge in
            defaults.setObject(badge, forKey: badgeKey)
            
            guard let realm = try? Realm() else {
                return
            }
            
            if let
                badge = badge,
                myUserID = YepUserDefaults.userID.value,
                me = userWithUserID(myUserID, inRealm: realm) {
                let _ = try? realm.write {
                    me.badge = badge
                }
            }
        }
    }()
    
    static var discoveredUserSortStyle: Listenable<String?> = {
        let discoveredUserSortStyle = defaults.stringForKey(discoveredUserSortStyleKey)
        
        return Listenable<String?>(discoveredUserSortStyle) { discoveredUserSortStyle in
            defaults.setObject(discoveredUserSortStyle, forKey: discoveredUserSortStyleKey)
        }
    }()
    
    static var feedSortStyle: Listenable<String?> = {
        let feedSortStyle = defaults.stringForKey(feedSortStyleKey)
        
        return Listenable<String?>(feedSortStyle) { feedSortStyle in
            defaults.setObject(feedSortStyle, forKey: feedSortStyleKey)
        }
    }()
    
}


