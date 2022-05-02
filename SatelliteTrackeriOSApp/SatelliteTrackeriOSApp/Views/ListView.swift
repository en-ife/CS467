//
//  ListView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/26/22.
//

import SwiftUI

struct ListView: View {
    // set state = default, do not show modal
    @State var show = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                    // call ListItem component
                    ListItem()
                        // set sheet 
                        .sheet(isPresented: $show, content: {
                            DetailView()
                        })
                        // set event
                        .onTapGesture {
                            // switch between true or false.. by default do not show modal
                            // on tap, present detailed view
                            show.toggle()
                        }
                }
            }
            .navigationTitle("Satellites near you")
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
