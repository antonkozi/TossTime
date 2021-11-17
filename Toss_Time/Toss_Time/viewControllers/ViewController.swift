//
//  ViewController.swift
//  Toss_Time
//
//  Created by Anton on 10/27/21.
//

import CoreLocation
import GoogleMaps
import UIKit
import Firebase
import FirebaseAuth
//import FirebaseDatabase

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var text:String = ""
    
    @IBOutlet weak var myMap: GMSMapView!
    
    public var completionHandler: ((String?) -> Void)?
    
    
    
    let locationManager = CLLocationManager()
    //var tables: [GMSMarker] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Utilities.styleHollowButton(myTableButton)
        
        
        
        locationManager.delegate = self
        myMap.delegate = self
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
            myMap.settings.zoomGestures=true
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
       
        //print("licenseL \n\n\(GMSServices.openSourceLicenseInfo())")
    }
    
   
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let lat = coordinate.latitude
        let long = coordinate.longitude

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        marker.title = "Tap to View Table"
        marker.map = mapView
        marker.tracksInfoWindowChanges = true
    }
    
    //TODO: Way to delete marker
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "green_vc") as! GreenViewController
        
       // vc.text = marker.title ?? "Not a valid marker"
        navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
    
    }
    
    //TODO: Custom Info window
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myMap.camera = GMSCameraPosition(
            target: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0),
            zoom: 8,
            bearing: 0,
            viewingAngle: 0)
    
       
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.latitude ?? 0.0)
        marker.title = "hi"
        marker.snippet = "hello"
        marker.map = myMap

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways:
            return
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
