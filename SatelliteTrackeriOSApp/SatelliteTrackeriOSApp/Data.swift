//
//  Data.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/27/22.
//

import SwiftUI

// CREATE DATA MODEL
struct Item: Identifiable {
    var id = UUID()         // create data structure, auto create ID
    var title: String       // ":" sets data type
    var text: String
    var image: String
}

// SAMPLE DATA ARRAY "items"
var items = [
    Item(title: "Satellite tracker", text: "A home guide to finding satellites in your area.", image: "person_on_rocket"),
    Item(title: "Use Satellite Tracker to", text: "further your knowledge of the skies.", image: "planet"),
    Item(title: "Let's explore", text: "Point your phone towards the sky to begin", image: "hand"),
]
