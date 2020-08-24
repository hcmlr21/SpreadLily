//
//  BikeDataModel.swift
//  ElectronicCarSpot
//
//  Created by Jkookoo on 2020/08/24.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

struct BikeDataModel: Codable {
    var rentBikeStatus: RentBikeStatus?
    
    struct RentBikeStatus: Codable {
        var listTotalCount: Int?
        var result: Result?
        var rows: [Row]?
        
        struct Result: Codable {
            var code: String?
            var message: String?
            
            enum CodingKeys: String, CodingKey {
                case code = "CODE"
                case message = "MESSAGE"
            }
        }
        
        struct Row: Codable {
            var rackTotCnt: String?
            var stationName: String?
            var parkingBikeTotCnt: String?
            var shared: String?
            var stationLatitude: String?
            var stationLongitude: String?
            var stationId: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case result = "RESULT"
            case rows = "row"
            case listTotalCount = "list_total_count"
        }
    }
}
