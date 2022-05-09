//
//  ContentView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/24/22.
//

import SwiftUI


// HOME PAGE
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    // set home button with icon
                    Image(systemName: "house")
                    Text("Home")
                }
            ListView()
                .tabItem{
                    Image(systemName: "eyes.inverse")
                    Text("Details")
                }
        }
    }
}



// UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

