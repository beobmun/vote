//
//  LocalEletionViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/24.
//

import Foundation
import Combine
import Firebase
import FirebaseStorage
import Alamofire

enum LOCALS {
     // 지역 상수 설정
    static let sido = ["서울특별시", "부산광역시", "대구광역시", "인천광역시", "광주광역시", "대전광역시", "울산광역시", "세종특별자치시", "경기도", "강원도", "충청북도", "충청남도", "전라북도", "전라남도", "경상북도", "경상남도", "제주특별자치도"]
    static let seoul = ["강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"]
    static let busan = ["강서구", "금정구", "기장군", "남구", "동구", "동래구", "부산진구", "북구", "사상구", "사하구", "서구", "수영구", "연제구", "영도구", "중구", "해운대구"]
    static let daegu = ["남구", "달서구", "달성군", "동구", "북구", "서구", "수성구", "중구"]
    static let incheon = ["강화군", "계양구", "남동구", "동구", "미추홀구", "부평구", "서구", "연수구", "옹진군", "중구"]
    static let gwangju = ["광산구", "남구", "동구", "북구", "서구"]
    static let daejeon = ["대덕구", "동구", "서구", "유성구", "중구"]
    static let ulsan = ["남구", "동구", "북구", "울주군", "중구"]
    static let sejong = ["세종시"]
    static let gyeonggi = ["가평군", "고양시", "과천시", "광명시", "광주시", "구리시", "군포시", "김포시", "남양주시", "동두천시", "부천시", "성남시", "수원시", "시흥시", "안산시", "안성시", "안양시", "양주시", "양평군", "여주시", "연천군", "오산시", "용인시", "의왕시", "의정부시", "이천시", "파주시", "평택시", "포천시", "하남시", "화성시"]
    static let gangwon = ["강릉시", "고성군", "동해시", "삼척시", "속초시", "양구군", "양양군", "영월군", "원주시", "인제군", "정선군", "철원군", "춘천시", "태백시", "평창군", "홍천군", "화천군", "횡성군"]
    static let chungcheongN = ["괴산군", "단양군", "보은군", "영동군", "옥천군", "음성군", "제천시", "증평군", "진천군", "청주시 상당구", "청주시 서원구", "청주시 청원구", "청주시 흥덕구", "충주시"]
    static let chungcheongS = ["계룡시", "공주시", "금산군", "논산시", "당진시", "보령시", "부여군", "서산시", "서천군", "아산시", "예산군", "천안시", "청양군", "태안군", "홍성군"]
    static let jeollaN = ["고창군", "군산시", "김제시", "남원시", "무주군", "부안군", "순창군", "완주군", "익산시", "임실군", "장수군", "전주시", "정읍시", "진안군"]
    static let jeollaS = ["강진군", "고흥군", "곡성군", "광양시", "구례군", "나주시", "담양군", "목포시", "무안군", "보성군", "순천시", "신안군", "여수시", "영광군", "영암군", "완도군", "장성군", "장흥군", "진도군", "함평군", "해남군", "화순군"]
    static let gyeongsangN = ["경산시", "경주시", "고령군", "구미시", "군위군", "김천시", "문경시", "봉화군", "상주시", "성주군", "안동시", "영덕군", "영양군", "영주시", "영천시", "예천군", "울릉군", "울진군", "의성군", "청도군", "청송군", "칠곡군", "포항시 남구", "포항시 북구"]
    static let gyeongsangS = ["거제시", "거창군", "고성군", "김해시", "남해군", "밀양시", "사천시", "산청군", "양산시", "의령군", "진주시", "창녕군", "창원시", "통영시", "하동군", "함안군", "함양군", "합천군"]
    static let jeju = ["서귀포시", "제주시"]
}

class LocalEletionViewModel: ObservableObject {
    var subscription = Set<AnyCancellable>()
    
    @Published var commonCodes = [CommonCode]()
    @Published var seletedCommonCode = 0
    @Published var election: [Election] = [.governor, .mayor, .superintendent]
    @Published var selectedElection = 0
    @Published var selectedSdName: String = LOCALS.sido[0]
    @Published var selectedSggName: String = ""
    @Published var sggNames = [String]()
    @Published var isLoading: Bool = false
    
    @Published var candidateInfo = [CandidateItem]()
    @Published var posterImage = [URL]()
    @Published var candidateStatus: CandidateGetResponse?
    
    var winnerInfo = [WinnerItem]()
    var winnerStatus: WinnerGetResponse?
    
    var getCandidateActionSubject = PassthroughSubject<(), Never>()
    
    init() {
        getCommonCode()
        filteredSggName(selectedSdName)
        
        getCandidateActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            self.isLoading = true
            self.getPosterImage()
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
        let ref = fireDB.collection("CommonCodes").document("local")
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
        let sgTypecode = election[selectedElection].rawValue
        let sdName = selectedSdName
        var sggName = election[selectedElection] != .mayor ? sdName : selectedSggName
        if (sgId <= "20180613" && sdName == "인천광역시" && sggName == "미추홀구") {
            sggName = "남구"
        }
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
        let document = "\(election[selectedElection])(\(sgId))"
        let ref = fireDB.collection("PosterImage").document(document)
        
        let key = election[selectedElection] != .mayor ? selectedSdName : "\(selectedSdName) \(selectedSggName)"
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
        let sgTypecode = election[selectedElection].rawValue
        let sdName = selectedSdName
        var sggName = election[selectedElection] != .mayor ? sdName : selectedSggName
        if (sgId <= "20180613" && sdName == "인천광역시" && sggName == "미추홀구") { // 인천광역시 "남구" -> "미추홀구"로 변경
            sggName = "남구"
        }
        print("sgTypecode : \(sgTypecode)")
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
                    if candidate.sgg_name == sggName { // sggName이 "서구"일때 "강서구"도 같이 검색되어 추가되는것을 방지
                        var info = candidate
                        if index < self.posterImage.count {
                            info.posterImage = self.posterImage[index]
                            index += 1
                        }
                        info.elected = self.winnerCmp(self.winnerInfo, info)
                        self.candidateInfo.append(info)
                    }
                }
            }
            .store(in: &subscription)
    }
    
    
}
