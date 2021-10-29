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
    
    //@IBOutlet weak var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey("AIzaSyBXtU8FJoiP9w4tyLbUvZQ07oYJ7oc1pUQ")
        print("licenseL \n\n\(GMSServices.openSourceLicenseInfo())")
        //createMapView()
        //self.mapView.mapStyle(withFilename: "theme", andType: "json")
    }
    
    /* func createMapView(){
        let camera = GMSCameraPosition.camera(withLatitude: 36.9741, longitude: 122.0308, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
    } */
    
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


/* extension GMSMapView {
    func mapStyle (withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find darkMap")
            }
        }
        catch {
            NSLog("failded to load. \(error)")
        }
    }
} */
