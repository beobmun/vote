//
//  RecentSearchListView.swift
//  vote
//
//  Created by 한법문 on 2022/01/24.
//

import SwiftUI
import URLImage

struct RecentSearchListView: View {
    let geometry: GeometryProxy
    let candidates: [OverallData]
    @ObservedObject private var recentSearchViewModel: RecentSearchViewModel

    init(_ geometry: GeometryProxy, _ recentSearchViewModel: RecentSearchViewModel) {
        self.geometry = geometry
        self.candidates = recentSearchViewModel.recentSearchCandidates
        self.recentSearchViewModel = recentSearchViewModel
    }
    
    
    var body: some View {
        let width = geometry.size.width
        
        List(candidates) { candidate in
            NavigationLink  {
                RecentSearchDetailView(geometry, candidate, recentSearchViewModel)
            } label: {
                HStack(spacing: 20) {
                    if let url = candidate.posterImage {
                        URLImage(url) { image in
                            image
                                .resizable()
                                .frame(width: width / 4, height: width / 3)
                        }
                    }
                    VStack(alignment: .leading) {
                        
                        switch candidate.election {
                        case .presidential:
                            Text(candidate.commonCode.sgName)
                                .font(.headline)
                        case .assembly:
                            Text("\(candidate.commonCode.sgName)\n\(candidate.candidateItem.sd_name) \(candidate.candidateItem.sgg_name)\n국회의원")
                                .font(.headline)
                        case .governor:
                            Text("\(candidate.commonCode.sgName)\n\(candidate.candidateItem.sd_name)\n시·도지사선거")
                                .font(.headline)
                        case .mayor:
                            Text("\(candidate.commonCode.sgName)\n\(candidate.candidateItem.sd_name) \(candidate.candidateItem.sgg_name)\n구·시·군의장선거")
                                .font(.headline)
                        case .superintendent:
                            Text("\(candidate.commonCode.sgName)\n\(candidate.candidateItem.sd_name)\n교육감선거")
                                .font(.headline)
                        }
                        
                        Spacer()
                        HStack {
                            Text("기호 \(candidate.candidateItem.giho)번")
                            if candidate.candidateItem.elected {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Spacer()
                        Text("\(candidate.candidateItem.party)")
                        Spacer()
                        Text("\(candidate.candidateItem.name)")
                        Spacer()
                    }
                }
            }

        }
        .listStyle(.plain)
        .onAppear {
            recentSearchViewModel.refreshActionSubject.send()
        }
        .navigationTitle(Text("최근검색"))
    }
}
