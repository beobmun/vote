//
//  CandidateDetailInfoView.swift
//  vote
//
//  Created by 한법문 on 2022/01/13.
//


import SwiftUI
import URLImage

struct CandidateDetailInfoView: View {
    let geometry: GeometryProxy
    let info: CandidateItem
    let election: Election
    let commonCode: CommonCode
    
    init(_ geometry: GeometryProxy, _ info: CandidateItem, _ election: Election, _ commonCode: CommonCode) {
        self.geometry = geometry
        self.info = info
        self.election = election
        self.commonCode = commonCode
    }
    var body: some View {
        let width = geometry.size.width
        
        ScrollView {
            HStack {
                Spacer()
                if let url = info.posterImage {
                    URLImage(url) { image in
                        image
                            .resizable()
                            .frame(width: width / 2, height: width * 3/4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {

                    switch election {
                    case .presidential:
                        Text(commonCode.sgName)
                            .font(.headline)
                    case .assembly:
                        Text("\(commonCode.sgName)\n\(info.sd_name) \(info.sgg_name)\n국회의원")
                            .font(.headline)
                    case .governor:
                        Text("\(commonCode.sgName)\n\(info.sd_name)\n시·도지사선거")
                            .font(.headline)
                    case .mayor:
                        Text("\(commonCode.sgName)\n\(info.sd_name) \(info.sgg_name)\n구·시·군의장선거")
                            .font(.headline)
                    case .superintendent:
                        Text("\(commonCode.sgName)\n\(info.sd_name)\n교육감선거")
                            .font(.headline)
                    }
                    Text("기호 \(info.giho) 번")
                        .font(.title)
                    Text(info.party)
                        .font(.title2)
                    Text("\(info.name) (\(info.gender), \(info.age))")
                        .font(.title3)
                } // VStack
                Spacer()
            } // HStack
            
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                Text("<기본 정보>")
                    .font(.title2)
                Text("직업 : \(info.job)")
                Text("학력 : \(info.edu)")

                Divider()
                
                Text("<주요 경력>")
                    .font(.title2)
                Text("  - \(info.career1)")
                Text("  - \(info.career2)")

                
            }
            .padding([.horizontal], 20)
            
            PledgeTabView(election, commonCode, info)
            
        } // ScrollView
    }
}

struct SampleView: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            ScrollView {
                HStack {
                    Image("대통령")
                        .resizable()
                        .frame(width: width / 2, height: width * 3/4)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("기호 0 번")
                            .font(.title)
                        Text("00000딩")
                            .font(.title2)
                        Text("홍길동 (남, 69)")
                            .font(.title3)
                    } // VStack
                    Spacer()
                } // HStack
                
                VStack(alignment: .leading, spacing: 10) {
                    Rectangle().frame(height: 0)
                    Text("기본 정보")
                        .font(.title2)
                    Text("직업 : 정당인")
                    Text("학력 : 00대학교 00학과 졸업")
                    
                    Spacer()
                    
                    Text("주요 경력")
                        .font(.title2)
                    Text("  - (전) 더불어민주당 당대표")
                    Text("  - (전) 더불어민주당 당대표")

                }
                .padding()
                
                
            } // ScrollView
            
        }
    }
}

struct CandidateDetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
    }
}
