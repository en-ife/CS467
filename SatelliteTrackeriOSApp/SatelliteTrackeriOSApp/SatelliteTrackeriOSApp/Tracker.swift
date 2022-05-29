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
    - https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
    - https://celestrak.com/NORAD/elements/gp.php?GROUP=amateur&FORMAT=tle // use to source latest amateur radio satellites
*/

import Foundation
import SwiftUI
import CoreMotion
import CoreLocation
import MapKit
import ZeitSatTrack
import UIKit
import UserNotifications
import ARKit

// ----------------------------------------------------------------------------------------------------
// API to find phone’s current location (lat, lon)
// Citation: https://www.hackingwithswift.com/read/22/2/requesting-location-core-location

class SatTracker : NSObject, CLLocationManagerDelegate {
    // ------------------------------------------------------------------------------------------------
    private static var instance: SatTracker! = nil
    
    public static func test() -> Void {
        if (instance == nil) {
            instance = SatTracker()
        }
        instance.runTest()
    }
    
    // ------------------------------------------------------------------------------------------------
    // GET USER'S LOCATION
    private var locationManager : CLLocationManager! = nil
    private var locationDelegate : ((CLLocation, Double)) -> Void =  { _ in }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
        print("\nYour current location is:\nLatitude: ", didUpdateLocations[0].coordinate.latitude, "\nLongitude: ", didUpdateLocations[0].coordinate.longitude)
        
        let userLocation = (CLLocation(latitude: didUpdateLocations[0].coordinate.latitude, longitude: didUpdateLocations[0].coordinate.longitude), didUpdateLocations[0].altitude)
        
