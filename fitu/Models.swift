//
//  Models.swift
//  Yep
//
//  Created by NIX on 15/3/20.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
// Adopted by Tianyuan

import UIKit
import RealmSwift
import Crashlytics
import MapKit

// 总是在这个队列里使用 Realm
//let realmQueue = dispatch_queue_create("com.Yep.realmQueue", DISPATCH_QUEUE_SERIAL)
let realmQueue = dispatch_queue_create("com.YourApp.YourQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0))

// MARK: User

class Avatar: Object {
    dynamic var avatarURLString: String = ""
    dynamic var avatarFileName: String = ""
    
    dynamic var roundMini: NSData = NSData() // 60
    dynamic var roundNano: NSData = NSData() // 40
    
    var user: User? {
        let users = linkingObjects(User.self, forProperty: "avatar")
        return users.first
    }
}


class UserSocialAccountProvider: Object {
    dynamic var name: String = ""
    dynamic var enabled: Bool = false
}


class User: Object {
    dynamic var userID: String = ""
    dynamic var username: String = ""
    dynamic var nickname: String = ""
    dynamic var introduction: String = ""
    dynamic var avatarURLString: String = ""
    dynamic var avatar: Avatar?
    dynamic var badge: String = ""
    dynamic var email: String = ""

    dynamic var height: Float = 0.0
    dynamic var weight: Float = 0.0
    dynamic var bodyShape: Int = 0
    dynamic var gender: Int = 0
    
    override class func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var lastSignInUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var notificationEnabled: Bool = true
    dynamic var blocked: Bool = false
    
    var socialAccountProviders = List<UserSocialAccountProvider>()
    
    var createdFeeds: [Feed] {
        return linkingObjects(Feed.self, forProperty: "creator")
    }
    
    var isMe: Bool {
        if let myUserID = YepUserDefaults.userID.value {
            return userID == myUserID
        }
        
        return false
    }
    
   }

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension User: Hashable {
    
    override var hashValue: Int {
        return userID.hashValue
    }
}

// MARK: Group

// Group 类型，注意：上线后若要调整，只能增加新状态
enum GroupType: Int {
    case Public     = 0
    case Private    = 1
}

class Group: Object {
    dynamic var groupID: String = ""
    dynamic var groupName: String = ""
    dynamic var notificationEnabled: Bool = true
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var owner: User?
    var members = List<User>()
    
    dynamic var groupType: Int = GroupType.Public.rawValue
    
    var withFeed: Feed? {
        return linkingObjects(Feed.self, forProperty: "group").first
    }
    
    dynamic var includeMe: Bool = false
    
    
    // 级联删除关联的数据对象
    
    }

// MARK: Message
enum MessageDownloadState: Int {
    case NoDownload     = 0 // 未下载
    case Downloading    = 1 // 下载中
    case Downloaded     = 2 // 已下载
}

enum MessageMediaType: Int, CustomStringConvertible {
    case Text           = 0
    case Image          = 1
    case Video          = 2
    case Audio          = 3
    case Sticker        = 4
    case Location       = 5
    case SectionDate    = 6
    case SocialWork     = 7
    
    var description: String {
        switch self {
        case .Text:
            return "text"
        case .Image:
            return "image"
        case .Video:
            return "video"
        case .Audio:
            return "audio"
        case .Sticker:
            return "sticker"
        case .Location:
            return "location"
        case .SectionDate:
            return "sectionDate"
        case .SocialWork:
            return "socialWork"
        }
    }
    
    var fileExtension: FileExtension? {
        switch self {
        case .Image:
            return .JPEG
        case .Video:
            return .MP4
        case .Audio:
            return .M4A
        default:
            return nil // TODO: more
        }
    }
    
    var placeholder: String? {
        switch self {
        case .Text:
            return nil
        case .Image:
            return NSLocalizedString("[Image]", comment: "")
        case .Video:
            return NSLocalizedString("[Video]", comment: "")
        case .Audio:
            return NSLocalizedString("[Audio]", comment: "")
        case .Sticker:
            return NSLocalizedString("[Sticker]", comment: "")
        case .Location:
            return NSLocalizedString("[Location]", comment: "")
        case .SocialWork:
            return NSLocalizedString("[Social Work]", comment: "")
        default:
            return NSLocalizedString("All message read", comment: "")
        }
    }
}

enum MessageSendState: Int, CustomStringConvertible {
    case NotSend    = 0
    case Failed     = 1
    case Successed  = 2
    case Read       = 3
    
    var description: String {
        get {
            switch self {
            case NotSend:
                return "NotSend"
            case Failed:
                return "Failed"
            case Successed:
                return "Sent"
            case Read:
                return "Read"
            }
        }
    }
}

class MediaMetaData: Object {
    dynamic var data: NSData = NSData()
    
    var string: String? {
        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    }
}

class SocialWorkGithubRepo: Object {
    dynamic var repoID: Int = 0
    dynamic var name: String = ""
    dynamic var fullName: String = ""
    dynamic var URLString: String = ""
    dynamic var repoDescription: String = ""
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var synced: Bool = false
    
    class func getWithRepoID(repoID: Int, inRealm realm: Realm) -> SocialWorkGithubRepo? {
        let predicate = NSPredicate(format: "repoID = %d", repoID)
        return realm.objects(SocialWorkGithubRepo).filter(predicate).first
    }
    
  }

class SocialWorkDribbbleShot: Object {
    dynamic var shotID: Int = 0
    dynamic var title: String = ""
    dynamic var htmlURLString: String = ""
    dynamic var imageURLString: String = ""
    dynamic var shotDescription: String = ""
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var synced: Bool = false
    
    class func getWithShotID(shotID: Int, inRealm realm: Realm) -> SocialWorkDribbbleShot? {
        let predicate = NSPredicate(format: "shotID = %d", shotID)
        return realm.objects(SocialWorkDribbbleShot).filter(predicate).first
    }
    
    
}

class SocialWorkInstagramMedia: Object {
    dynamic var repoID: String = ""
    dynamic var linkURLString: String = ""
    dynamic var imageURLString: String = ""
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var synced: Bool = false
}

enum MessageSocialWorkType: Int {
    case GithubRepo     = 0
    case DribbbleShot   = 1
    case InstagramMedia = 2
    
    var accountName: String {
        switch self {
        case .GithubRepo: return "github"
        case .DribbbleShot: return "dribbble"
        case .InstagramMedia: return "instagram"
        }
    }
}

class MessageSocialWork: Object {
    dynamic var type: Int = MessageSocialWorkType.GithubRepo.rawValue
    
    dynamic var githubRepo: SocialWorkGithubRepo?
    dynamic var dribbbleShot: SocialWorkDribbbleShot?
    dynamic var instagramMedia: SocialWorkInstagramMedia?
}

class Message: Object {
    dynamic var messageID: String = ""
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var arrivalUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var mediaType: Int = MessageMediaType.Text.rawValue
    
    dynamic var textContent: String = ""
    
    var recalledTextContent: String {
        let nickname = fromFriend?.nickname ?? ""
        return String(format: NSLocalizedString("%@ recalled a message.", comment: ""), nickname)
    }
    
    dynamic var openGraphDetected: Bool = false
    dynamic var openGraphInfo: OpenGraphInfo?
    
    
    dynamic var attachmentURLString: String = ""
    dynamic var localAttachmentName: String = ""
    dynamic var thumbnailURLString: String = ""
    dynamic var localThumbnailName: String = ""
    dynamic var attachmentID: String = ""
    dynamic var attachmentExpiresUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970 + (6 * 60 * 60 * 24) // 6天，过期时间s3为7天，客户端防止误差减去1天
    
    var nicknameWithTextContent: String {
        if let nickname = fromFriend?.nickname {
            return String(format: NSLocalizedString("%@: %@", comment: ""), nickname, textContent)
        } else {
            return textContent
        }
    }
    
    var thumbnailImage: UIImage? {
        switch mediaType {
        case MessageMediaType.Image.rawValue:
            if let imageFileURL = NSFileManager.yepMessageImageURLWithName(localAttachmentName) {
                return UIImage(contentsOfFile: imageFileURL.path!)
            }
        case MessageMediaType.Video.rawValue:
            if let imageFileURL = NSFileManager.yepMessageImageURLWithName(localThumbnailName) {
                return UIImage(contentsOfFile: imageFileURL.path!)
            }
        default:
            return nil
        }
        return nil
    }
    
    dynamic var mediaMetaData: MediaMetaData?
    
    dynamic var socialWork: MessageSocialWork?
    
    dynamic var downloadState: Int = MessageDownloadState.NoDownload.rawValue
    dynamic var sendState: Int = MessageSendState.NotSend.rawValue
    dynamic var readed: Bool = false
    dynamic var mediaPlayed: Bool = false // 音频播放过，图片查看过等
    dynamic var hidden: Bool = false // 隐藏对方消息，使之不再显示
    dynamic var deletedByCreator: Bool = false
    
    dynamic var fromFriend: User?
    
    var isReal: Bool {
        
        if socialWork != nil {
            return false
        }
        
        if mediaType == MessageMediaType.SectionDate.rawValue {
            return false
        }
        
        return true
    }
    
    func deleteAttachmentInRealm(realm: Realm) {
        
        if let mediaMetaData = mediaMetaData {
            realm.delete(mediaMetaData)
        }
        
        // 除非没有谁指向 openGraphInfo，不然不能删除它
        if let openGraphInfo = openGraphInfo {
            if openGraphInfo.feeds.isEmpty {
                if openGraphInfo.messages.count == 1, let first = openGraphInfo.messages.first where first == self {
                    realm.delete(openGraphInfo)
                }
            }
        }
        
        switch mediaType {
            
        case MessageMediaType.Image.rawValue:
            NSFileManager.removeMessageImageFileWithName(localAttachmentName)
            
        case MessageMediaType.Video.rawValue:
            NSFileManager.removeMessageVideoFilesWithName(localAttachmentName, thumbnailName: localThumbnailName)
            
        case MessageMediaType.Audio.rawValue:
            NSFileManager.removeMessageAudioFileWithName(localAttachmentName)
            
        case MessageMediaType.Location.rawValue:
            NSFileManager.removeMessageImageFileWithName(localAttachmentName)
            
        case MessageMediaType.SocialWork.rawValue:
            
            if let socialWork = socialWork {
                
                if let githubRepo = socialWork.githubRepo {
                    realm.delete(githubRepo)
                }
                
                if let dribbbleShot = socialWork.dribbbleShot {
                    realm.delete(dribbbleShot)
                }
                
                if let instagramMedia = socialWork.instagramMedia {
                    realm.delete(instagramMedia)
                }
                
                realm.delete(socialWork)
            }
            
        default:
            break // TODO: if have other message media need to delete
        }
    }
    
    func deleteInRealm(realm: Realm) {
        deleteAttachmentInRealm(realm)
        realm.delete(self)
    }
    
    func updateForDeletedFromServerInRealm(realm: Realm) {
        
        deletedByCreator = true
        
        // 删除附件
        deleteAttachmentInRealm(realm)
        
        // 再将其变为文字消息
        sendState = MessageSendState.Read.rawValue
        readed = true
        textContent = ""
        mediaType = MessageMediaType.Text.rawValue
    }
}

// MARK: Conversation
// MARK: Feed

//enum AttachmentKind: String {
//
//    case Image = "image"
//    case Thumbnail = "thumbnail"
//    case Audio = "audio"
//    case Video = "video"
//}

class OpenGraphInfo: Object {
    
    dynamic var URLString: String = ""
    dynamic var siteName: String = ""
    dynamic var title: String = ""
    dynamic var infoDescription: String = ""
    dynamic var thumbnailImageURLString: String = ""
    
    var messages: [Message] {
        return linkingObjects(Message.self, forProperty: "openGraphInfo")
    }
    var feeds: [Feed] {
        return linkingObjects(Feed.self, forProperty: "openGraphInfo")
    }
    
    override class func primaryKey() -> String? {
        return "URLString"
    }
    
    override class func indexedProperties() -> [String] {
        return ["URLString"]
    }
    
    convenience init(URLString: String, siteName: String, title: String, infoDescription: String, thumbnailImageURLString: String) {
        self.init()
        
        self.URLString = URLString
        self.siteName = siteName
        self.title = title
        self.infoDescription = infoDescription
        self.thumbnailImageURLString = thumbnailImageURLString
    }
    
    class func withURLString(URLString: String, inRealm realm: Realm) -> OpenGraphInfo? {
        return realm.objects(OpenGraphInfo).filter("URLString = %@", URLString).first
    }
}

extension OpenGraphInfo: OpenGraphInfoType {
    
    var URL: NSURL {
        return NSURL(string: URLString)!
    }
}

class Feed: Object {
    
    dynamic var feedID: String = ""
    dynamic var allowComment: Bool = true
    
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var updatedUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    
    dynamic var creator: User?
    
    dynamic var messagesCount: Int = 0
    dynamic var body: String = ""
    
    

    dynamic var socialWork: MessageSocialWork?
 
    dynamic var openGraphInfo: OpenGraphInfo?
    
    // 级联删除关联的数据对象
    
    func cascadeDeleteInRealm(realm: Realm) {
        
        if let socialWork = socialWork {
            
            if let githubRepo = socialWork.githubRepo {
                realm.delete(githubRepo)
            }
            
            if let dribbbleShot = socialWork.dribbbleShot {
                realm.delete(dribbbleShot)
            }
            
            if let instagramMedia = socialWork.instagramMedia {
                realm.delete(instagramMedia)
            }
            
            realm.delete(socialWork)
        }
        
        // 除非没有谁指向 openGraphInfo，不然不能删除它
        if let openGraphInfo = openGraphInfo {
            if openGraphInfo.messages.isEmpty {
                if openGraphInfo.feeds.count == 1, let first = openGraphInfo.messages.first where first == self {
                    realm.delete(openGraphInfo)
                }
            }
        }
        
        realm.delete(self)
    }
}

// MARK: Offline JSON

enum OfflineJSONName: String {
    
    case Feeds
    case DiscoveredUsers
}

class OfflineJSON: Object {
    
    dynamic var name: String!
    dynamic var data: NSData!
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    convenience init(name: String, data: NSData) {
        self.init()
        
        self.name = name
        self.data = data
    }
    
    var JSON: JSONDictionary? {
        return decodeJSON(data)
    }
    
    class func withName(name: OfflineJSONName, inRealm realm: Realm) -> OfflineJSON? {
        return realm.objects(OfflineJSON).filter("name = %@", name.rawValue).first
    }
}

class UserLocationName: Object {
    
    dynamic var userID: String = ""
    dynamic var locationName: String = ""
    
    override class func primaryKey() -> String? {
        return "userID"
    }
    
    override class func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    convenience init(userID: String, locationName: String) {
        self.init()
        
        self.userID = userID
        self.locationName = locationName
    }
    
    class func withUserID(userID: String, inRealm realm: Realm) -> UserLocationName? {
        return realm.objects(UserLocationName).filter("userID = %@", userID).first
    }
}

// MARK: Helpers

func userWithUserID(userID: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "userID = %@", userID)
    
    #if DEBUG
        let users = realm.objects(User).filter(predicate)
        if users.count > 1 {
            println("Warning: same userID: \(users.count), \(userID)")
        }
    #endif
    
    return realm.objects(User).filter(predicate).first
}

