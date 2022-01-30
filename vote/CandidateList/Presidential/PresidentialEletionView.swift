//
//  PresidentialEletionView.swift
//  vote
//
//  Created by 한법문 on 2022/01/10.
//

import SwiftUI
import URLImage

struct PresidentialElectionView: View {
    let geometry: GeometryProxy
    let election: Election = .presidential
    
    @StateObject private var presidentialEletionViewModel = PresidentialElectionViewModel(.presidential)
    //@State private var selected: Int = 0
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        
        if let headerCode = presidentialEletionViewModel.candidateStatus?.header.code,
           headerCode == "INFO-00" && !presidentialEletionViewModel.isLoading {
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("선거 선택 : ")
                        .padding()
                    
                    Spacer()
                    
                    Picker("선거", selection: $presidentialEletionViewModel.selected, content: {
                        ForEach (0..<presidentialEletionViewModel.commonCodes.count) { i in
                            Text("\(presidentialEletionViewModel.commonCodes[i].sgName)")
                                .tag(i)
                        }
                    })
                        .padding([.leading, .trailing], 20)
                        .pickerStyle(.menu)
                        .onChange(of: presidentialEletionViewModel.selected) { _ in
                            presidentialEletionViewModel.refreshActionSubject.send()
                        }

                } // HStack

                List(presidentialEletionViewModel.candidateInfo) { info in
                    NavigationLink {
                        CandidateDetailInfoView(geometry,
                                                info,
                                                election,
                                                presidentialEletionViewModel.commonCodes[presidentialEletionViewModel.selected])

                    } label: {
                        CandidateRowView(geometry, info, election)
                            .onAppear {
                                if self.presidentialEletionViewModel.candidateInfo.last == info {
                                    presidentialEletionViewModel.getMoreActionSubject.send()
                                }
                            }
                    
                    }
                    
                }
                .listStyle(.plain)
                .navigationTitle(Text("대통령선거"))
            } // VStack
            if presidentialEletionViewModel.isMoreLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        } else {
            ProgressView()
            .progressViewStyle(.circular)
            
        }
    }
}

struct CandidateRowView: View {
    var geometry: GeometryProxy
    var candidateInfo: CandidateItem
    var election: Election
    
    init(_ geometry: GeometryProxy, _ candidateInfo: CandidateItem, _ election: Election) {
        self.geometry = geometry
        self.candidateInfo = candidateInfo
        self.election = election
    }
    var body: some View {
        let width = geometry.size.width
        
        HStack(spacing: 20) {
            if let url = candidateInfo.posterImage {
                URLImage(url) { image in
                    image
                        .resizable()
                        .frame(width: width / 4, height: width / 3)
                }
            }
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    let giho = election == .assembly ? "\(candidateInfo.sgg_name) 기호 \(candidateInfo.giho)번" : "기호 \(candidateInfo.giho)번"
                    Text(giho)
                    if candidateInfo.elected {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                
                Spacer()
                Text("\(candidateInfo.party)")
                Spacer()
                Text("\(candidateInfo.name)")
                Spacer()
            }
        }

    }
}

//struct PresidentialElectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geo in
//            PresidentialElectionView(geo)
//        }
//
//    }
//}
