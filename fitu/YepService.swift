//
//  YepService.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import Alamofire

#if STAGING
let BaseURL = NSURL(string: "https://park-staging.catchchatchina.com/api")!
#else
let BaseURL = NSURL(string: "")!
#endif

// Models

struct LoginUser: CustomStringConvertible {
    let accessToken: String
    let userID: String
    let username: String
    let height: Float
    let weight: Float
    let bodyShape: Int
    let gender: Int
    let avatarURLString: String?
    
    var description: String {
        return "LoginUser(accessToken: \(accessToken), userID: \(userID), username: \(username), avatarURLString: \(avatarURLString), \(height), \(weight), \(bodyShape))"
    }
}

/*
struct QiniuProvider: CustomStringConvertible {
    let token: String
    let key: String
    let downloadURLString: String

    var description: String {
        return "QiniuProvider(token: \(token), key: \(key), downloadURLString: \(downloadURLString))"
    }
}
*/

func saveTokenAndUserInfoOfLoginUser(loginUser: LoginUser) {
    YepUserDefaults.userID.value = loginUser.userID
    YepUserDefaults.username.value = loginUser.username
    YepUserDefaults.avatarURLString.value = loginUser.avatarURLString


    // NOTICE: 因为一些操作依赖于 accessToken 做检测，又可能依赖上面其他值，所以要放在最后赋值
    YepUserDefaults.v1AccessToken.value = loginUser.accessToken
}

// MARK: - Register

