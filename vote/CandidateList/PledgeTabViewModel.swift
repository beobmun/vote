//
//  PledgeTabViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/19.
//

import Foundation
import Combine
import Alamofire
import SwiftUI


class PledgeTabViewModel: ObservableObject {
    
    var subscription = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var index = 0
    @Published var pledgeInfo: PledgeGetResponse?
    @Published var pledges = [Pledge]()
    
    func getPledge(_ election: Election, _ commonCode: CommonCode, _ info: CandidateItem) {
        isLoading = true
        AF.request(Router.getPledge(sgId: commonCode.sgId, sgTypecode: election.rawValue, cnddtId: info.cnddtId))
            .publishDecodable(type: PledgeResponse.self)
            .compactMap { $0.value }
            .sink { [weak self] completion in
                guard let self = self else { return }
                guard let pleInfo = self.pledgeInfo else {
                    self.isLoading = false
                    print ("pleInfo fail")
                    self.saveRecentSearchCandidate(OverallData(election: election, commonCode: commonCode, candidateItem: info, posterImage: info.posterImage, elected: info.elected, pledgeArray: self.pledges))
                    return }
                self.pledgeSplit(pleInfo)
                self.saveRecentSearchCandidate(OverallData(election: election, commonCode: commonCode, candidateItem: info, posterImage: info.posterImage, elected: info.elected, pledgeArray: self.pledges))
                self.isLoading = false
            } receiveValue: { [weak self] receiveValue in
                guard let self = self else { return }
                self.pledgeInfo = receiveValue.getResponse
            }
            .store(in: &subscription)

    }
    
    func pledgeSplit(_ pledgeInfo: PledgeGetResponse) {
        if pledgeInfo.header.code == "INFO-00" {
            for item in pledgeInfo.item {
                var pledges = [Pledge]()
                let prmsCnt: Int = Int(item.prmsCnt)! < 10 ? Int(item.prmsCnt)! : 10
                var pledge = Dictionary<Int, Pledge>()
                pledge[0] = Pledge.init(name: item.prmsRealmName1, title: item.prmsTitle1, content: item.prmmCont1)
                pledge[1] = Pledge.init(name: item.prmsRealmName2, title: item.prmsTitle2, content: item.prmmCont2)
                pledge[2] = Pledge.init(name: item.prmsRealmName3, title: item.prmsTitle3, content: item.prmmCont3)
                pledge[3] = Pledge.init(name: item.prmsRealmName4, title: item.prmsTitle4, content: item.prmmCont4)
                pledge[4] = Pledge.init(name: item.prmsRealmName5, title: item.prmsTitle5, content: item.prmmCont5)
                pledge[5] = Pledge.init(name: item.prmsRealmName6, title: item.prmsTitle6, content: item.prmmCont6)
                pledge[6] = Pledge.init(name: item.prmsRealmName7, title: item.prmsTitle7, content: item.prmmCont7)
                pledge[7] = Pledge.init(name: item.prmsRealmName8, title: item.prmsTitle8, content: item.prmmCont8)
                pledge[8] = Pledge.init(name: item.prmsRealmName9, title: item.prmsTitle9, content: item.prmmCont9)
                pledge[9] = Pledge.init(name: item.prmsRealmName10, title: item.prmsTitle10, content: item.prmmCont10)
                for i in (0..<prmsCnt) {
                    guard let p = pledge[i] else { return }
                    pledges.append(p)
                }
                self.pledges = pledges
                print("pledges success")
            }
        }
    }
    
    func saveRecentSearchCandidate(_ overallData: OverallData) {
        let myDB = DBHelper.shared
        let tableName = "\(SQLiteTableName.recentSearchCandidate)"
//        myDB.deleteTable(tableName)
        //기존 것과 비교
        let recentSearchViewModel = RecentSearchViewModel()
        for data in recentSearchViewModel.recentSearchCandidates {
            let cnddtId = data.candidateItem.cnddtId
            if cnddtId == overallData.candidateItem.cnddtId {
                print("same cnddtId")
                return
            }
        }
        
        let columm = ["overallData"]

        myDB.createTable(tableName, columm)

        do {
            let data = try JSONEncoder().encode(overallData)
            let dataToString = String(data: data, encoding: .utf8)
            myDB.insertData("\(SQLiteTableName.recentSearchCandidate)", columm, [dataToString!])
        }
        catch {
            print("JsonEncoder Error")
        }
//        myDB.readData(tableName)
    }
}
