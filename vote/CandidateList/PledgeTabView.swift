//
//  PledgeTabView.swift
//  vote
//
//  Created by 한법문 on 2022/01/19.
//

import SwiftUI

struct PledgeTabView: View {
    @ObservedObject private var pledgeTabViewModel = PledgeTabViewModel()
    
    let election: Election
    let commonCode: CommonCode
    let info: CandidateItem

    init(_ election: Election, _ commonCode: CommonCode, _ info: CandidateItem) {
        self.election = election
        self.commonCode = commonCode
        self.info = info
        pledgeTabViewModel.getPledge(election, commonCode, info)
    }
    
    var body: some View {
        let prmsCnt = pledgeTabViewModel.pledges.count
        
        VStack(alignment: .leading, spacing: 10) {
            Divider()
            Text("<공약>")
                .font(.title2)
            if (prmsCnt > 0 && !pledgeTabViewModel.isLoading) {
                TabView(selection: $pledgeTabViewModel.index) {
                    ForEach(0..<prmsCnt) { i in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(pledgeTabViewModel.pledges[pledgeTabViewModel.index].name)
                                    .font(.headline)

                                Text(pledgeTabViewModel.pledges[pledgeTabViewModel.index].title)
                                    .font(.title3)

                                Text(pledgeTabViewModel.pledges[pledgeTabViewModel.index].content)
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
            } else if (pledgeTabViewModel.isLoading) {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
                
            } else {
                VStack(alignment: .leading) {
                    Text("공약을 불러올 수 없습니다.")
//                    Text("(종료된 선거는 당선인만 공약을 조회할 수 있습니다.)")
                    Divider()
                }
            }
            
        } // VStack
        .padding([.horizontal], 20)

    }
}


//struct PledgeTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        PledgeTabView()
//
//    }
//}