func validateUsername(username: String, failureHandler: FailureHandler?, completion: ((Bool, String)) -> Void) {
    let requestParameters = [
    "username": username]
    
    let parse: JSONDictionary -> (Bool, String)? = { data in
        println("data: \(data)")
        
        if let available = data["available"] as? Bool {
            if available {
                return (available, "")
            } else {
                if let message = data["message"] as? String {
                    return (available, message)
                }
            }
        }
        
        return (false, "")
        
    }
    
    let resource = jsonResource(path: "/v1/users/username_validate", method: .GET, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func registerUsername(username: String, password: String, height: String, weight: String, bodyShape: Int, gender: Int, failureHandler: FailureHandler?, completion: Bool -> Void) {
    
    let requestParameters = [
        "username": username,
        "password": password ]
    
    let parse: JSONDictionary -> Bool? = { data in
        println("data: \(data)")
        
        if let status  = data["status"] as? String {
            if status == "ok" {
                return true
            }
        }
        
        return false
    }
    
    let resource = jsonResource(path: "/v1/register/create", method: .POST, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
    
}


func verifyUsername(username: String, password: String, failureHandler: FailureHandler?, completion: LoginUser -> Void) {
    let requestParameters = [
        "username": username, "password": password]
    
    let parse: JSONDictionary -> LoginUser? = { data in
        
        if let accessToken = data["access_token"] as? String {
            if let user = data["user"] as? [String: AnyObject] {
                if
                    let userID = user["id"] as? String,
                    let username = user["username"] as? String
                    {
                        let height = user["height"] as! Float
                        let weight = user["weight"] as! Float
                        let bodyShape = user["bodyShape"] as! Int
                        let gender = user["gender"] as! Int
                        let avatarURLString = user["avatar_url"] as? String
                        
                        return LoginUser(accessToken: accessToken, userID: userID, username: username, height:height, weight:weight, bodyShape: bodyShape,gender: gender,avatarURLString: avatarURLString)
                }
            }
        }
        
        return nil
    }
    
    let resource = jsonResource(path: "/v1/registration/verify", method: .PUT, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
    
}

// MARK: - User

func userInfoOfUserWithUserID(userID: String, failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {
    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }

    let resource = authJsonResource(path: "/v1/users/\(userID)", method: .GET, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func discoverUserByUsername(username: String, failureHandler: FailureHandler?, completion: DiscoveredUser -> Void) {

    let parse: JSONDictionary -> DiscoveredUser? = { data in

        //println("discoverUserByUsernamedata: \(data)")
        return parseDiscoveredUser(data)
    }

    let resource = authJsonResource(path: "/v1/users/\(username)/profile", method: .GET, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// 自己的信息
func userInfo(failureHandler failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {
    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }

    let resource = authJsonResource(path: "/v1/user", method: .GET, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func updateMyselfWithInfo(info: JSONDictionary, failureHandler: FailureHandler?, completion: Bool -> Void) {

    // nickname
    // avatar_url
    // username
    // latitude
    // longitude

    let parse: JSONDictionary -> Bool? = { data in
        //println("updateMyself \(data)")
        return true
    }
    
    let resource = authJsonResource(path: "/v1/user", method: .PATCH, requestParameters: info, parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func updateAvatarWithImageData(imageData: NSData, failureHandler: FailureHandler?, completion: String -> Void) {

    guard let token = YepUserDefaults.v1AccessToken.value else {
        println("updateAvatarWithImageData no token")
        return
    }

    let parameters: [String: String] = [
        "Authorization": "Token token=\"\(token)\"",
    ]

    let filename = "avatar.jpg"

    Alamofire.upload(.PATCH, BaseURL.absoluteString + "/v1/user/set_avatar", headers: parameters, multipartFormData: { multipartFormData in

        multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: filename, mimeType: "image/jpeg")

    }, encodingCompletion: { encodingResult in
        //println("encodingResult: \(encodingResult)")

        switch encodingResult {

        case .Success(let upload, _, _):

            upload.responseJSON(completionHandler: { response in

                guard let
                    data = response.data,
                    json = decodeJSON(data),
                    avatarInfo = json["avatar"] as? JSONDictionary,
                    avatarURLString = avatarInfo["url"] as? String
                else {
                    failureHandler?(reason: .CouldNotParseJSON, errorMessage: nil)
                    return
                }

                completion(avatarURLString)
            })

        case .Failure(let encodingError):

            failureHandler?(reason: .Other(nil), errorMessage: "\(encodingError)")
        }
    })
}

func loginByUsername(username: String, password: String, failureHandler: FailureHandler?, completion: LoginUser -> Void) {
    
    
    let requestParameters: JSONDictionary = [
    "username": username,
    "password": password]
    
    let parse: JSONDictionary -> LoginUser? = { data in
        
        if let accessToken = data["access_token"] as? String {
            if let user = data["user"] as? [String: AnyObject] {
                if
                    let userID = user["id"] as? String,
                    let username = user["username"] as? String
                {
                    let height = user["height"] as! Float
                    let weight = user["weight"] as! Float
                    let bodyShape = user["bodyShape"] as! Int
                    let avatarURLString = user["avatar_url"] as? String
                    
                    return LoginUser(accessToken: accessToken, userID: userID, username: username, height:height, weight:weight, bodyShape: bodyShape, avatarURLString: avatarURLString)
                }
            }
        }
        
        return nil
    }

    
    let resource = jsonResource(path: "/v1/auth/token", method: .POST, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func logout(failureHandler failureHandler: FailureHandler?, completion: () -> Void) {

    let parse: JSONDictionary -> Void? = { data in
        return
    }

    let resource = authJsonResource(path: "/v1/auth/logout", method: .DELETE, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - UploadAttachment

struct UploadAttachment {

    enum Type: String {
        case Message = "Message"
        case Feed = "Topic"
    }
    let type: Type

    enum Source {
        case Data(NSData)
        case FilePath(String)
    }
    let source: Source

    let fileExtension: FileExtension

    let metaDataString: String?
}

func tryUploadAttachment(uploadAttachment: UploadAttachment, failureHandler: FailureHandler?, completion: String -> Void) {

    guard let token = YepUserDefaults.v1AccessToken.value else {
        println("uploadAttachment no token")
        return
    }

    let headers: [String: String] = [
        "Authorization": "Token token=\"\(token)\"",
    ]

    var parameters: [String: String] = [
        "attachable_type": uploadAttachment.type.rawValue,
    ]

    if let metaDataString = uploadAttachment.metaDataString {
        parameters["metadata"] = metaDataString
    }

    let name = "file"
    let filename = "file.\(uploadAttachment.fileExtension.rawValue)"
    let mimeType = uploadAttachment.fileExtension.mimeType

    Alamofire.upload(.POST, BaseURL.absoluteString + "/v1/attachments", headers: headers, multipartFormData: { multipartFormData in

        for parameter in parameters {
            multipartFormData.appendBodyPart(data: parameter.1.dataUsingEncoding(NSUTF8StringEncoding)!, name: parameter.0)
        }

        switch uploadAttachment.source {

        case .Data(let data):
            multipartFormData.appendBodyPart(data: data, name: name, fileName: filename, mimeType: mimeType)

        case .FilePath(let filePath):
            multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: filePath), name: name, fileName: filename, mimeType: mimeType)
        }

    }, encodingCompletion: { encodingResult in
        //println("encodingResult: \(encodingResult)")

        switch encodingResult {

        case .Success(let upload, _, _):

            upload.responseJSON(completionHandler: { response in

                guard let
                    data = response.data,
                    json = decodeJSON(data)
                else {
                    failureHandler?(reason: .CouldNotParseJSON, errorMessage: nil)
                    return
                }

                println("tryUploadAttachment json: \(json)")

                guard let
                    uploadAttachmentID = json["id"] as? String
                else {
                    failureHandler?(reason: .CouldNotParseJSON, errorMessage: nil)
                    return
                }

                completion(uploadAttachmentID)
            })
            
        case .Failure(let encodingError):
            
            failureHandler?(reason: .Other(nil), errorMessage: "\(encodingError)")
        }
    })
}


func deleteMessageFromServer(messageID messageID: String, failureHandler: FailureHandler?, completion: () -> Void) {

    let parse: JSONDictionary -> Void? = { data in
        return
    }

    let resource = authJsonResource(path: "/v1/messages/\(messageID)", method: .DELETE, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func refreshAttachmentWithID(attachmentID: String, failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {

    let requestParameters = [
        "ids": [attachmentID],
    ]

    let parse: JSONDictionary -> JSONDictionary? = { data in
        return (data["attachments"] as? [JSONDictionary])?.first
    }

    let resource = authJsonResource(path: "/v1/attachments/refresh_url", method: .PATCH, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

enum DiscoveredUserSortStyle: String {
    case Distance = "distance"
    case LastSignIn = "last_sign_in_at"
    case Default = "default"
    
    var name: String {
        switch self {
        case .Distance:
            return NSLocalizedString("Nearby", comment: "")
        case .LastSignIn:
            return NSLocalizedString("Time", comment: "")
        case .Default:
            return NSLocalizedString("Match", comment: "")
        }
    }
    
    var nameWithArrow: String {
        return name + " ▾"
    }
}

struct DiscoveredUser: Hashable {
    
    struct SocialAccountProvider {
        let name: String
        let enabled: Bool
    }
    
    let id: String
    let username: String
    let introduction: String?
    let avatarURLString: String
    let badge: String?
    
    let createdUnixTime: NSTimeInterval
    let lastSignInUnixTime: NSTimeInterval
    
    let socialAccountProviders: [SocialAccountProvider]
    
    let recently_updated_provider: String?
    
    var hashValue: Int {
        return id.hashValue
    }
    
    var isMe: Bool {
        if let myUserID = YepUserDefaults.userID.value {
            return id == myUserID
        }
        
        return false
    }
    
    static func fromUser(user: User) -> DiscoveredUser {
        
        return DiscoveredUser(id: user.userID, username: user.username, introduction: user.introduction, avatarURLString: user.avatarURLString, badge: user.badge, createdUnixTime: user.createdUnixTime, lastSignInUnixTime: user.lastSignInUnixTime, socialAccountProviders: [], recently_updated_provider: nil)
    }
}

func ==(lhs: DiscoveredUser, rhs: DiscoveredUser) -> Bool {
    return lhs.id == rhs.id
}

let parseDiscoveredUser: JSONDictionary -> DiscoveredUser? = { userInfo in
    if let
        id = userInfo["id"] as? String,
        username = userInfo["username"] as? String,
        avatarInfo = userInfo["avatar"] as? JSONDictionary,
        avatarURLString = avatarInfo["url"] as? String,
        createdUnixTime = userInfo["created_at"] as? NSTimeInterval,
        lastSignInUnixTime = userInfo["last_sign_in_at"] as? NSTimeInterval
        {
        
        let introduction = userInfo["introduction"] as? String
        let badge = userInfo["badge"] as? String
        
        
        var socialAccountProviders = Array<DiscoveredUser.SocialAccountProvider>()
        if let socialAccountProvidersInfo = userInfo["providers"] as? [String: Bool] {
            for (name, enabled) in socialAccountProvidersInfo {
                let provider = DiscoveredUser.SocialAccountProvider(name: name, enabled: enabled)
                
                socialAccountProviders.append(provider)
            }
        }
        
        var recently_updated_provider: String?
        
        if let updated_provider = userInfo["recently_updated_provider"] as? String{
            recently_updated_provider = updated_provider
        }
        
        let discoverUser = DiscoveredUser(id: id, username: username,introduction: introduction, avatarURLString: avatarURLString, badge: badge, createdUnixTime: createdUnixTime, lastSignInUnixTime: lastSignInUnixTime, socialAccountProviders: socialAccountProviders, recently_updated_provider: recently_updated_provider)
        
        return discoverUser
    }
    
    return nil
}


// MARK: - Feeds

enum FeedSortStyle: String {

    case Time = "time"
    case Match = "default"
    
    var name: String {
        switch self {
        case .Time:
            return NSLocalizedString("Time", comment: "")
        case .Match:
            return NSLocalizedString("Match", comment: "")
        }
    }
    
    var nameWithArrow: String {
        return name + " ▾"
    }
}

struct DiscoveredAttachment {

    //let kind: AttachmentKind
    let metadata: String
    let URLString: String

    var image: UIImage?

    var isTemporary: Bool {
        return image != nil
    }

    var thumbnailImage: UIImage? {

        guard (metadata as NSString).length > 0 else {
            return nil
        }

        if let data = metadata.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            if let metaDataInfo = decodeJSON(data) {
                if let thumbnailString = metaDataInfo[YepConfig.MetaData.thumbnailString] as? String {
                    if let imageData = NSData(base64EncodedString: thumbnailString, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                        let image = UIImage(data: imageData)
                        return image
                    }
                }
            }
        }

        return nil
    }

    static func fromJSONDictionary(json: JSONDictionary) -> DiscoveredAttachment? {
        guard let
            //kindString = json["kind"] as? String,
            //kind = AttachmentKind(rawValue: kindString),
            metadata = json["metadata"] as? String,
            fileInfo = json["file"] as? JSONDictionary,
            URLString = fileInfo["url"] as? String else {
                return nil
        }

        //return DiscoveredAttachment(kind: kind, metadata: metadata, URLString: URLString)
        return DiscoveredAttachment(metadata: metadata, URLString: URLString, image: nil)
    }
}

func ==(lhs: DiscoveredFeed, rhs: DiscoveredFeed) -> Bool {
    return lhs.id == rhs.id
}

struct DiscoveredFeed: Hashable {
    
    var hashValue: Int {
        return id.hashValue
    }

    let id: String
    let allowComment: Bool
    let kind: FeedKind

    var hasSocialImage: Bool {
        switch kind {
        case .DribbbleShot:
            return true
        default:
            return false
        }
    }

    var hasMapImage: Bool {

        switch kind {
        case .Location:
            return true
        default:
            return false
        }
    }

    let createdUnixTime: NSTimeInterval
    let updatedUnixTime: NSTimeInterval

    let creator: DiscoveredUser
    let body: String

    struct GithubRepo {
        let ID: Int
        let name: String
        let fullName: String
        let description: String
        let URLString: String
        let createdUnixTime: NSTimeInterval

        static func fromJSONDictionary(json: JSONDictionary) -> GithubRepo? {
            guard let
                ID = json["repo_id"] as? Int,
                name = json["name"] as? String,
                fullName = json["full_name"] as? String,
                description = json["description"] as? String,
                URLString = json["url"] as? String,
                createdUnixTime = json["created_at"] as? NSTimeInterval else {
                    return nil
            }

            return GithubRepo(ID: ID, name: name, fullName: fullName, description: description, URLString: URLString, createdUnixTime: createdUnixTime)
        }
    }

    struct DribbbleShot {
        let ID: Int
        let title: String
        let description: String?
        let imageURLString: String
        let htmlURLString: String
        let createdUnixTime: NSTimeInterval

        static func fromJSONDictionary(json: JSONDictionary) -> DribbbleShot? {
            guard let
                ID = json["shot_id"] as? Int,
                title = json["title"] as? String,
                imageURLString = json["media_url"] as? String,
                htmlURLString = json["url"] as? String,
                createdUnixTime = json["created_at"] as? NSTimeInterval else {
                    return nil
            }
            
            let description = json["description"] as? String

            return DribbbleShot(ID: ID, title: title, description: description, imageURLString: imageURLString, htmlURLString: htmlURLString, createdUnixTime: createdUnixTime)
        }
    }

    struct AudioInfo {
        let feedID: String
        let URLString: String
        let metaData: NSData
        let duration: NSTimeInterval
        let sampleValues: [CGFloat]

        static func fromJSONDictionary(json: JSONDictionary, feedID: String) -> AudioInfo? {
            guard let
                fileInfo = json["file"] as? JSONDictionary,
                URLString = fileInfo["url"] as? String,
                metaDataString = json["metadata"] else {
                    return nil
            }

            if let metaData = metaDataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                if let metaDataInfo = decodeJSON(metaData) {

                    guard let
                        duration = metaDataInfo[YepConfig.MetaData.audioDuration] as? NSTimeInterval,
                        sampleValues = metaDataInfo[YepConfig.MetaData.audioSamples] as? [CGFloat] else {
                            return nil
                    }

                    return AudioInfo(feedID: feedID, URLString: URLString, metaData: metaData, duration: duration, sampleValues: sampleValues)
                }
            }

            return nil
        }
    }

    struct LocationInfo {

        let name: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees

        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        static func fromJSONDictionary(json: JSONDictionary) -> LocationInfo? {
            guard let
                name = json["place"] as? String,
                latitude = json["latitude"] as? CLLocationDegrees,
                longitude = json["longitude"] as? CLLocationDegrees else {
                    return nil
            }

            return LocationInfo(name: name, latitude: latitude, longitude: longitude)
        }
    }

    struct OpenGraphInfo: OpenGraphInfoType {

        let URL: NSURL

        let siteName: String
        let title: String
        let infoDescription: String
        let thumbnailImageURLString: String

        static func fromJSONDictionary(json: JSONDictionary) -> OpenGraphInfo? {
            guard let
                URLString = json["url"] as? String,
                URL = NSURL(string: URLString),
                siteName = json["site_name"] as? String,
                title = json["title"] as? String,
                infoDescription = json["description"] as? String,
                thumbnailImageURLString = json["image_url"] as? String else {
                    return nil
            }

            return OpenGraphInfo(URL: URL, siteName: siteName, title: title, infoDescription: infoDescription, thumbnailImageURLString: thumbnailImageURLString)
        }
    }

    enum Attachment {
        case Images([DiscoveredAttachment])
        case Github(GithubRepo)
        case Dribbble(DribbbleShot)
        case Audio(AudioInfo)
        case Location(LocationInfo)
        case URL(OpenGraphInfo)
    }

    let attachment: Attachment?

    var imageAttachments: [DiscoveredAttachment]? {
        if let attachment = attachment, case let .Images(attachments) = attachment {
            return attachments
        }

        return nil
    }

    var imageAttachmentsCount: Int {
        return imageAttachments?.count ?? 0
    }


    let groupID: String
    var messagesCount: Int

    var uploadingErrorMessage: String? = nil

    var timeString: String {
        let timeString = "\(NSDate(timeIntervalSince1970: createdUnixTime).timeAgo)"
        return timeString
    }

   
    static func fromFeedInfo(feedInfo: JSONDictionary, groupInfo: JSONDictionary?) -> DiscoveredFeed? {

        //println("feedInfo: \(feedInfo)")

        guard let
            id = feedInfo["id"] as? String,
            allowComment = feedInfo["allow_comment"] as? Bool,
            kindString = feedInfo["kind"] as? String,
            kind = FeedKind(rawValue: kindString),
            createdUnixTime = feedInfo["created_at"] as? NSTimeInterval,
            updatedUnixTime = feedInfo["updated_at"] as? NSTimeInterval,
            creatorInfo = feedInfo["user"] as? JSONDictionary,
            body = feedInfo["body"] as? String,
            messagesCount = feedInfo["message_count"] as? Int else {
                return nil
        }

        var groupInfo = groupInfo

        if groupInfo == nil {
            groupInfo = feedInfo["circle"] as? JSONDictionary
        }

        guard let creator = parseDiscoveredUser(creatorInfo), groupID = groupInfo?["id"] as? String else {
            return nil
        }

        
        var attachment: DiscoveredFeed.Attachment?

        switch kind {

        case .URL:
            if let
                openGraphInfosData = feedInfo["attachments"] as? [JSONDictionary],
                openGraphInfoDict = openGraphInfosData.first,
                openGraphInfo = DiscoveredFeed.OpenGraphInfo.fromJSONDictionary(openGraphInfoDict) {
                    attachment = .URL(openGraphInfo)
            }

        case .Image:

            let attachmentsData = feedInfo["attachments"] as? [JSONDictionary]
            let attachments = attachmentsData?.map({ DiscoveredAttachment.fromJSONDictionary($0) }).flatMap({ $0 }) ?? []

            attachment = .Images(attachments)

        case .GithubRepo:

            if let
                githubReposData = feedInfo["attachments"] as? [JSONDictionary],
                githubRepoInfo = githubReposData.first,
                githubRepo = DiscoveredFeed.GithubRepo.fromJSONDictionary(githubRepoInfo) {
                    attachment = .Github(githubRepo)
            }

        case .DribbbleShot:

            if let
                dribbbleShotsData = feedInfo["attachments"] as? [JSONDictionary],
                dribbbleShotInfo = dribbbleShotsData.first,
                dribbbleShot = DiscoveredFeed.DribbbleShot.fromJSONDictionary(dribbbleShotInfo) {
                    attachment = .Dribbble(dribbbleShot)
            }

        case .Audio:

            if let
                audioInfosData = feedInfo["attachments"] as? [JSONDictionary],
                _audioInfo = audioInfosData.first,
                audioInfo = DiscoveredFeed.AudioInfo.fromJSONDictionary(_audioInfo, feedID: id) {
                    attachment = .Audio(audioInfo)
            }

        case .Location:

            if let
                locationInfosData = feedInfo["attachments"] as? [JSONDictionary],
                _locationInfo = locationInfosData.first,
                locationInfo = DiscoveredFeed.LocationInfo.fromJSONDictionary(_locationInfo) {
                    attachment = .Location(locationInfo)
            }

        default:
            break
        }

       
        return DiscoveredFeed(id: id, allowComment: allowComment, kind: kind, createdUnixTime: createdUnixTime, updatedUnixTime: updatedUnixTime, creator: creator, body: body, attachment: attachment, groupID: groupID, messagesCount: messagesCount, uploadingErrorMessage: nil)
    }
}

let parseFeed: JSONDictionary -> DiscoveredFeed? = { data in
    
    //println("feedsData: \(data)")
    
    if let feedInfo = data["topic"] as? JSONDictionary, groupInfo = data["circle"] as? JSONDictionary {
        return DiscoveredFeed.fromFeedInfo(feedInfo, groupInfo: groupInfo)
    }
    
    return nil
}

let parseFeeds: JSONDictionary -> [DiscoveredFeed]? = { data in

    //println("feedsData: \(data)")

    if let feedsData = data["topics"] as? [JSONDictionary] {
        return feedsData.map({ DiscoveredFeed.fromFeedInfo($0, groupInfo: nil) }).flatMap({ $0 })
    }

    return []
}

func discoverFeedsWithSortStyle(sortStyle: FeedSortStyle, pageIndex: Int, perPage: Int, maxFeedID: String?, failureHandler: ((Reason, String?) -> Void)?, completion: [DiscoveredFeed] -> Void) {

    var requestParameters: JSONDictionary = [
        "sort": sortStyle.rawValue,
        "page": pageIndex,
        "per_page": perPage,
    ]

   
    if let maxFeedID = maxFeedID {
        requestParameters["max_id"] = maxFeedID
    }

    let parse: JSONDictionary -> [DiscoveredFeed]? = { data in

        // 只离线第一页，且无 skill
        if pageIndex == 1 {
            if let realm = try? Realm() {
                if let offlineData = try? NSJSONSerialization.dataWithJSONObject(data, options: []) {

                    let offlineJSON = OfflineJSON(name: OfflineJSONName.Feeds.rawValue, data: offlineData)

                    let _ = try? realm.write {
                        realm.add(offlineJSON, update: true)
                    }
                }
            }
        }

        return parseFeeds(data)
    }

    let resource = authJsonResource(path: "/v1/topics/discover", method: .GET, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func feedWithSharedToken(token: String, failureHandler: FailureHandler?, completion: DiscoveredFeed -> Void) {

    let requestParameters: JSONDictionary = [
        "token": token,
    ]

    let parse = parseFeed
    
    let resource = authJsonResource(path: "/v1/circles/shared_messages", method: .GET, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func myFeedsAtPageIndex(pageIndex: Int, perPage: Int, failureHandler: FailureHandler?, completion: [DiscoveredFeed] -> Void) {

    let requestParameters: JSONDictionary = [
        "page": pageIndex,
        "per_page": perPage,
    ]

    let parse = parseFeeds

    let resource = authJsonResource(path: "/v1/topics", method: .GET, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func feedsOfUser(userID: String, pageIndex: Int, perPage: Int, failureHandler: FailureHandler?,completion: [DiscoveredFeed] -> Void) {

    let requestParameters: JSONDictionary = [
        "page": pageIndex,
        "per_page": perPage,
    ]

    let parse = parseFeeds

    let resource = authJsonResource(path: "/v1/users/\(userID)/topics", method: .GET, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

enum FeedKind: String {
    case Text = "text"
    case URL = "web_page"
    case Image = "image"
    case Video = "video"
    case Audio = "audio"
    case Location = "location"

    case AppleMusic = "apple_music"
    case AppleMovie = "apple_movie"
    case AppleEBook = "apple_ebook"

    case GithubRepo = "github"
    case DribbbleShot = "dribbble"
    //case InstagramMedia = "instagram"

    var accountName: String? {
        switch self {
        case .GithubRepo: return "github"
        case .DribbbleShot: return "dribbble"
        //case .InstagramMedia: return "instagram"
        default: return nil
        }
    }

    var needBackgroundUpload: Bool {
        switch self {
        case .Image:
            return true
        case .Audio:
            return true
        default:
            return false
        }
    }

    var needParseOpenGraph: Bool {
        switch self {
        case .Text:
            return true
        default:
            return false
        }
    }
}

func createFeedWithKind(kind: FeedKind, message: String, attachments: [JSONDictionary]?, coordinate: CLLocationCoordinate2D?, allowComment: Bool, failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {

    var requestParameters: JSONDictionary = [
        "kind": kind.rawValue,
        "body": message,
        "latitude": 0,
        "longitude": 0,
        "allow_comment": allowComment,
    ]

    if let coordinate = coordinate {
        requestParameters["latitude"] = coordinate.latitude
        requestParameters["longitude"] = coordinate.longitude
    }

    if let attachments = attachments {
        requestParameters["attachments"] = attachments
    }

    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }

    let resource = authJsonResource(path: "/v1/topics", method: .POST, requestParameters: requestParameters, parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func deleteFeedWithFeedID(feedID: String, failureHandler: FailureHandler?, completion: () -> Void) {

    let parse: JSONDictionary -> ()? = { data in
        return
    }

    let resource = authJsonResource(path: "/v1/topics/\(feedID)", method: .DELETE, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - Social Work

struct TokensOfSocialAccounts {
    let githubToken: String?
    let dribbbleToken: String?
    let instagramToken: String?
}

func tokensOfSocialAccounts(failureHandler failureHandler: ((Reason, String?) -> Void)?, completion: TokensOfSocialAccounts -> Void) {

    let parse: JSONDictionary -> TokensOfSocialAccounts? = { data in

        //println("tokensOfSocialAccounts data: \(data)")

        let githubToken = data["github"] as? String
        let dribbbleToken = data["dribbble"] as? String
        let instagramToken = data["instagram"] as? String

        return TokensOfSocialAccounts(githubToken: githubToken, dribbbleToken: dribbbleToken, instagramToken: instagramToken)
    }

    let resource = authJsonResource(path: "/v1/user/provider_tokens", method: .GET, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

func authURLRequestWithURL(url: NSURL) -> NSURLRequest {
    
    let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 0)
    
    if let token = YepUserDefaults.v1AccessToken.value {
        request.setValue("Token token=\"\(token)\"", forHTTPHeaderField: "Authorization")
    }

    return request
}

func socialAccountWithProvider(provider: String, failureHandler: FailureHandler?, completion: JSONDictionary -> Void) {
    
    let parse: JSONDictionary -> JSONDictionary? = { data in
        return data
    }
    
    let resource = authJsonResource(path: "/v1/user/\(provider)", method: .GET, requestParameters: [:], parse: parse)
    
    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}

struct InstagramWork {

    struct Media {

        let ID: String
        let linkURLString: String

        struct Images {
            let lowResolution: String
            let standardResolution: String
            let thumbnail: String
        }
        let images: Images

        let likesCount: Int
        let commentsCount: Int

        let username: String
    }

    let medias: [Media]
}

func instagramWorkOfUserWithUserID(userID: String, failureHandler: FailureHandler?, completion: InstagramWork -> Void) {

    let parse: JSONDictionary -> InstagramWork? = { data in
        //println("instagramData:\(data)")

        if let mediaData = data["media"] as? [JSONDictionary] {

            var medias = Array<InstagramWork.Media>()

            for mediaInfo in mediaData {
                if let
                    ID = mediaInfo["id"] as? String,
                    linkURLString = mediaInfo["link"] as? String,
                    imagesInfo = mediaInfo["images"] as? JSONDictionary,
                    likesInfo = mediaInfo["likes"] as? JSONDictionary,
                    commentsInfo = mediaInfo["comments"] as? JSONDictionary,
                    userInfo = mediaInfo["user"] as? JSONDictionary {
                        if let
                            lowResolutionInfo = imagesInfo["low_resolution"] as? JSONDictionary,
                            standardResolutionInfo = imagesInfo["standard_resolution"] as? JSONDictionary,
                            thumbnailInfo = imagesInfo["thumbnail"] as? JSONDictionary,

                            lowResolution = lowResolutionInfo["url"] as? String,
                            standardResolution = standardResolutionInfo["url"] as? String,
                            thumbnail = thumbnailInfo["url"] as? String,

                            likesCount = likesInfo["count"] as? Int,
                            commentsCount = commentsInfo["count"] as? Int,

                            username = userInfo["username"] as? String {

                                let images = InstagramWork.Media.Images(lowResolution: lowResolution, standardResolution: standardResolution, thumbnail: thumbnail)

                                let media = InstagramWork.Media(ID: ID, linkURLString: linkURLString, images: images, likesCount: likesCount, commentsCount: commentsCount, username: username)

                                medias.append(media)
                        }
                }
            }

            return InstagramWork(medias: medias)
        }

        return nil
    }

    let resource = authJsonResource(path: "/v1/users/\(userID)/instagram", method: .GET, requestParameters: [:], parse: parse)

    apiRequest({_ in}, baseURL: BaseURL, resource: resource, failure: failureHandler, completion: completion)
}