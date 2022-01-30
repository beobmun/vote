//
//  CategoryBtnView.swift
//  vote
//
//  Created by 한법문 on 2022/01/24.
//

import SwiftUI

struct CategoryBtnView: View {
    let geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        let width = geometry.size.width
        HStack(alignment: .center) {
            NavigationLink {
                PresidentialElectionView(geometry)
            } label: {
                Text("대통령선거")
                    .frame(width: width / 4, height: width / 3)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray, radius: 5, x: 5, y: 5)

            }
            
            Spacer()
            
            NavigationLink {
                LocalElectionView(geometry)
            } label: {
                Text("전국동시지방선거")
                    .frame(width: width / 4, height: width / 3)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray, radius: 5, x: 5, y: 5)
            }
            
            Spacer()
            
            NavigationLink {
                AssemblyElectionView(geometry)
            } label: {
                Text("국회의원선거")
                    .frame(width: width / 4, height: width / 3)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray, radius: 5, x: 5, y: 5)
            }
            
        } // HStack
        .padding()
    }
}
