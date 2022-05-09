//
//  HomeView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/26/22.
//  Citations: https://www.youtube.com/watch?v=1AXyC24NCkE&t=6784s
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        // horizontal scrolling stack
        // link navigation card to detail page "view"
        NavigationView {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items) { item in
                            NavigationLink(destination:
                                DetailView()) {
                                CardView(item: item)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Explore the skies")
                
                // New addition to home page
                Text("Famous satellites")
                    .font(.subheadline).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                LazyVGrid (columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16){
                    ForEach(items) { item in
                        NavigationLink(destination:
                            DetailView()) {
                        SmallCardView(item: item)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