func userWithUsername(username: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "username = %@", username)
    return realm.objects(User).filter(predicate).first
}

func userWithAvatarURLString(avatarURLString: String, inRealm realm: Realm) -> User? {
    let predicate = NSPredicate(format: "avatarURLString = %@", avatarURLString)
    return realm.objects(User).filter(predicate).first
}


func feedWithFeedID(feedID: String, inRealm realm: Realm) -> Feed? {
    let predicate = NSPredicate(format: "feedID = %@", feedID)
    
    #if DEBUG
        let feeds = realm.objects(Feed).filter(predicate)
        if feeds.count > 1 {
            println("Warning: same feedID: \(feeds.count), \(feedID)")
        }
    #endif
    
    return realm.objects(Feed).filter(predicate).first
}

func avatarWithAvatarURLString(avatarURLString: String, inRealm realm: Realm) -> Avatar? {
    let predicate = NSPredicate(format: "avatarURLString = %@", avatarURLString)
    return realm.objects(Avatar).filter(predicate).first
}

func tryGetOrCreateMeInRealm(realm: Realm) -> User? {
    if let userID = YepUserDefaults.userID.value {
        
        if let me = userWithUserID(userID, inRealm: realm) {
            return me
            
        } else {
            
            let me = User()
            
            me.userID = userID
            
            if let nickname = YepUserDefaults.nickname.value {
                me.nickname = nickname
            }
            
            if let avatarURLString = YepUserDefaults.avatarURLString.value {
                me.avatarURLString = avatarURLString
            }
            
            let _ = try? realm.write {
                realm.add(me)
            }
            
            return me
        }
    }
    
    return nil
}

