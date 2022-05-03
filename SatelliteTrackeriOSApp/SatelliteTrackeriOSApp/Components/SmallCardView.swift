//
//  SmallCardView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 5/2/22.
//

import SwiftUI

struct SmallCardView : View {
    var item: Item = items[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //Image("person_on_rocket")
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:99)
                .frame(maxWidth: .infinity)
            //Text("Satellite tracker")
            Text(item.title)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .blendMode(.overlay)
            //Text("A home guide to finding satellites in your area.")
            Text(item.text)
                .opacity(0.7)
        }
        .foregroundColor(.white)
        .padding(16)
        .frame(height: 222.0)
        .background(LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .leading,
            endPoint: .trailing))
        .cornerRadius(30)
    }
}

struct SmallCardView_Previews: PreviewProvider {
    static var previews: some View {
        SmallCardView()
    }
}

