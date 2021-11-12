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
import FirebaseDatabase

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var text:String = ""
    
    @IBOutlet weak var myMap: GMSMapView!
    
    public var completionHandler: ((String?) -> Void)?
    
    //@ObservedObject private var viewModel = TablesViewModel()
    
    func add_marker(mapView: GMSMapView, coordinate: CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = "fsdafadsfasdfasd"
        marker.snippet = "Add a post"
        marker.map = mapView
        marker.tracksInfoWindowChanges = true
    }
    
    let locationManager = CLLocationManager()
    //var tables: [GMSMarker] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        //This bit of code here gives the tables and prints them to the console log
        db.collection("Tables").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let coord = CLLocationCoordinate2DMake(data["latitude"]  as! CLLocationDegrees,                                          data["longitude"] as! CLLocationDegrees)
                    
                    self.add_marker(mapView: self.myMap, coordinate: coord)
                }
            }
        }
        
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
        add_marker(mapView: mapView, coordinate: coordinate)
    }
    
    //TODO: Way to delete marker
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableFormVC") as! TableFormViewController
        
        vc.setCoordinates(coord: marker.position)
        
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
