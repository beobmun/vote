//
//  HomeImage.swift
//  vote
//
//  Created by 한법문 on 2022/01/09.
//

import SwiftUI
import Combine
import URLImage

struct HomeImageView: View {
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var currnetIndex = 0
    @ObservedObject private var homeImageViewModel = HomeImageViewModel()
    let geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        let imgCnt = homeImageViewModel.homeImagesUrl.count
        let width = geometry.size.width
        
        if (imgCnt > 0) {
            TabView(selection: $currnetIndex) {
                ForEach(0..<imgCnt) { i in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .frame(width: width, height: width * 3/4)
                            .tag(i)
                        if let url = homeImageViewModel.homeImagesUrl["\(i)"] {
                            URLImage(url) { image in
                                image
                                    .resizable()
                                    .frame(width: width + 10, height: width * 3/4)
                                    .clipped()
                            }
                        } //UrlImage

                    } //ZStack

                } //ForEach
            } //TabView
            .tabViewStyle(PageTabViewStyle())
            .onReceive(timer) { _ in
                withAnimation {
                    currnetIndex = currnetIndex < imgCnt ? currnetIndex + 1 : 0
                }
            }
        } else {
            Text("loading...")
        }
    }
}

struct HomeImageView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            HomeImageView(geometry)
        }
        
    }
}