        locationDelegate(userLocation)
        locationDelegate = { _ in }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error:: \(error.localizedDescription)")
       }
    
    // ------------------------------------------------------------------------------------------------
    // GET PITCH, ROLL, YAW
    private var cmm: CMMotionManager! = nil
    public func runTest() -> Void {
        if (cmm == nil) {
            cmm = CMMotionManager()
            cmm.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        }
        
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.requestLocation()
        
        // Test satellite by tapping on globe icon
        testSatellite()
        
        // Debugging: code prints to STDOUT / terminal when user taps Details (eye) icon
        if let attitude = cmm.deviceMotion?.attitude {
            let roll = attitude.roll
            let pitch = attitude.pitch
            let yaw = attitude.yaw
            print("Roll: ", roll, "Pitch: ", pitch, "Yaw: ", yaw)
        }
    }
    
    // ------------------------------------------------------------------------------------------------
    public static func satellitePositions() -> [(String, GeoCoordinates)]{
        if (instance == nil) {
            instance = SatTracker()
        }

        return instance.computeSatellitePositions()
    }
    // ------------------------------------------------------------------------------------------------
    public static func userLocation(whenLocationUpdated: @escaping ((CLLocation, Double)) -> Void) {
        if (instance == nil) {
            instance = SatTracker()
        }
        
        instance.getUserLocation(whenLocationUpdated: whenLocationUpdated)
    }
    // ------------------------------------------------------------------------------------------------
    private func getUserLocation(whenLocationUpdated: @escaping ((CLLocation, Double)) -> Void) {
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.requestLocation()
        locationDelegate = whenLocationUpdated
    }
    
    private var trackerInitialized = false
    // ------------------------------------------------------------------------------------------------
    private func computeSatellitePositions() -> [(String, GeoCoordinates)] {
        // Instantiate lib -> read internal satellite dataset -> return arr of top-level Satellite groups
        let satTracker = ZeitSatTrackManager.sharedInstance // WORKING

        if (!trackerInitialized) {
            
            // Loading a group / all components of X group (hundreds of satellite TLEs).
            // Each group can be enumerated to get a listing of the names of the TLE files in each group
            let satGroups = satTracker.satelliteCollections() // WORKING
            
            // Load satellite sub group
            let subGroups = satTracker.subGroupsForCollection(name:"Communications Satellites") // WORKING
            
            // Load satellite TLE (6 categories)
            //  Loading TLEs does NOT start tracking satellites / It is loading a satellite catalog + initial math so the satellite can be tracked.
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
            satTracker.updateInterval = TimeInterval(1.0) // WORKING

            trackerInitialized = true
        }
        // ------------------------------------------------------------------------------------------------
        // All amateur radio satellites in Celestrack database
        let amateurRadioSatellitesArray = ["CUBEBUG-2 (LO-74)", "CUBESAT XI-IV (CO-57)", "CUBESAT XI-V", "CUTE-1 (CO-55)", "CUTE-1.7+APD II (CO-65)", "DELFI-C3 (DO-64)", "DIWATA-2B", "DIY-1 (ARDUIQUBE)", "DUCHIFAT-1","DUCHIFAT-3","E-ST@R-II", "ES'HAIL 2","EYESAT A", "FALCONSA", "FOX-1CLIFF (AO-95)","FOX-1D (AO-92)","FUNCUBE-1 (AO-73)", "GOMX-1", "HUSKYSAT-1 (HO-107)", "ISS (ZARYA)", "ITAMSAT (IO-26)", "ITASAT 1", "ITUPSAT1", "JAISAT-1", "JAS-2 (FO-29)", "JUGNU", "JY1SAT (JO-97)", "KAITUO 1A", "KAITUO 1B", "KKS-1 (KISEKI)", "LAPAN-A2", "LILACSAT-2", "LUSAT (LO-19)", "M-CUBED & EXP-1 PRIME", "MAX VALI ER SAT", "MOZHAYET S4 (RS-22)", "NAYIF-1 (EO-88)", "NEXUS (FO-99)", "NUDT-PHO NESAT", "NUSAT-1 (FRESCO)", "ORBITAL FACTORY 2 (OF-2)", "OSCAR 7 (AO-7)", "PCSAT (NO-44)", "PHASE 3B (AO-10)", "PSAT2 (NO-104)", "QB50P1", "RADFXSAT (FOX-1B)", "RADFXSAT-2 (AO-109)", "RADIO RO STO (RS-15)", "RS-44 & BREEZE-KM R/B", "SALSAT", "SAUDISAT 1C (SO-50)", "SEEDS II (CO-66)", "SOMP", "SPROUT", "SRMSAT", "STRAND-1", "SWISSCUBE", "TECHSAT 1B (GO-32)", "TIANWANG 1A (TW-1A)", "UNISAT-6", "UOSAT 2", "UVSQ-SAT", "UWE-3", "UWE-4", "XIWANG-1 (HOPE-1)", "XW-2A", "XW-2B", "XW-2C", "XW-2D", "XW-2E", "XW-2F", "XW-3 (CAS-9)", "YUBILEINY (RS-30)", "ZACUBE-1 (TSHEPISOSAT)", "ZDPS 2A", "ZDPS 2B", "ZHUHAI-1 01 (CAS-4A)", "ZHUHAI-1 02 (CAS-4B)"]
        
        var satPositions : [(String, GeoCoordinates)] = []
        
        // return lat', long', altitude of amateur satellites relative to user position
        for amateurRadioSat in amateurRadioSatellitesArray {
            let satLoc = satTracker.locationForSatelliteNamed(amateurRadioSat)
            print(amateurRadioSat)

            if let satLoc = satLoc {
                print("Latitude: ", satLoc.latitude)
                print("Longitude: ", satLoc.longitude)
                print("Altitude: ", satLoc.altitude)
                print("\n")
                satPositions.append((amateurRadioSat, satLoc))
            }
        }
        return satPositions
    }
    
    
    // -----------------------------------------------------------------------------------------------
    // ZEIT SAT TRACKER - TEST LIBRARY
    public func testSatellite() -> Void {
        // Instantiate lib -> read internal satellite dataset -> return arr of top-level Satellite groups
        let satTracker = ZeitSatTrackManager.sharedInstance // WORKING
        
        // Loading a group / all components of X group (hundreds of satellite TLEs).
        // Each group can be enumerated to get a listing of the names of the TLE files in each group
        let satGroups = satTracker.satelliteCollections() // WORKING
        
        // Load satellite sub group
        let subGroups = satTracker.subGroupsForCollection(name:"Communications Satellites") // WORKING
        
        // Load satellite TLE (6 categories)
        //  Loading TLEs does NOT start tracking satellites / It is loading a satellite catalog + initial math so the satellite can be tracked.
        //  ERROR -> UNSURE IF THIS IS PRODUCING A LIST OF SUBGROUPS ... LOADING FROM MAIN SEEMS TO PRODUCE NIL
        let commonInterestSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Common Interest")
        let weatherEarthResourcesSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Weather & Earth Resources Satellites")
        let communicationSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Communications Satellites")
        let navigationSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Navigation Satellites")
        let scientificSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Scientific Satellites")
        let miscSatellites = satTracker.loadSatelliteSubGroup(subgroupName: "Amateur Radio", group: "Miscellaneous Satellites")
        
        // Set reference location - enable continuous location updates
        let status = satTracker.enableContinuousLocationUpdates()
        
        // ------------------------------------------------------------------------------------------------
        // Satellite update frequency, every 1 second
        satTracker.updateInterval = TimeInterval(1.0) // WORKING
        
        // Dictionary containing info on all known satellites
        let allSatellitesDict = satTracker.locationsForSatellites() // WORKING
            print("\nAll available satellite dictionaries: \n")
            for satelliteDict in allSatellitesDict {
                print(satelliteDict)
            }
        // ------------------------------------------------------------------------------------------------
        // look for single Amateur radio satellite
        let whereIsOSCAR7 = satTracker.locationForSatelliteNamed("OSCAR 7 (AO-7)") // WORKING
        print("\nOSCAR 7 Tracking information: \n", whereIsOSCAR7)
        
        let satLoc = satTracker.locationForSatelliteNamed("OSCAR 7 (AO-7)")
        print("\nNow tracking OSCAR 7")
        print("Latitude: ", satLoc?.latitude)
        print("Longitude: ", satLoc?.longitude)
        print("Altitude: ", satLoc?.altitude ,"\n")
        
        //  return dictionary of orbital parameters for vis' sat' path /locating sat' visually from the ground.
       // let orbitalInfo = satTracker.orbitalInfoForSatelliteNamed("OSCAR 7 (AO-7)", location:satLoc?.latitude, satLoc?.longitude))
        
        //print("Here is the orbital information for OSCAR-7: \n", orbitalInfo)
        
        // Display all Amateur Radio Satellites tracked by Celestrack - (found manually)
        print("Here are all amateur satellites tracked by Celestrack.\n")
        // all amateur radio satellites in Celestrack database
        let amateurRadioSatellitesArray = ["CUBEBUG-2 (LO-74)", "CUBESAT XI-IV (CO-57)", "CUBESAT XI-V", "CUTE-1 (CO-55)", "CUTE-1.7+APD II (CO-65)", "DELFI-C3 (DO-64)", "DIWATA-2B", "DIY-1 (ARDUIQUBE)", "DUCHIFAT-1","DUCHIFAT-3","E-ST@R-II", "ES'HAIL 2","EYESAT A", "FALCONSA", "FOX-1CLIFF (AO-95)","FOX-1D (AO-92)","FUNCUBE-1 (AO-73)", "GOMX-1", "HUSKYSAT-1 (HO-107)", "ISS (ZARYA)", "ITAMSAT (IO-26)", "ITASAT 1", "ITUPSAT1", "JAISAT-1", "JAS-2 (FO-29)", "JUGNU", "JY1SAT (JO-97)", "KAITUO 1A", "KAITUO 1B", "KKS-1 (KISEKI)", "LAPAN-A2", "LILACSAT-2", "LUSAT (LO-19)", "M-CUBED & EXP-1 PRIME", "MAX VALI ER SAT", "MOZHAYET S4 (RS-22)", "NAYIF-1 (EO-88)", "NEXUS (FO-99)", "NUDT-PHO NESAT", "NUSAT-1 (FRESCO)", "ORBITAL FACTORY 2 (OF-2)", "OSCAR 7 (AO-7)", "PCSAT (NO-44)", "PHASE 3B (AO-10)", "PSAT2 (NO-104)", "QB50P1", "RADFXSAT (FOX-1B)", "RADFXSAT-2 (AO-109)", "RADIO RO STO (RS-15)", "RS-44 & BREEZE-KM R/B", "SALSAT", "SAUDISAT 1C (SO-50)", "SEEDS II (CO-66)", "SOMP", "SPROUT", "SRMSAT", "STRAND-1", "SWISSCUBE", "TECHSAT 1B (GO-32)", "TIANWANG 1A (TW-1A)", "UNISAT-6", "UOSAT 2", "UVSQ-SAT", "UWE-3", "UWE-4", "XIWANG-1 (HOPE-1)", "XW-2A", "XW-2B", "XW-2C", "XW-2D", "XW-2E", "XW-2F", "XW-3 (CAS-9)", "YUBILEINY (RS-30)", "ZACUBE-1 (TSHEPISOSAT)", "ZDPS 2A", "ZDPS 2B", "ZHUHAI-1 01 (CAS-4A)", "ZHUHAI-1 02 (CAS-4B)"]
        // ------------------------------------------------------------------------------------------------
        // return lat', long', altitude of amateur satellites relative to user position
        for amateurRadioSat in amateurRadioSatellitesArray {
            let satLoc = satTracker.locationForSatelliteNamed(amateurRadioSat)
            print(amateurRadioSat)
            print("Latitude: ", satLoc?.latitude)
            print("Longitude: ", satLoc?.longitude)
            print("Altitude: ", satLoc?.altitude)
            print("\n")
        }
     }
}
