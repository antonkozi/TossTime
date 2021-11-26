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
import SwiftUI
//import FirebaseDatabase

var allMarkers = Array<GMSMarker>()
var toRemove = CLLocationCoordinate2D()

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var text:String = ""
    
    @IBOutlet weak var myMap: GMSMapView!
    @IBOutlet weak var logoutButton: UIButton!
    
    public var completionHandler: ((String?) -> Void)?
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        myMap.isMyLocationEnabled = true
        myMap.delegate = self
       
        let db = Firestore.firestore()
                
        // This bit of code here gets the lat & long of tables, and adds map markers for them
        db.collection("Tables").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let lat = data["latitude"]  as! CLLocationDegrees
                    let lon = data["longitude"] as! CLLocationDegrees
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    let id = data["id"]
                    
                    if ((lat == toRemove.latitude) && (lon == toRemove.longitude)) { continue }
                    self.add_marker(mapView: self.myMap, coordinate: coord, id: id as! String)
                }
            }
        }
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
            myMap.settings.zoomGestures=true
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
       
        print("license \n\n\(GMSServices.openSourceLicenseInfo())")
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        showLogoutSheet()
    }
    
    func showLogoutSheet(){
        
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel ", style: .default, handler: { action in
            print("Tapped Cancel")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { action in
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            self.transitionToLogout()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func transitionToLogout(){

        let loginView = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.loginController) as? signLogin
        self.view.window?.rootViewController = loginView
        withAnimation {
            self.view.window?.makeKeyAndVisible()
        }

    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let lat = coordinate.latitude
        let long = coordinate.longitude

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        marker.title = "Tap to View Table"
        marker.map = mapView
        marker.userData = Auth.auth().currentUser!.uid
        marker.tracksInfoWindowChanges = true
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableFormVC") as! TableFormViewController
                
        vc.setCoordinates(coord: marker.position)
        vc.markerToLoad = marker.userData as! String
        
        navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let camera = GMSCameraPosition(
            target: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0),
            zoom: 8,
            bearing: 0,
            viewingAngle: 0)
        myMap.animate(to: camera)
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
    
    func add_marker(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, id: String){
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = "Tap to View Table"
        marker.map = mapView
        marker.userData = id
        marker.tracksInfoWindowChanges = true
        allMarkers.append(marker)
    }
    
    func remove_marker(coordinate: CLLocationCoordinate2D) {
        // find the marker in the list and remove it from the map
        
        for marker in allMarkers {
            let lat = marker.position.latitude
            let lon = marker.position.longitude
            
            if ((lat == coordinate.latitude) && (lon == coordinate.longitude)) {
                marker.map = nil
                break
            }
        }
        
        let db = Firestore.firestore()
        db.collection("Tables").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let lat = data["latitude"]  as! CLLocationDegrees
                    let lon = data["longitude"] as! CLLocationDegrees
                    // let docID = data["id"] as! String
                    
                    if ((coordinate.latitude  == lat) && (coordinate.longitude == lon)) {
                        // if (mark.userData == docID) { }
                        toRemove = coordinate
                        document.reference.delete()
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
