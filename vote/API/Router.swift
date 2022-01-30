//
//  Router.swift
//  vote
//
//  Created by 한법문 on 2022/01/13.
//

import Foundation
import Alamofire

let BASE_URL = "http://apis.data.go.kr/9760000/"
let SERVICE_KEY = "LhgTKfRfM3ttAo8YnPLNWIiv7HNj6MKDGDD2hM%2Bo8eFs5Dc1GoBVTCxId9CZE1vODiOYeuH%2FqaCEmpi2cC1Ayg%3D%3D".removingPercentEncoding

enum Router: URLRequestConvertible {

    case getCandidateInfo(serviceKey: String = SERVICE_KEY!,
                          pageNo: Int = 1,
                          numOfRows: Int = 10,
                          sgId: String,
                          sgTypecode: String,
                          resultType: String = "json",
                          sggName: String = "",
                          sdName: String = "")
    case getWinnerInfo(serviceKey: String = SERVICE_KEY!,
                       pageNo: Int = 1,
                       numOfRows: Int = 10,
                       sgId: String,
                       sgTypecode: String,
                       resultType: String = "json",
                       sggName: String = "",
                       sdName: String = "")
    
    case getPledge(serviceKey: String = SERVICE_KEY!,
                   pageNo: Int = 1,
                   numOfRows: Int = 10,
                   sgId: String,
                   sgTypecode: String,
                   resultType: String = "json",
                   cnddtId: String)
    
    var baseURL: URL {
        return URL(string: BASE_URL)!
    }
    
    var endPoint: String {
        switch self {
        case .getCandidateInfo:
            return "PofelcddInfoInqireService/getPofelcddRegistSttusInfoInqire"
        case .getWinnerInfo:
            return "WinnerInfoInqireService2/getWinnerInfoInqire"
        case .getPledge:
            return "ElecPrmsInfoInqireService/getCnddtElecPrmsInfoInqire"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCandidateInfo: return .get
        case .getWinnerInfo: return .get
        case .getPledge: return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .getCandidateInfo(serviceKey, pageNo, numOfRows, sgId, sgTypecode, resultType, sggName, sdName):
            var params = Parameters()
            params["serviceKey"] = serviceKey
            params["pageNo"] = pageNo
            params["numOfRows"] = numOfRows
            params["sgId"] = sgId
            params["sgTypecode"] = sgTypecode
            params["resultType"] = resultType
            params["sggName"] = sggName
            params["sdName"] = sdName
            return params
            
        case let .getWinnerInfo(serviceKey, pageNo, numOfRows, sgId, sgTypecode, resultType, sggName, sdName):
            var params = Parameters()
            params["serviceKey"] = serviceKey
            params["pageNo"] = pageNo
            params["numOfRows"] = numOfRows
            params["sgId"] = sgId
            params["sgTypecode"] = sgTypecode
            params["resultType"] = resultType
            params["sggName"] = sggName
            params["sdName"] = sdName
            return params
            
        case let .getPledge(serviceKey, pageNo, numOfRows, sgId, sgTypecode, resultType, cnddtId):
            var params = Parameters()
            params["serviceKey"] = serviceKey
            params["pageNo"] = pageNo
            params["numOfRows"] = numOfRows
            params["sgId"] = sgId
            params["sgTypecode"] = sgTypecode
            params["resultType"] = resultType
            params["cnddtId"] = cnddtId
            return params
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endPoint)
        var request = URLRequest(url: url)
        request.method = method
        
        switch self {
        case .getCandidateInfo:
            request = try URLEncoding.default.encode(request, with: parameters)
        case  .getWinnerInfo:
            request = try URLEncoding.default.encode(request, with: parameters)
        case .getPledge:
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}
