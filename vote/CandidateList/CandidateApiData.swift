//
//  ApiData.swift
//  vote
//
//  Created by 한법문 on 2022/01/12.
//

import Foundation


struct CandidateInfoResponse: Codable {
    var getResponse: CandidateGetResponse
    
    private enum CodingKeys: String, CodingKey {
        case getResponse = "getPofelcddRegistSttusInfoInqire"
    }
}

struct CandidateGetResponse: Codable {
    var header: CandidateHeader
    var item: [CandidateItem]
    var numOfRows: Int
    var pageNo: Int
    var totalCount: Int
}

struct CandidateHeader: Codable {
    var code: String
    var message: String
}

struct CandidateItem: Codable, Identifiable {
    var id = UUID()
    var posterImage: URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/vote-59bad.appspot.com/o/DefaultImage%2Fperson.png?alt=media&token=50f508c2-e8db-44ea-b173-440a7f0d421b")!
    var elected: Bool = false
    var giho: String
    var cnddtId: String
    var party: String
    var name: String
    var gender: String
    var birthday: String
    var age: String
    var job: String
    var edu: String
    var career1: String
    var career2: String
    var sd_name: String
    var sgg_name: String
    
    private enum CodingKeys: String, CodingKey {
//        case posterImage = "posterImage"
//        case elected = "elected"
        case giho = "GIHO"
        case cnddtId = "HUBOID"
        case party = "JD_NAME"
        case name = "NAME"
        case gender = "GENDER"
        case birthday = "BIRTHDAY"
        case age = "AGE"
        case job = "JOB"
        case edu = "EDU"
        case career1 = "CAREER1"
        case career2 = "CAREER2"
        case sd_name = "SD_NAME"
        case sgg_name = "SGG_NAME"
        
    }
}

extension CandidateItem: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