func blurredThumbnailImageOfMessage(message: Message) -> UIImage? {
    
    if let mediaMetaData = message.mediaMetaData {
        if let metaDataInfo = decodeJSON(mediaMetaData.data) {
            if let blurredThumbnailString = metaDataInfo[YepConfig.MetaData.blurredThumbnailString] as? String {
                if let data = NSData(base64EncodedString: blurredThumbnailString, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                    return UIImage(data: data)
                }
            }
        }
    }
    
    return nil
}
// MARK: Update with info

func updateUserWithUserID(userID: String, useUserInfo userInfo: JSONDictionary, inRealm realm: Realm) {
    
    if let user = userWithUserID(userID, inRealm: realm) {
        
        // 更新用户信息
        
        if let lastSignInUnixTime = userInfo["last_sign_in_at"] as? NSTimeInterval {
            user.lastSignInUnixTime = lastSignInUnixTime
        }
        
        if let username = userInfo["username"] as? String {
            user.username = username
        }
        
        if let nickname = userInfo["nickname"] as? String {
            user.nickname = nickname
        }
        
        if let height = userInfo["height"] as? Float {
            user.height = height
        }
        
        if let weight = userInfo["weight"] as? Float {
            user.weight = weight
        }
        
        if let bodyShape = userInfo["bodyShape"] as? Int {
            user.bodyShape = bodyShape
        }
        
        if let introduction = userInfo["introduction"] as? String {
            user.introduction = introduction
        }
        
        if let avatarInfo = userInfo["avatar"] as? JSONDictionary, avatarURLString = avatarInfo["url"] as? String {
            user.avatarURLString = avatarURLString
        }
    }
}

// MARK: Delete
func clearUselessRealmObjects() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    println("do clearUselessRealmObjects")
    
    realm.beginWrite()
    
    // Message
    
    do {
        // 7天前
        let oldThresholdUnixTime = NSDate(timeIntervalSinceNow: -(60 * 60 * 24 * 7)).timeIntervalSince1970
        
        let predicate = NSPredicate(format: "createdUnixTime < %f", oldThresholdUnixTime)
        let oldMessages = realm.objects(Message).filter(predicate)
        
        println("oldMessages.count: \(oldMessages.count)")
        
        oldMessages.forEach({
            $0.deleteAttachmentInRealm(realm)
            realm.delete($0)
        })
    }
    
    // Feed
    
    
    let _ = try? realm.commitWrite()
}

