//
//  MainView.swift
//  vote
//
//  Created by 한법문 on 2021/12/30.
//

import SwiftUI
import URLImage

struct HomeView: View {
    let geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                let width: CGFloat = geometry.size.width
                VStack {
                        
                    HomeImageView(geometry)
                        .frame(height: width * 3/4)
                    RecentSearchView(geometry)
                    CategoryBtnView(geometry)
                } // Vstack

            } //ScrollView
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("선거PICK")
                        .font(.title)
                    
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack {
//                        NavigationLink(destination: Text("trailing")) {
//                            Image(systemName: "person.circle")
//                                .foregroundColor(Color.black)
//                                .font(.system(size: 25))
//                        }
//                        NavigationLink(destination: Text("trailing 2")) {
//                            Image(systemName: "person.circle.fill")
//                        }
//                    }
//                }
            }) //toolbar
            .navigationBarTitleDisplayMode(.inline)
        } //NavigationView
        .navigationViewStyle(.stack)

        


    }
}





struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            HomeView(geo)
        }
        
    }
}
