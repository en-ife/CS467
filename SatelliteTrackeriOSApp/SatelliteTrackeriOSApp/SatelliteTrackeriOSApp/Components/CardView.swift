//
//  CardView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/25/22.
//

import SwiftUI
import CoreLocation

// CARD COMPONENT
struct CardView: View {
    // set var "item" to retrieve data in our Data view
    var item: Item = items[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //Image("person_on_rocket")
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:300)
                .frame(maxWidth: .infinity)
            //Text("Satellite tracker")
            Text(item.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .blendMode(.overlay)
            //Text("A home guide to finding satellites in your area.")
            Text(item.text)
                .opacity(0.7)
            //Text("Go HAM radio operators!")
                .opacity(0.7)
        }
        .foregroundColor(.white)
        .padding(.all)
        .frame(width: 350.0, height: 500.0)
        .background(LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .leading,
            endPoint: .trailing))
        .cornerRadius(30)
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
