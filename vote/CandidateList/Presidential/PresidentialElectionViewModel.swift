//
//  CandidateListViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/10.
//

import Foundation
import Firebase
import Combine
import Alamofire
import SwiftUI

enum Election: String, Codable {
    case presidential = "1"
    case assembly = "2"
    case governor = "3"
    case mayor = "4"
    case superintendent = "11"
}

struct CommonCode: Codable {
    
    let sgId: String
    let sgName: String
}

class PresidentialElectionViewModel: ObservableObject {
    
    let election: Election
    var subscription = Set<AnyCancellable>()
    
    @Published var selected = 0
    @Published var commonCodes = [CommonCode]()
    @Published var candidateInfo = [CandidateItem]()
    @Published var posterImage = [URL]()
    @Published var candidateStatus: CandidateGetResponse?
    @Published var isLoading : Bool = false
    @Published var isMoreLoading : Bool = false
    
    var winnerInfo = [WinnerItem]()
    var winnerStatus: WinnerGetResponse?
    

    
    var refreshActionSubject = PassthroughSubject<(), Never>()
    var getMoreActionSubject = PassthroughSubject<(), Never>()
    
    init(_ election: Election)
    {
        self.election = election
        getCommonCode(election)
        print("실행됨")
        
        refreshActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            self.getPosterImage(election, self.selected)
        }.store(in: &subscription)
        
        getMoreActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            guard let currentPage = self.candidateStatus?.pageNo,
                  let totalCount = self.candidateStatus?.totalCount else { return }
            if (currentPage * 10 < totalCount && !self.isMoreLoading) {
                self.getMoreInfo(election, self.selected)
            }
        }.store(in: &subscription)
    }
    
    func getCommonCode(_ election: Election) {
        let ref = fireDB.collection("CommonCodes").document("\(election)")
        
        ref.getDocument { [weak self] snapshot, err in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                guard let data = snapshot.data() else { return }
                for value in data {
                    let commoncode = CommonCode(sgId: value.key, sgName: value.value as! String)
                    self.commonCodes.append(commoncode)
                }
            } else {
                print("err")
            }
            self.commonCodes.sort { $0.sgId > $1.sgId }
            self.getPosterImage(election, 0)
        }
    }
    
    func getPosterImage(_ election: Election, _ selected: Int) {
        let ref = fireDB.collection("PosterImage").document("\(election)")
        self.posterImage = [URL]()
        ref.getDocument { [weak self] snapshot, err in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                guard let data = snapshot.data() else { return }
                for d in data {
                    if (d.key == self.commonCodes[selected].sgId) {
                        for value in d.value as! NSArray {
                            let url = URL(string: value as! String)!
                            self.posterImage.append(url)
                        }
                    }
                }
            }
        }
//        getCandidateInfo(election, selected)
        getWinnerInfo(election, selected)
    }
    
    func getCandidateInfo(_ election: Election, _ selected: Int) {
        self.isLoading = true

        self.candidateInfo = [CandidateItem]()
        AF.request(Router.getCandidateInfo(sgId: commonCodes[selected].sgId, sgTypecode: election.rawValue))
            .publishDecodable(type: CandidateInfoResponse.self)
            .compactMap { $0.value }
            .sink(receiveCompletion: { completion in
                self.isLoading = false
            }, receiveValue: { [weak self] receivedValue in
                guard let self = self else { return }
                
                self.candidateStatus = receivedValue.getResponse
                
                var index = 0
                for candidate in receivedValue.getResponse.item {
                    var info = candidate
                    if index < self.posterImage.count {
                        info.posterImage = self.posterImage[index]
                        index += 1
                    }
                    info.elected = self.winnerCmp(self.winnerInfo, info)
                    self.candidateInfo.append(info)
                }
            })
            .store(in: &subscription)

    }
    
    func getMoreInfo(_ election: Election, _ selected: Int) {
        guard let currentPage = candidateStatus?.pageNo else { return }
        
        self.isMoreLoading = true
        
        AF.request(Router.getCandidateInfo(pageNo: currentPage + 1, sgId: commonCodes[selected].sgId, sgTypecode: election.rawValue))
            .publishDecodable(type: CandidateInfoResponse.self)
            .compactMap { $0.value }
            .sink(receiveCompletion: { completion in
                self.isMoreLoading = false
            }, receiveValue: { [weak self] receivedValue in
                guard let self = self else { return }
                var candidateArray = [CandidateItem]()
                for candidate in receivedValue.getResponse.item {
                    var info = candidate
                    let index = Int(candidate.giho)! - 1
                    info.posterImage = self.posterImage[index]
                    info.elected = self.winnerCmp(self.winnerInfo, info)
                    candidateArray.append(info)
                }
                self.candidateInfo += candidateArray
                
                self.candidateStatus = receivedValue.getResponse
            })
            .store(in: &subscription)
    }
    

    
    func getWinnerInfo(_ election: Election, _ selected: Int) {
        
        AF.request(Router.getWinnerInfo(sgId: commonCodes[selected].sgId, sgTypecode: election.rawValue))
            .publishDecodable(type: WinnerInfoResponse.self)
            .compactMap { $0.value }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.getCandidateInfo(election, selected)
            }, receiveValue: { [weak self] receiveValue in
                guard let self = self else { return }
                self.winnerStatus = receiveValue.getResponse
                self.winnerInfo = receiveValue.getResponse.item
//                print(receiveValue.getResponse.item[0].cnddtId)
            })
            .store(in: &subscription)
    }
    
    func winnerCmp(_ winner: [WinnerItem], _ candidate: CandidateItem) -> Bool {
        guard let winnerStatus = winnerStatus else { return false }
        if winnerStatus.header.code == "INFO-00" {
            for winner in winner {
                if candidate.cnddtId == winner.cnddtId {
                    return true
                }
            }
        }
        return false
    }
    

}
