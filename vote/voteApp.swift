//
//  voteApp.swift
//  vote
//
//  Created by 한법문 on 2021/12/29.
//

import SwiftUI
import Firebase

@main
struct voteApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
