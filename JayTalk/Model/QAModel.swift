//
//  QAModel.swift
//  JayTalk
//
//  Created by Jkookoo on 2021/04/08.
//  Copyright © 2021 Jkookoo. All rights reserved.
//

import UIKit
import ObjectMapper

class QAModel: Mappable {
    var question: String?
    var answer: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        question <- map["question"]
        answer <- map["answer"]
    }
}
