//
//  PledgApiData.swift
//  vote
//
//  Created by 한법문 on 2022/01/17.
//

import Foundation


struct PledgeResponse: Codable {
    var getResponse: PledgeGetResponse
    
    private enum CodingKeys: String, CodingKey {
        case  getResponse = "getCnddtElecPrmsInfoInqire"
    }
}

struct PledgeGetResponse: Codable {
    var header: PledgeHeader
    var item: [PledgeItem]
    var numOfRows: Int
    var pageNo: Int
    var totalCount: Int
}

struct PledgeHeader: Codable {
    var code: String
    var message: String
}

struct PledgeItem: Codable {
    var prmsCnt: String
    var prmsRealmName1: String
    var prmsTitle1: String
    var prmmCont1: String
    var prmsRealmName2: String
    var prmsTitle2: String
    var prmmCont2: String
    var prmsRealmName3: String
    var prmsTitle3: String
    var prmmCont3: String
    var prmsRealmName4: String
    var prmsTitle4: String
    var prmmCont4: String
    var prmsRealmName5: String
    var prmsTitle5: String
    var prmmCont5: String
    var prmsRealmName6: String
    var prmsTitle6: String
    var prmmCont6: String
    var prmsRealmName7: String
    var prmsTitle7: String
    var prmmCont7: String
    var prmsRealmName8: String
    var prmsTitle8: String
    var prmmCont8: String
    var prmsRealmName9: String
    var prmsTitle9: String
    var prmmCont9: String
    var prmsRealmName10: String
    var prmsTitle10: String
    var prmmCont10: String
}

struct Pledge: Codable {
    var name: String
    var title: String
    var content: String
}
