//
//  AssemblyElectionViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/26.
//

import Foundation
import Combine
import Firebase
import Alamofire

class AssemblyElectionViewModel: ObservableObject {
    var subscription = Set<AnyCancellable>()
    
    @Published var commonCodes = [CommonCode]()
    @Published var seletedCommonCode = 0
    @Published var election: Election = .assembly
    @Published var selectedSdName: String = LOCALS.sido[0]
    @Published var selectedSggName: String = ""
    @Published var sggNames = [String]()
    @Published var isLoading: Bool = false
    @Published var isMoreLoading: Bool = false
    
    @Published var candidateInfo = [CandidateItem]()
    @Published var posterImage = [URL]()
    @Published var candidateStatus: CandidateGetResponse?
    
    var winnerInfo = [WinnerItem]()
    var winnerStatus: WinnerGetResponse?
    
    var getCandidateActionSubject = PassthroughSubject<(), Never>()
    var getMoreActionSubject = PassthroughSubject<(), Never>()

    init() {
        getCommonCode()
        filteredSggName(selectedSdName)
        
        getCandidateActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            self.isLoading = true
            self.getPosterImage()
        }.store(in: &subscription)
        
        getMoreActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            guard let currentPage = self.candidateStatus?.pageNo,
                  let totalCount = self.candidateStatus?.totalCount else { return }
            if (currentPage * 10 < totalCount && !self.isMoreLoading) {
                self.getMoreInfo()
            }
        }.store(in: &subscription)
    }
    
    func filteredSggName(_ selectedSdName: String) {
        if selectedSdName == "서울특별시" {
            sggNames = LOCALS.seoul
        } else if selectedSdName == "부산광역시" {
            sggNames = LOCALS.busan
        } else if selectedSdName == "대구광역시" {
            sggNames = LOCALS.daegu
        } else if selectedSdName == "인천광역시" {
            sggNames = LOCALS.incheon
        } else if selectedSdName == "광주광역시" {
            sggNames = LOCALS.gwangju
        } else if selectedSdName == "대전광역시" {
            sggNames = LOCALS.daejeon
        } else if selectedSdName == "울산광역시" {
            sggNames = LOCALS.ulsan
        } else if selectedSdName == "세종특별자치시" {
            sggNames = LOCALS.sejong
        } else if selectedSdName == "경기도" {
            sggNames = LOCALS.gyeonggi
        } else if selectedSdName == "강원도" {
            sggNames = LOCALS.gangwon
        } else if selectedSdName == "충청북도" {
            sggNames = LOCALS.chungcheongN
        } else if selectedSdName == "충청남도" {
            sggNames = LOCALS.chungcheongS
        } else if selectedSdName == "전라북도" {
            sggNames = LOCALS.jeollaN
        } else if selectedSdName == "전라님도" {
            sggNames = LOCALS.jeollaS
        } else if selectedSdName == "경상북도" {
            sggNames = LOCALS.gyeongsangN
        } else if selectedSdName == "경상남도" {
            sggNames = LOCALS.gyeongsangS
        } else {
            sggNames = LOCALS.jeju
        }
        selectedSggName = sggNames[0]
    }
    
    func getCommonCode() {
        let ref = fireDB.collection("CommonCodes").document("assembly")
        
        ref.getDocument { [weak self] snapshot, err in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                guard let data = snapshot.data() else { return }
                for value in data {
                    let commoncode = CommonCode(sgId: value.key, sgName: value.value as! String)
                    self.commonCodes.append(commoncode)
                }
            } else {
                print("getCommonCode err")
            }
            self.commonCodes.sort { $0.sgId > $1.sgId }
        }
    }
    
    func getWinnerInfo() {
        let sgId = commonCodes[seletedCommonCode].sgId
        let sgTypecode = election.rawValue
        let sdName = selectedSdName
        let sggName = selectedSggName
        
        AF.request(Router.getWinnerInfo(sgId: sgId, sgTypecode: sgTypecode, sggName: sggName, sdName: sdName))
            .publishDecodable(type: WinnerInfoResponse.self)
            .compactMap { $0.value }
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.getCandidateInfo()
            } receiveValue: { [weak self] receiveValue in
                guard let self = self else { return }
                self.winnerStatus = receiveValue.getResponse
                self.winnerInfo = receiveValue.getResponse.item
            }
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
    
    func getPosterImage() {
        let sgId = commonCodes[seletedCommonCode].sgId
        let document = "\(election)(\(sgId))"
        let ref = fireDB.collection("PosterImage").document(document)
        
        let key = "\(selectedSdName) \(selectedSggName)"
        print("document :", document)
        self.posterImage = [URL]()
        ref.getDocument { [weak self] snapshot, err in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                guard let data = snapshot.data() else { return }
                for d in data {
                    if (d.key == key) {
                        for value in d.value as! NSArray {
                            let url = URL(string: value as! String)!
                            self.posterImage.append(url)
                        }
                    }
                }
            }
        }
        
        getWinnerInfo()
    }
    
    func getCandidateInfo() {
        let sgId = commonCodes[seletedCommonCode].sgId
        let sgTypecode = election.rawValue
        let sdName = selectedSdName
        var sggName = selectedSggName
        if (sgId < "20200415" && sdName == "인천광역시" && sggName == "미추홀구") { // 인천광역시 "남구" -> "미추홀구"로 변경
            sggName = "남구"
        }
        self.candidateInfo = [CandidateItem]()
        AF.request(Router.getCandidateInfo(sgId: sgId, sgTypecode: sgTypecode, sggName: sggName, sdName: sdName))
            .publishDecodable(type: CandidateInfoResponse.self)
            .compactMap { $0.value }
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
            } receiveValue: { [weak self] receivedValue in
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
            }
            .store(in: &subscription)
    }
    
    func getMoreInfo() {
        guard let currentPage = candidateStatus?.pageNo else { return }
        let sgId = commonCodes[seletedCommonCode].sgId
        let sgTypecode = election.rawValue
        let sdName = selectedSdName
        var sggName = selectedSggName
        if (sgId < "20200415" && sdName == "인천광역시" && sggName == "미추홀구") { // 인천광역시 "남구" -> "미추홀구"로 변경
            sggName = "남구"
        }
        self.isMoreLoading = true
        
        AF.request(Router.getCandidateInfo(pageNo: currentPage + 1, sgId: sgId, sgTypecode: sgTypecode, sggName: sggName, sdName: sdName))
            .publishDecodable(type: CandidateInfoResponse.self)
            .compactMap { $0.value }
            .sink(receiveCompletion: { completion in
                self.isMoreLoading = false
            }, receiveValue: { [weak self] receivedValue in
                guard let self = self else { return }
                var candidateArray = [CandidateItem]()
                var index = self.candidateInfo.count
                for candidate in receivedValue.getResponse.item {
                    var info = candidate
                    if index < self.posterImage.count {
                        info.posterImage = self.posterImage[index]
                        index += 1
                    }
                    info.elected = self.winnerCmp(self.winnerInfo, info)
                    candidateArray.append(info)
                }
                self.candidateInfo += candidateArray
                
                self.candidateStatus = receivedValue.getResponse
            })
            .store(in: &subscription)
    }
    
}
