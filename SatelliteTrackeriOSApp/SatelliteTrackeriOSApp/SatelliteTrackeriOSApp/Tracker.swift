//
//  Tracker.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 5/2/22.

/*
 Citations:
 - Core Motion: https://developer.apple.com/documentation/coremotion/cmattitude
 - Core Location:
    - https://developer.apple.com/documentation/corelocation/cllocationmanager
    - https://developer.apple.com/videos/play/wwdc2019/705/
*/

import Foundation
import SwiftUI
import CoreMotion
import ZeitSatTrack

// Use Core motion to determine device's pitch, roll, and yaw values
class SatTracker {
    private static var cmm: CMMotionManager! = nil
    
    public static func test() -> Void {
        if (cmm == nil) {
            cmm = CMMotionManager()
            cmm.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        }
        
        // Test satellite framework by tapping on globe icon
        testSatellite()
        
        // Debugging: code prints to STDOUT / terminal when user
        //  taps Details (eye) icon in lower R
        //  taps the B&W globe icon next to satellite list
        if let attitude = cmm.deviceMotion?.attitude {
            let roll = attitude.roll
            let pitch = attitude.pitch
            let yaw = attitude.yaw
            print("Roll: ", roll, "Pitch: ", pitch, "Yaw: ", yaw)
        }
    }
    
    public static func testSatellite() -> Void {
        // Instantiate lib -> read from internal satellite dataset -> return arr of top-level Sat groups
        let satTracker = ZeitSatTrackManager.sharedInstance // WORKING
        
        // Loading a group / all components of X group (hundreds of satellite TLEs).
        // Each group can be enumerated to get a listing of the names of the TLE files in each group
        let satGroups = satTracker.satelliteCollections() // WORKING
        
        // Load satellite sub group
        let subGroups = satTracker.subGroupsForCollection(name:"Communications Satellites") // WORKING
        
        // Load satellite TLE (6 categories)
        //  Loading TLEs does NOT start tracking satellites
        //  It is loading sat' catalog + initial math so sat' can be tracked.
        //  ERROR -> UNSURE IF THIS IS PRODUCING A LIST OF SUBGROUPS ... LOADING FROM MAIN SEEMS TO PRODUCE NIL
        let commonInterestSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Common Interest")
        let weatherEarthResourcesSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Weather & Earth Resources Satellites")
        let communicationSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Communications Satellites")
        let navigationSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Navigation Satellites")
        let scientificSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Scientific Satellites")
        let miscSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Miscellaneous Satellites")
        
        // Set reference location - enable continuous location updates
        let status = satTracker.enableContinuousLocationUpdates()
        
        // Satellite update frequency, every 1 second
        satTracker.updateInterval = TimeInterval(1.0)
        
        // Dictionary containing info on all known satellites
        let allSatellitesDict = satTracker.locationsForSatellites() // WORKING
            print("\nAll available satellite dictionaries: \n")
            for satelliteDict in allSatellitesDict {
                print(satelliteDict)
            }
            
        // Look for single Amateur radio satellite
        let whereIsOSCAR7 = satTracker.locationForSatelliteNamed("OSCAR 7 (AO-7)")
        print("\nOSCAR 7 Tracking information: \n", whereIsOSCAR7)
        
     }
    

        
    

    
}
