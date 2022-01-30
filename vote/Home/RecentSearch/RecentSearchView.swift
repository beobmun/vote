//
//  RecentSearchView.swift
//  vote
//
//  Created by 한법문 on 2022/01/20.
//

import SwiftUI
import URLImage

struct RecentSearchView: View {
    let geometry: GeometryProxy
    
    @ObservedObject private var recentSearchViewModel = RecentSearchViewModel()

    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    var body: some View {
        
        VStack {
            HStack {
                Text("최근 검색")
                Spacer()
                NavigationLink {
                    RecentSearchListView(geometry, recentSearchViewModel)
                } label: {
                    Text("더보기")
                        .foregroundColor(Color.blue)
                }

            } // HStack
            if recentSearchViewModel.recentSearchCandidates.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(recentSearchViewModel.recentSearchCandidates) { candidate in
                            NavigationLink {
                                RecentSearchDetailView(geometry, candidate, recentSearchViewModel)
                            } label: {
                                RecentCandidateCard(geometry, candidate)
                            }
                        }
                    }
                    
                } //ScrollView
            } else {
                Text("최근 검색내역이 없습니다.")
            }


        } //VStack
        .padding()
        .onAppear {
            recentSearchViewModel.refreshActionSubject.send()
        }
    }
}

struct RecentCandidateCard: View {
    let overallData: OverallData
    let geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy, _ overallData: OverallData) {
        self.geometry = geometry
        self.overallData = overallData
    }
    
    var body: some View {
        let width = geometry.size.width

        HStack {
            if let url = overallData.posterImage {
                URLImage(url) { image in
                    image
                        .resizable()
                        .frame(width: width / 6, height: width / 6 * 3/2)
                }
            }

            VStack(spacing: 5) {

                switch overallData.election {
                case .presidential:
                    Text(overallData.commonCode.sgName)
                        .foregroundColor(.black)
                case .assembly:
                    Text("\(overallData.commonCode.sgName)\n\(overallData.candidateItem.sd_name) \(overallData.candidateItem.sgg_name)\n국회의원")
                        .foregroundColor(.black)
                case .governor:
                    VStack {
                        Text("\(overallData.commonCode.sgName)")
                        Text("\(overallData.candidateItem.sd_name)")
                        Text("시·도지사선거")
                    }
                    .foregroundColor(.black)
                    .font(.subheadline)
                case .mayor:
                    Text("\(overallData.commonCode.sgName)\n\(overallData.candidateItem.sd_name) \(overallData.candidateItem.sgg_name)\n구·시·군의장선거")
                        .foregroundColor(.black)
                case .superintendent:
                    Text("\(overallData.commonCode.sgName)\n\(overallData.candidateItem.sd_name)\n교육감선거")
                        .foregroundColor(.black)
                }
                
                Text("기호 \(overallData.candidateItem.giho)번")
                    .foregroundColor(.black)
                Text(overallData.candidateItem.name)
                    .foregroundColor(.black)

            }
        } // HStack
        .frame(width: width / 1.8, height: width / 3.2)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(10)
        .shadow(color: .gray, radius: 5, x: 5, y: 5)
        
    }
}


//struct RecentCandidateCard_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            RecentSearchView(geometry, true)
//        }
//
//    }
//}
