//
//  UserModel.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/13.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    @objc var profileImageUrl: String?
    @objc var userName: String?
    @objc var uid: String?
    @objc var conditionComment: String?
    @objc var pushToken: String?
}
