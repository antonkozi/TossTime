//
//  ViewController.swift
//  Toss_Time
//
//  Created by Anton on 10/27/21.
//

import CoreLocation
import GoogleMaps
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey("AIzaSyBXtU8FJoiP9w4tyLbUvZQ07oYJ7oc1pUQ")
        
        
        
        print("licenseL \n\n\(GMSServices.openSourceLicenseInfo())")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let coordinate = location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
    }
    
    


}

