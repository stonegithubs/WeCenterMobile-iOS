//
//  User.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var answerCount: NSNumber?
    @NSManaged var answerFavoriteCount: NSNumber?
    @NSManaged var avatarData: NSData?
    @NSManaged var avatarURI: String?
    @NSManaged var birthday: NSNumber?
    @NSManaged var followerCount: NSNumber?
    @NSManaged var followingCount: NSNumber?
    @NSManaged var genderValue: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var jobID: NSNumber?
    @NSManaged var markCount: NSNumber?
    @NSManaged var name: String?
    @NSManaged var questionCount: NSNumber?
    @NSManaged var signature: String?
    @NSManaged var thankCount: NSNumber?
    @NSManaged var topicFocusCount: NSNumber?
    @NSManaged var actions: NSSet
    @NSManaged var answers: NSSet
    @NSManaged var articles: NSSet
    @NSManaged var answerComments: NSSet
    @NSManaged var answerCommentsMentioned: NSSet
    @NSManaged var followers: NSSet
    @NSManaged var followings: NSSet
    @NSManaged var questions: NSSet
    @NSManaged var topics: NSSet
    @NSManaged var articleComments: NSSet
    @NSManaged var articleCommentsMentioned: NSSet
    
    enum Gender: Int {
        case Male = 1
        case Female = 2
        case Secret = 3
    }
    
    var gender: Gender? {
        get {
            return (genderValue == nil) ? nil : Gender(rawValue: genderValue!.integerValue)
        }
        set {
            genderValue = newValue?.rawValue
        }
    }
    
    var avatar: UIImage? {
        get {
            if avatarData != nil {
                return UIImage(data: avatarData!)
            } else {
                return nil
            }
        }
        set {
            avatarData = UIImagePNGRepresentation(newValue)
        }
    }
    
    var followed: Bool? = nil
    
    var avatarURL: String? {
        return (avatarURI == nil) ? nil : networkManager.website + networkManager.paths["User Avatar"]! + avatarURI!
    }
    
    class func get(#ID: NSNumber, error: NSErrorPointer) -> User? {
        return dataManager.fetch("User", ID: ID, error: error) as? User
    }
    
    class func fetch(#ID: NSNumber, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Extra Information",
            parameters: [
                "uid": ID
            ],
            success: {
                data in
                let user = dataManager.autoGenerate("User", ID: ID) as User
                user.id = ID
                user.name = data["user_name"] as? String
                user.avatarURI = data["avatar_file"] as? String
                user.followerCount = (data["fans_count"] as NSString).integerValue
                user.followingCount = (data["friend_count"] as NSString).integerValue
                user.questionCount = (data["question_count"] as NSString).integerValue
                user.answerCount = (data["answer_count"] as NSString).integerValue
                user.topicFocusCount = (data["topic_focus_count"] as NSString).integerValue
                user.agreementCount = (data["agree_count"] as NSString).integerValue
                user.thankCount = (data["thanks_count"] as NSString).integerValue
                user.answerFavoriteCount = (data["answer_favorite_count"] as NSString).integerValue
                user.followed = (data["has_focus"] as NSNumber == 1)
                success?(user)
            }, failure: failure)
    }
    
    func fetchFollowings(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Following List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if (data["total_rows"] as NSString).integerValue > 0 {
                    var array = self.followings.allObjects as [User]
                    for value in data["rows"] as [NSDictionary] {
                        let userID = (value["uid"] as NSString).integerValue
                        var user: User! = array.filter({ $0.id == userID }).first
                        if user == nil {
                            user = dataManager.autoGenerate("User", ID: (value["uid"] as NSString).integerValue) as User
                            array.append(user)
                        }
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                    }
                    self.followings = NSSet(array: array)
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchFollowers(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Follower List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if (data["total_rows"] as NSString).integerValue > 0 {
                    var array = self.followers.allObjects as [User]
                    for value in data["rows"] as [NSDictionary] {
                        let userID = (value["uid"] as NSString).integerValue
                        var user: User! = array.filter({ $0.id == userID }).first
                        if user == nil {
                            user = dataManager.autoGenerate("User", ID: (value["uid"] as NSString).integerValue) as User
                            array.append(user)
                        }
                        user.name = value["user_name"] as? String
                        user.avatarURI = value["avatar_file"] as? String
                        user.signature = value["signature"] as? String
                    }
                    self.followers = NSSet(array: array)
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }
    
    func fetchTopics(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Topic List",
            parameters: [
                "uid": id,
                "page": page,
                "per_page": count
            ],
            success: {
                data in
                if (((data["total_rows"] as? NSString)?.integerValue) ?? (data["total_rows"] as? NSNumber)?.integerValue ?? 0) > 0 {
                    var array = self.topics.allObjects as [Topic]
                    for value in data["rows"] as [NSDictionary] {
                        let topicID = (value["topic_id"] as NSString).integerValue
                        var topic: Topic! = array.filter({ $0.id == topicID }).first
                        if topic == nil {
                            topic = dataManager.autoGenerate("Topic", ID: topicID) as Topic
                            array.append(topic)
                        }
                        topic.title = value["topic_title"] as? String
                        topic.introduction = value["topic_description"] as? String
                        topic.imageURI = value["topic_pic"] as? String
                        array.append(topic)
                    }
                    self.topics = NSSet(array: array)
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
                return
            },
            failure: failure)
    }
    
    func fetchQuestions(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Question List",
            parameters: [
                "uid": id
            ],
            success: {
                data in
                if (data["total_rows"] as NSString).integerValue > 0 {
                    var questionsData = [NSDictionary]()
                    if data["rows"] is NSDictionary {
                        questionsData = [data["rows"] as NSDictionary]
                    } else {
                        questionsData = data["rows"] as [NSDictionary]
                    }
                    var array = self.questions.allObjects as [Question]
                    for questionData in questionsData {
                        let questionID = (questionData["id"] as NSString).integerValue
                        var question: Question! = array.filter({ $0.id == questionID }).first
                        if question == nil {
                            question = dataManager.autoGenerate("Question", ID: questionID) as Question
                            array.append(question)
                        }
                        question.user = self
                        question.title = questionData["title"] as? String
                        question.body = questionData["detail"] as? String
                    }
                    self.questions = NSSet(array: array)
                }
                success?()
            },
            failure: failure)
    }
    
    class func loginWithCookieAndCacheInStorage(#success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        let data = NSUserDefaults.standardUserDefaults().objectForKey("Cookies") as? NSData
        if data == nil {
            var userInfo = [
                NSLocalizedDescriptionKey: "Could not find any cookies in storage.",
                NSLocalizedFailureReasonErrorKey: "You've never logged in before or cookies have been cleared.",
            ]
            failure?(NSError(
                domain: networkManager.website,
                code: networkManager.internalErrorCode.integerValue,
                userInfo: userInfo)) // Needs specification
        } else {
            let cookies = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as [NSHTTPCookie]
            let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookies {
                storage.setCookie(cookie)
            }
            networkManager.GET("User UID",
                parameters: nil,
                success: {
                    data in
                    var error: NSError? = nil
                    let user = self.get(ID: data["uid"] as NSNumber, error: &error)
                    if user != nil {
                        success?(user!)
                    } else {
                        failure?(error ?? NSError()) // Needs specification
                    }
                },
                failure: failure)
        }
    }
    
    class func loginWithName(name: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.clearCookies()
        networkManager.POST("User Login",
            parameters: [
                "user_name": name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                "password": password.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            ],
            success: {
                data in
                let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]
                let cookiesData = NSKeyedArchiver.archivedDataWithRootObject(cookies)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(cookiesData, forKey: "Cookies")
                defaults.synchronize()
                let user = dataManager.autoGenerate("User", ID: data["uid"] as NSNumber) as User
                user.name = data["user_name"] as? String
                user.avatarURI = data["avatar_file"] as? String
                appDelegate.saveContext()
                self.loginWithCookieAndCacheInStorage(success: success, failure: failure)
            },
            failure: failure)
    }
    
    // Needs to be modified
    func fetchProfile(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("User Basic Information",
            parameters: [
                "uid": id
            ],
            success: {
                data in
                let value = data[0] as NSDictionary
                self.name = value["user_name"] as? String
                self.genderValue = value["sex"] is NSNull ? Gender.Secret.rawValue : (value["sex"] as NSString).integerValue
                self.birthday = (value["birthday"] as? NSString)?.integerValue
                self.jobID = (value["job_id"] as NSString).integerValue
                self.signature = value["signature"] as? String
                success?()
            },
            failure: failure)
    }
    
    func toggleFollow(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("Follow User",
            parameters: [
                "uid": id
            ],
            success: {
                data in
                self.followed = (data["type"] as String == "add")
                success?()
            },
            failure: failure)
    }
    
    private let imageView = UIImageView()
    
    func fetchAvatar(#success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if avatarURL != nil {
            imageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: avatarURL!)!),
                placeholderImage: nil,
                success: {
                    request, response, image in
                    self.avatar = image
                    success?()
                    return
                },
                failure: {
                    request, response, error in
                    failure?(error)
                    return
            })
        } else {
            failure?(NSError()) // Needs specification
        }
    }
    
    private enum ActionTypeID: Int {
        case QuestionPublishment = 101
        case QuestionFocusing = 105
        case Answer = 201
        case AnswerAgreement = 204
        case ArticlePublishment = 501
        case ArticleAgreement = 502
    }
    
    func fetchRelatedActions(#page: Int, count: Int, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        networkManager.GET("Home List",
            parameters: [
                "page": page - 1,
                "per_page": count
            ],
            success: {
                data in
                let rows = data["total_rows"] as Int
                if rows > 0 {
                    let objects = data["rows"] as [[String: AnyObject]]
                    for object in objects {
                        let typeID = ActionTypeID(rawValue: (object["associate_action"] as NSNumber).integerValue)!
                        var action_: Action!
                        switch typeID {
                        case .AnswerAgreement:
                            let action = dataManager.autoGenerate("AnswerAgreementAction", ID: object["history_id"] as NSNumber) as AnswerAgreementAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = (dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User)
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["user_name"] as String)
                            let answerInfo = object["answer_info"] as NSDictionary
                            action.answer = dataManager.autoGenerate("Answer", ID: answerInfo["answer_id"] as NSNumber) as Answer
                            action.answer.question = (dataManager.autoGenerate("Question", ID: answerInfo["question_id"] as NSNumber) as Question)
                            action.answer.body = (answerInfo["answer_content"] as String)
                            action.answer.agreementCount = (answerInfo["agree_count"] as NSNumber)
                            action.answer.evaluation = Answer.Evaluation(rawValue: Msr.Data.IntegerValueOfObject(answerInfo["agree_status"]!))!
                            let questionInfo = object["question_info"] as NSDictionary
                            action.answer.question = (dataManager.autoGenerate("Question", ID: questionInfo["question_id"] as NSNumber) as Question)
                            action.answer.question!.title = (questionInfo["question_content"] as String)
                            break
                        case .QuestionFocusing:
                            let action = dataManager.autoGenerate("QuestionFocusingAction", ID: object["history_id"] as NSNumber) as QuestionFocusingAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["avatar_file"] as String)
                            let questionInfo = object["question_info"] as NSDictionary
                            action.question = dataManager.autoGenerate("Question", ID: questionInfo["question_id"] as NSNumber) as Question
                            action.question.title = (questionInfo["question_content"] as String)
                            break
                        case .QuestionPublishment:
                            let action = dataManager.autoGenerate("QuestionPublishmentAction", ID: object["history_id"] as NSNumber) as QuestionPublishmentAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["avatar_file"] as String)
                            let questionInfo = object["question_info"] as NSDictionary
                            action.question = dataManager.autoGenerate("Question", ID: questionInfo["question_id"] as NSNumber) as Question
                            action.question.title = (questionInfo["question_content"] as String)
                            action.question.user = action.user
                            break
                        case .ArticleAgreement:
                            let action = dataManager.autoGenerate("ArticleAgreementAction", ID: object["history_id"] as NSNumber) as ArticleAgreementAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["avatar_file"] as String)
                            let articleInfo = object["article_info"] as NSDictionary
                            action.article = dataManager.autoGenerate("Article", ID: articleInfo["id"] as NSNumber) as Article
                            action.article.title = (articleInfo["title"] as String)
                            break
                        case .Answer:
                            let action = dataManager.autoGenerate("AnswerAction", ID: object["history_id"] as NSNumber) as AnswerAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["avatar_file"] as String)
                            let answerInfo = object["answer_info"] as NSDictionary
                            action.answer = dataManager.autoGenerate("Answer", ID: answerInfo["answer_id"] as NSNumber) as Answer
                            action.answer.body = (answerInfo["answer_content"] as String)
                            action.answer.agreementCount = (answerInfo["agree_count"] as NSNumber)
                            action.answer.evaluation = Answer.Evaluation(rawValue: Msr.Data.IntegerValueOfObject(answerInfo["agree_status"]!))!
                            let questionInfo = object["question_info"] as NSDictionary
                            action.answer.question = (dataManager.autoGenerate("Question", ID: questionInfo["question_id"] as NSNumber) as Question)
                            action.answer.question!.title = (questionInfo["question_content"] as String)
                            action.answer.user = action.user
                            break
                        case .ArticlePublishment:
                            let action = dataManager.autoGenerate("ArticlePublishmentAction", ID: object["history_id"] as NSNumber) as ArticlePublishmentAction
                            action_ = action
                            action.date = NSDate(timeIntervalSince1970: (object["add_time"] as NSNumber).doubleValue)
                            let userInfo = object["user_info"] as NSDictionary
                            action.user = dataManager.autoGenerate("User", ID: userInfo["uid"] as NSNumber) as User
                            action.user.name = (userInfo["user_name"] as String)
                            action.user.avatarURI = (userInfo["avatar_file"] as String)
                            let articleInfo = object["article_info"] as NSDictionary
                            action.article = dataManager.autoGenerate("Article", ID: articleInfo["id"] as NSNumber) as Article
                            action.article.title = (articleInfo["title"] as String)
                            action.article.user = action.user
                            break
                        default:
                            break
                        }
                    }
                    success?()
                } else {
                    failure?(NSError()) // Needs specification
                }
            },
            failure: failure)
    }

}
