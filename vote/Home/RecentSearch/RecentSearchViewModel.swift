//
//  RecentSearchViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/20.
//

import Foundation
import Combine

class RecentSearchViewModel: ObservableObject {
    @Published var recentSearchCandidates = [OverallData]()
    var candidateIDArr = [Int]()
    var subscription = Set<AnyCancellable>()
    
    let myDB = DBHelper()
    var refreshActionSubject = PassthroughSubject<(), Never>()
    
    init() {
        getRecentSearchCandidates()
        
        refreshActionSubject.sink { [weak self] _ in
            guard let self = self else { return }
            print("recentSearch - refresh")
            self.getRecentSearchCandidates()
            print(self.recentSearchCandidates.count)
        }.store(in: &subscription)
    }
    
    func getRecentSearchCandidates() {
        let columm = ["overallData"]
        var readData = Dictionary<Int, Any>()
        var keyArr = [Int]()

        readData = myDB.readData("\(SQLiteTableName.recentSearchCandidate)", columm)
        var overallData = [OverallData]()
        for (key, value) in readData {
            var index = 0
            for k in keyArr {
                if key < k {
                    index += 1
                }
            }
            if let data = value as? Dictionary<String, String> {
                do {
                    let data = try JSONDecoder().decode(OverallData.self, from: (data["overallData"]!.data(using: .utf8))!)
                    overallData.insert(data, at: index)
                    keyArr.insert(key, at: index)
                }
                catch {
                    print("JSONDecoder Error")
                }
            }
            
        }
        self.recentSearchCandidates = overallData
        self.candidateIDArr = keyArr
    }
    
    func deleteCandidate(_ candidate: OverallData) {
        let current = candidate.candidateItem.cnddtId
        var currentIndex: Int? {
            for i in 0..<recentSearchCandidates.count {
                let cnddtId = recentSearchCandidates[i].candidateItem.cnddtId
                if cnddtId == current {
                    return i
                }
            }
            return nil
        }
        guard let i = currentIndex else { return }
        let id = candidateIDArr[i]
        myDB.deleteData("\(SQLiteTableName.recentSearchCandidate)", id)
    }
}
