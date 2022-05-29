//
//  SatelliteView.swift
//  SatelliteTrackeriOSApp
//
//  Created by En Kelly on 5/22/22.
//

import SwiftUI
import ARKit
import RealityKit
import ZeitSatTrack

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {

        // Create an ARKit view
        let view = ARView()
        
        // Start ARKit with a configuration that enables 3DOF tracking with heading information (aligned to true north)
        let session = view.session
        let config = AROrientationTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading

        session.run(config)
        // darken camera feed / reduce exposure so it's easier to see satellite models and names
        view.environment.background = .cameraFeed(exposureCompensation: -4.0)
        
        // addSatellites can only be called after location is available from CoreLocation
        // this may take a few seconds
        SatTracker.userLocation(whenLocationUpdated: { (location) in
            addSatellites(view: view, userLocation: location)
        })
        
        return view
    }
    
    // ------------------------------------------------------------------------------------------------
    // Convert latitude, longitude, and altitude coordinates into ARKit world coordinates
    private static func llaToLocalXYZ(satPosition: GeoCoordinates, from: (CLLocation, Double)) -> SIMD3<Float>? {
        // A satellite position needs to be converted to an azimuth/elevation coordinate given the user's
        // current location. The ZeitSatTrack framework provides this functionality via the EarthStation class.
        let station = EarthStation()
        station.coordinate = .init(latitude: from.0.coordinate.latitude, longitude: from.0.coordinate.longitude)
        station.altitude = from.1

        // convert lat/lon/alt to azimuth/elevation in degrees
        let localPos = station.lookAngleForSatelliteAt(satelliteCoordinates: satPosition)

        if localPos.elevation < -20 { //show satellites that are slightly below the horizon
            return nil
        }

        // convert from degrees to radians
        let azimuth = localPos.azimuth / 180.0 * Double.pi
        let elevation = localPos.elevation / 180.0 * Double.pi

        // ARKit coordinates define gravity as (0, -1, 0)
        // and heading (true north) as (0, 0, -1)
        // Convert azimuth/elevation into the ARKit coordinate system, as described above

        let z = -(cos(elevation) * cos(azimuth))
        let x = cos(elevation) * sin(azimuth)
        let y = sin(elevation)

        return SIMD3<Float>(Float(x), Float(y), Float(z))
    }
    
    @State private var satEntities: [String:(Entity, Entity)] = [:]
    @State private var lastUserLocation: (CLLocation, Double)?

    // ------------------------------------------------------------------------------------------------
    // Create RealityKit models for the visible satellites
    private func addSatellites(view: ARView, userLocation: (CLLocation, Double)) -> Void {

        // Get current satellite positions
        let satellites = SatTracker.satellitePositions()
        lastUserLocation = userLocation
        let satAnchor = AnchorEntity()
        view.scene.anchors.append(satAnchor)

        for sat in satellites {
            // convert satellite coordinates to XYZ coordinates
            guard let satPosition = RealityKitView.llaToLocalXYZ(satPosition: sat.1, from: userLocation) else
            {
                continue
            }
            
            // place each satellite 10 meters away from the camera
            // ARKit tracking is set to 3DOF so this is simply a way to scale
            // the models with a single constant
            let satPositionToRender = satPosition * 10

            // Load the satellite USDZ used to represent each satellite in the app
            let markerEntity = try! Entity.load(named: "Satellite")

            // set model position and orientation (lookAt) - making sure it's always facing the user
            markerEntity.position = satPositionToRender
            markerEntity.scale = .init(1, 1, 1)
            markerEntity.look(at: .zero, from: markerEntity.position, relativeTo: nil)
            
            // create a text entity with the satellite name
            let label = MeshResource.generateText(" " + sat.0, extrusionDepth: 0, alignment: .natural)
            let labelMaterial = UnlitMaterial(color: .white)
            let labelEntity = ModelEntity(mesh: label, materials: [labelMaterial])

            // set Satellite name text position and size
            labelEntity.position = satPositionToRender
            labelEntity.look(at: .zero, from: labelEntity.position, relativeTo: nil)
            labelEntity.scale = .init(-0.02, 0.02, 0.02)

            // add entities to a dictionary so they can be referenced by the method that
            // updates satellite positions every (1) second
            satEntities[sat.0] = (labelEntity, markerEntity)
            
            satAnchor.addChild(markerEntity)
            satAnchor.addChild(labelEntity)
        }
        
        // update satellite positions every (1) second
        continuouslyUpdateSatellitePositions()
    }

    // ------------------------------------------------------------------------------------------------
    private func continuouslyUpdateSatellitePositions() {
        // get current satellite positions (the ZeitSatTrack framework is configured to update positions every second)
        let satellites = SatTracker.satellitePositions()

        // update mesh positions and orientations based on current satellite positions similar to addSatellites() method.
        for sat in satellites {
            guard let satPosition = RealityKitView.llaToLocalXYZ(satPosition: sat.1, from: lastUserLocation!) else
            {
                continue
            }

            let satPositionToRender = satPosition * 10 // scale visuals!
            let entities = satEntities[sat.0]
            // ensure text is always billboarding i.e. facing the user
            entities!.0.position = satPositionToRender
            entities!.1.position = satPositionToRender
            entities!.0.look(at: .zero, from: satPositionToRender, relativeTo: nil)
            entities!.1.look(at: .zero, from: satPositionToRender, relativeTo: nil)
        }
        // run again, forever :)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            continuouslyUpdateSatellitePositions()
        }
    }
    func updateUIView(_ view: ARView, context: Context) {
    }
}

struct SatelliteView: View {
    var body: some View {
        RealityKitView()
    }
}

struct SatelliteView_Previews: PreviewProvider {
    static var previews: some View {
        SatelliteView()
    }
}
