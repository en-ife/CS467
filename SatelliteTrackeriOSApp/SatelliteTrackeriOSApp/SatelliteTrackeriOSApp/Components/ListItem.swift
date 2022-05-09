//
//  ListItem.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/26/22.
//

import SwiftUI

struct ListItem: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "globe.americas.fill")
                // make original color
                .renderingMode(.original)
                .font(.body)
                // set frame
                .frame(width:36, height:36)
                .foregroundColor(.gray)
                .background(Color.black)
                // make icon circular
                .mask(Circle())
                .onTapGesture {
                    SatTracker.test()
                }
            VStack(alignment: .leading, spacing: 4.0) {
                Text("Satellite __")
                Text("Uplink: __ ")
                Text("Downlink: __")
            }
        }
        .padding(.vertical)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem()
    }
}
