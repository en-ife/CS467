//
//  HomeView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/26/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        // horizontal scrolling stack
        NavigationView {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0 ..< 5) { item in
                            // link navigation card to detail page "view"
                            NavigationLink(destination: DetailView()) {
                                CardView()
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Explore the skies")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
