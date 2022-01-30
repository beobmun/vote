//
//  LocalElectionView.swift
//  vote
//
//  Created by 한법문 on 2022/01/24.
//

import SwiftUI

struct LocalElectionView: View {
    let geometry: GeometryProxy
    @StateObject private var localElectionViewModel = LocalEletionViewModel()
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        
        if localElectionViewModel.commonCodes.count > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("선거 선택 : ")
                    
                    Spacer()
                    
                    Picker("선거", selection: $localElectionViewModel.seletedCommonCode) {
                        ForEach (0..<localElectionViewModel.commonCodes.count) { i in
                            Text("\(localElectionViewModel.commonCodes[i].sgName)")
                                .tag(i)
                        }
                        .pickerStyle(.menu)
                    }
                } // HStack
                .padding([.horizontal], 20)
                
                Picker("종류", selection: $localElectionViewModel.selectedElection) {
                    Text("시·도지사")
                        .tag(0)
                    Text("구·시·군의장")
                        .tag(1)
                    Text("교육감")
                        .tag(2)
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing], 20)

                HStack {
                    Text("시도 : ")
                    Picker("시도", selection: $localElectionViewModel.selectedSdName) {
                        ForEach (LOCALS.sido, id: \.self) { sdName in
                            Text(sdName)
                        }
                        .pickerStyle(.menu)
                    }
                    .onChange(of: localElectionViewModel.selectedSdName) { sdName in
                        localElectionViewModel.filteredSggName(sdName)
                    }
                    if (localElectionViewModel.selectedElection == 1) {
                        Divider()
                            .frame(height: 20)
                        Text("선거구 : ")
                        Picker("선거구", selection: $localElectionViewModel.selectedSggName) {
                            ForEach (localElectionViewModel.sggNames, id:\.self) { sggName in
                                Text("\(sggName)")
                                    .tag(sggName)
                            }
                            .pickerStyle(.menu)
                        }
                        Spacer()
                    } else {
                        Spacer()
                    }
                    
                    Button {
                        localElectionViewModel.getCandidateActionSubject.send()
                    } label: {
                        if (!localElectionViewModel.isLoading) {
                            Text("조회")
                                .foregroundColor(Color.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }

                } // HStack
                .padding([.horizontal], 20)
                if localElectionViewModel.isLoading {
                    VStack {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                } else {
                    
                    List(localElectionViewModel.candidateInfo) { info in
                        NavigationLink {
                            CandidateDetailInfoView(geometry,
                                                    info,
                                                    localElectionViewModel.election[localElectionViewModel.selectedElection],
                                                    localElectionViewModel.commonCodes[localElectionViewModel.seletedCommonCode])
                        } label: {
                            CandidateRowView(geometry, info, localElectionViewModel.election[localElectionViewModel.selectedElection])
                        }
                    }
                    .listStyle(.plain)
                }
                
                
            } // VStack
            .navigationTitle(Text("전국동시지방선거"))
        }
    }
}
