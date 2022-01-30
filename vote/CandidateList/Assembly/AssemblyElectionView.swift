//
//  AssemblyElectionView.swift
//  vote
//
//  Created by 한법문 on 2022/01/25.
//

import SwiftUI

struct AssemblyElectionView: View {
    let geometry: GeometryProxy
    
    @StateObject private var assemblyElectionViewModel = AssemblyElectionViewModel()
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        if assemblyElectionViewModel.commonCodes.count > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("선거 선택 : ")
                    
                    Spacer()
                    
                    Picker("선거", selection: $assemblyElectionViewModel.seletedCommonCode) {
                        ForEach (0..<assemblyElectionViewModel.commonCodes.count) { i in
                            Text("\(assemblyElectionViewModel.commonCodes[i].sgName)")
                                .tag(i)
                        }
                        .pickerStyle(.menu)
                    }
                } // HStack
                .padding([.horizontal], 20)
                
                HStack {
                    Text("시도 : ")
                    Picker("시도", selection: $assemblyElectionViewModel.selectedSdName) {
                        ForEach (LOCALS.sido, id: \.self) { sdName in
                            Text(sdName)
                        }
                        .pickerStyle(.menu)
                    }
                    .onChange(of: assemblyElectionViewModel.selectedSdName) { sdName in
                        assemblyElectionViewModel.filteredSggName(sdName)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    Text("선거구 : ")
                    Picker("선거구", selection: $assemblyElectionViewModel.selectedSggName) {
                        ForEach (assemblyElectionViewModel.sggNames, id: \.self) { sggName in
                            Text(sggName)
                                .tag(sggName)
                        }
                        .pickerStyle(.menu)
                    }
                    Spacer()
                    
                    Button {
                        assemblyElectionViewModel.getCandidateActionSubject.send()
                    } label: {
                        if (!assemblyElectionViewModel.isLoading) {
                            Text("조회")
                                .foregroundColor(Color.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                } // HStack
                .padding([.horizontal], 20)
                
                if assemblyElectionViewModel.isLoading {
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
                    List(assemblyElectionViewModel.candidateInfo) { info in
                        NavigationLink {
                            CandidateDetailInfoView(geometry,
                                                    info,
                                                    assemblyElectionViewModel.election,
                                                    assemblyElectionViewModel.commonCodes[assemblyElectionViewModel.seletedCommonCode])
                        } label: {
                            CandidateRowView(geometry, info, assemblyElectionViewModel.election)
                                .onAppear {
                                    if self.assemblyElectionViewModel.candidateInfo.last == info {
                                        assemblyElectionViewModel.getMoreActionSubject.send()
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            } // VStack
            .navigationTitle(Text("국회의원선거"))
        }
        if assemblyElectionViewModel.isMoreLoading {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
