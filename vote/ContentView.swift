//
//  ContentView.swift
//  vote
//
//  Created by 한법문 on 2021/12/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in

//            MyTabView(geometry)

            HomeView(geometry)

        } //GeometryReader
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
