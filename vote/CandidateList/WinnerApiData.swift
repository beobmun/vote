//
//  WinnerApiData.swift
//  vote
//
//  Created by 한법문 on 2022/01/13.
//

import Foundation

struct WinnerInfoResponse: Codable {
    var getResponse: WinnerGetResponse
    
    private enum CodingKeys: String, CodingKey {
        case getResponse = "getWinnerInfoInqire"
    }
}

struct WinnerGetResponse: Codable {
    var header: WinnerHeader
    var item: [WinnerItem]
    var numOfRows: Int
    var pageNo: Int
    var totalCount: Int
}

struct WinnerHeader: Codable {
    var code: String
    var message: String
}

struct WinnerItem: Codable {
    var cnddtId: String
    var dugsu: String
    var dugyul: String
    
    private enum CodingKeys: String, CodingKey {
        case cnddtId = "HUBOID"
        case dugsu = "DUGSU"
        case dugyul = "DUGYUL"
    }
}
