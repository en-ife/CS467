//
//  DetailView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/25/22.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image("person_on_ball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height:300)
                    .frame(maxWidth: .infinity)
                Text("Satellite tracker")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .blendMode(.overlay)
                Text("A home guide to finding satellites in your area.")
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.all)
            //.frame(width: 350.0, height: 500.0)
            .background(LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .leading,
                endPoint: .trailing))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Let's get started.")
                    .font(.headline)
                Text("Point your phone towards the direction you'd like to explore.")
                    .font(.title).bold()
                Text("Then, pause movement of your phone. After a few seconds, Satellite Tracker will generate a list of satellites in your field of view.")
            }
            .padding()
        //.cornerRadius(30)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
