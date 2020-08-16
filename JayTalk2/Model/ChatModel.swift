//
//  ChatModel.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/15.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import ObjectMapper

class ChatModel: Mappable {
    var users: [String:Bool] = [:]// 채팅방에 참여한 사람들
    var comments: [String:Comment] = [:] // 채팅방의 대화들
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    class Comment: Mappable {
        var uid: String?
        var message: String?
        var timeStamp: Int?
        var readUsers:[String:Bool] = [:]
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timeStamp <- map["timeStamp"]
            readUsers <- map["readUsers"]
        }
    }
}
