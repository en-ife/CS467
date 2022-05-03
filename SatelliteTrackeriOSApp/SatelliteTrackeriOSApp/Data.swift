//
//  Data.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 4/27/22.
//

import SwiftUI

// CREATE DATA MODEL
struct Item: Identifiable {
    var id = UUID()
    var title: String
    var text: String
    var image: String
}

// SAMPLE DATA ARRAY
var items = [
    Item(title: "Satellite tracker", text: "A home guide to finding satellites in your area.", image: "person_on_rocket"),
    Item(title: "Adventures await", text: "Learning about our planet is an adventure.", image: "planet"),
    Item(title: "Have fun", text: "Explore our world from the palm of your hand.", image: "person_sitting"),
    Item(title: "Let's explore", text: "Point your phone towards the sky to begin.", image: "hand")
    ]

