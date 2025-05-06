//
//  ContentView.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        NavigationSplitView {
            List {
                Text("List")
            }
            .navigationBarBackButtonHidden(true)
            
            Text("Detail")
        } detail: {
            Text("Detail")
        }
    }


}

#Preview {
    ContentView()
}
