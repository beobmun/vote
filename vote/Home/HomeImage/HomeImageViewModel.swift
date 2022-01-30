//
//  HomeViewModel.swift
//  vote
//
//  Created by 한법문 on 2022/01/08.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Combine

let fireDB = Firestore.firestore()

class HomeImageViewModel: ObservableObject {
    
    @Published var homeImagesUrl: [String: URL] = [:]
    
    init() {
        print("실행")
        getHomeImageUrl()
    }
    
    let homeImagesRef = fireDB.collection("Home").document("HomeImage")
    func getHomeImageUrl() {
        homeImagesRef.getDocument { snapshot, err in
            if let snapshot = snapshot, snapshot.exists {
                guard let data = snapshot.data() else { return }
                for value in data {
                    self.homeImagesUrl[value.key] = URL(string: value.value as! String)
                }
                // enum으로 url에 대한 key 만들어서 뷰에서 불러올때 컨드롤
            } else {
                print("err")
            }
        }
    }
    
}
