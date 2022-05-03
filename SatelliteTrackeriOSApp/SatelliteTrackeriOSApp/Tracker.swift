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

// Use Core motion to determine device's pitch, roll, and yaw values
class SatTracker {
    private static var cmm: CMMotionManager! = nil
    
    public static func test() -> Void {
        if (cmm == nil) {
            cmm = CMMotionManager()
            cmm.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        }
        
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
}
