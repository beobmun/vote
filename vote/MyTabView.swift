//
//  TabView.swift
//  vote
//
//  Created by 한법문 on 2022/01/06.
//

import SwiftUI


struct MyTabView: View {
    
    let geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(geometry)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(.stack)
            }
            .tabItem {
                Image(systemName: "house")
            }
            .tag(0)

            Text("Second View")
                .tabItem {
                    Image(systemName: "newspaper")
                }
                .tag(1)
        }
    }
}

struct MyTabView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            MyTabView(geometry)
        }
        
    }
}
