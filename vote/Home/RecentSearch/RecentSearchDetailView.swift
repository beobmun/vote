//
//  RecentSearchDetailView.swift
//  vote
//
//  Created by 한법문 on 2022/01/23.
//

import SwiftUI
import URLImage

struct RecentSearchDetailView: View {
    let geometry: GeometryProxy
    let candidate: OverallData
    @State private var pledgeIndex = 0
    @State private var showAlert = false
    @State private var isDelete = false
    @ObservedObject private var recentSearchViewModel: RecentSearchViewModel
    
    init(_ geometry: GeometryProxy, _ candidate: OverallData, _ recentSearchViewModel: RecentSearchViewModel) {
        self.geometry = geometry
        self.candidate = candidate
        self.recentSearchViewModel = recentSearchViewModel
    }
    
    var body: some View {
        let width = geometry.size.width
        ScrollView {
            HStack {
                Spacer()
                if let url = candidate.posterImage {
                    URLImage(url) { image in
                        image
                            .resizable()
                            .frame(width: width / 2, height: width * 3/4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    
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
                    
                    Text("기호 \(candidate.candidateItem.giho) 번")
                        .font(.title)
                    Text(candidate.candidateItem.party)
                        .font(.title2)
                    Text("\(candidate.candidateItem.name) (\(candidate.candidateItem.gender), \(candidate.candidateItem.age))")
                        .font(.title3)
                } // VStack
                Spacer()
            } // HStack
            
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                Text("<기본 정보>")
                    .font(.title2)
                Text("직업 : \(candidate.candidateItem.job)")
                Text("학력 : \(candidate.candidateItem.edu)")

                Divider()
                
                Text("<주요 경력>")
                    .font(.title2)
                Text("  - \(candidate.candidateItem.career1)")
                Text("  - \(candidate.candidateItem.career2)")

                Divider()
                Text("<공약>")
                    .font(.title2)

            }
            .padding([.horizontal], 20)
            
            VStack {
                if (candidate.pledgeArray.count > 0) {
                    TabView(selection: $pledgeIndex) {
                        ForEach(0..<candidate.pledgeArray.count) { i in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(candidate.pledgeArray[pledgeIndex].name)
                                        .font(.headline)

                                    Text(candidate.pledgeArray[pledgeIndex].title)
                                        .font(.title3)

                                    Text(candidate.pledgeArray[pledgeIndex].content)
                                        .font(.body)
                                    Spacer().frame(height: 30)
                                    
                                    Divider()
                                        
                                }
                                .tag(i)
                            }

                        }
                    }
                    .frame(height: 500)
                    .tabViewStyle(PageTabViewStyle())
                } else {
                    VStack(alignment: .leading) {
                        Text("공약을 불러올 수 없습니다.")
                        Divider()
                    }
                }
            }
            .padding([.horizontal], 20)
        } // ScrollView
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isDelete {
                    Button {
                        self.showAlert.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        } // toolbar
        .alert(isPresented: $showAlert) {
            Alert(title: Text("삭제"), message: Text("최근 검색 목록에서 삭제 하시겠습니까?"), primaryButton: .default(Text("확인"), action: {
                recentSearchViewModel.deleteCandidate(candidate)
                isDelete = true
            }), secondaryButton: .cancel())
        }
    }
}
