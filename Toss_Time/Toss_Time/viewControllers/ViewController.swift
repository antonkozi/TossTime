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
import FirebaseStorage

/** Global Variables
 - allMarkers       An array containing all marker objects on the map
 - toRemove       Used to hide a marker after deletion (accounts for database latency)
*/
var allMarkers = Array<GMSMarker>()
var toRemove = CLLocationCoordinate2D()
private let storage = Storage.storage().reference()


class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    // var text:String = ""         unnecessary?
    
    @IBOutlet weak var myMap: GMSMapView!
    @IBOutlet weak var tableList: UIButton!
    @IBOutlet weak var add_table: UIButton!
    @IBOutlet weak var current_location: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    public var completionHandler: ((String?) -> Void)?
    let locationManager = CLLocationManager()
    
    struct myLocationVar {
        static var CLL = CLLocation();
    }
    
    /**
     This function handles all of the necessary setup once the ViewController loads.
     Table data is loaded from the database, and coordinate pairs are created to instantiate markers with.      (setData function)
     A prompt is given to the user the request if they wish to use their current location with the app.
     Lastly, the license for Google Maps is printed to the console, for legal reasons.
     
     - Parameters:  None
     
     - Returns:     None
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        myMap.isMyLocationEnabled = true
        myMap.delegate = self
        
        setData()
       
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
            myMap.settings.zoomGestures=true
        }
        else{
            locationManager.requestWhenInUseAuthorization()
        }
        myLocationVar.CLL = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        print("license \n\n\(GMSServices.openSourceLicenseInfo())")
    }
    
    
    /**
     This function loads the table data from the Tables collection in Firestore
     Using this data, it creates markers on the map utilizing the 'add_marker(_)' function.
     
     - Parameters:  None
     
     - Returns:     None
     */
    func setData(){
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
    }
    
    
    /**
     Initializes a new marker on the map when the user presses & holds at a location.
     
     - Parameters:
        - coordinate:  The CLLocationCoordinate2D where the marker will be placed
     
     - Returns:     None
     */
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
    
    
    /**
     Transitions to a new view controller - TableFormViewController
     Refers to two members belonging to TableFormViewController:
     
        1. setCoordinates(  coord  )        A function that transfers marker's lat & long to global scope of TableFormViewController
        2. markerToLoad                         Global variable in TableFormViewController, set to the user ID of the user who created the marker
     
     - Parameters:
        - mapView:  The main GMSMapView
        - marker:   The GMSMarker containing the info window which was tapped
     
     - Returns:     None
     */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableFormVC") as! TableFormViewController
                
        vc.setCoordinates(coord: marker.position)
        vc.markerToLoad = marker.userData as! String
        
        navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
    
    }
    
    /**
     Function manages locations, doesnt actually do anything but the app crashes without it
     
     - Parameters:
        - manager:  Property that manages everything to do with locations
        - didUpdateLocations: racks whether location was updated
     
     - Returns:     None
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //this code takes you to your current location everytime the map is opened
//        let camera = GMSCameraPosition(
//            target: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0),
//            zoom: 17,
//            bearing: 0,
//            viewingAngle: 0)
//        myMap.animate(to: camera)
    }

    
    /**
     Function handles permissions to user location
     
     - Parameters:
        - manager:  Property that manages everything to do with locations
     
     - Returns:     None
     */
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
    
    
    /**
     This function adds a new GMSMarker object to the GMSMapView, given a coordinate and user ID string.
     
     - Parameters:
        - mapview               The GMSMapView which will have a marker placed on it
        - coordinate        The CLLocationCoordinate2D object where the new marker will be placed
        - id                          The user ID string which is associated with the marker's user
     
     - Returns:         None
     */
    func add_marker(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, id: String){
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = "Tap to View Table"
        marker.icon = UIImage(named: "tableMarker.png")
        marker.map = mapView
        marker.userData = id
        marker.tracksInfoWindowChanges = true
        allMarkers.append(marker)
    }
    
    
    /**
     This function removes a marker from:
     1. The global variable 'allMarkers'
     2. The GMSMapView
     3. The Firestore "Tables" collection
     
     - Parameters:
        - coordinate        The CLLocationCoordinate2D of the marker which is to be deleted
     
     - Returns:         None
     */
    func remove_marker(coordinate: CLLocationCoordinate2D) {
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
                    if ((coordinate.latitude  == lat) && (coordinate.longitude == lon)) {
                        toRemove = coordinate
                        document.reference.delete()
                    }
                }
            }
        }
        
        let imageRef = storage.child("images/\(Auth.auth().currentUser!.uid).png")

        // Delete the file
        imageRef.delete { error in
          if let error = error {
            print(error)
          } else {
            print("file deleted")
          }
        }
        
    }
    
    
    /**
     Error handling function - prints the error message to the console
     
     - Parameters:
        - manager       CLLocationManager
        - error           Error string
     
     - Returns:     None
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    /**
    Function which adds a marker at the current location - the functionality of the Add Table button
     
     - Parameters:
        - mapView       The GMSMapView which will have a marker placed on it
        - id                  The user ID string which is associated with the marker's user
     
     - Returns:     None
     */
    func add_marker_at_current_location(mapView: GMSMapView, id: String){
        let lat = mapView.myLocation?.coordinate.latitude
        let long = mapView.myLocation?.coordinate.longitude
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat ?? 0.0, longitude: long ?? 0.0)
        marker.icon = UIImage(named: "tableMarker.png")
        marker.title = "Tap to View Table"
        marker.map = mapView
        marker.userData = id
        marker.tracksInfoWindowChanges = true
    }
    
    
    /**
     Function which determines the user's current location and moves the map's camera position there
     
     - Parameters:
        - mapView       The GMSMapView which the camera can traverse
     
     - Returns:     None
     */
    func go_to_current_location(mapView: GMSMapView){
        let lat = mapView.myLocation?.coordinate.latitude
        let long = mapView.myLocation?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat ?? 0.0, longitude: long ?? 0.0, zoom: 17)
            mapView.animate(to: camera)
    }
    
    
    /**
     Function which prompts the user if they wish to log out - upon confirmation, they are logged out and transitioned to the login page.
     
     - Parameters:      None
     
     - Returns:         None
     */
    func logout() {
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
            
            let loginView = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.loginController) as? signLogin
            self.view.window?.rootViewController = loginView
            withAnimation {
                self.view.window?.makeKeyAndVisible()
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    
    /**
     This function activates when the user presses the Table List button at the bottom center of the screen.
     
     - Parameters:      None
     
     - Returns:         None
     */
    @IBAction func tableList(_ sender: Any) {
        let tables = storyboard?.instantiateViewController(withIdentifier: "tables_view") as! TableViewController
        navigationController?.pushViewController(tables, animated: true)
        present(tables, animated: true)
    }
    
    
    /**
     This function activates when the user presses the Add Table button at the bottom right of the screen.
     
     - Parameters:      None
     
     - Returns:         None
     */
    @IBAction func add_table(_ sender: Any) {
        go_to_current_location(mapView: myMap)
        add_marker_at_current_location(mapView: myMap, id: Auth.auth().currentUser!.uid)
    }
    
    
    /**
     This function activates when the user presses the Current Location button at the bottom left of the screen.
     
     - Parameters:      None
     
     - Returns:         None
     */
    @IBAction func current_location(_ sender: Any) {
        go_to_current_location(mapView: myMap)
    }
    
    
    /**
     This function activates when the user presses the Logout button at the top left of the screen.
     
     - Parameters:      None
     
     - Returns:         None
     */
    @IBAction func logoutTapped(_ sender: Any) {
        logout()
    }
    /**
    Function which brings Google Maps view to specific coordinates
     
     - Parameters:
        - latitude      latitude in Double to zoom to
        - longitude         longitude in Double to zoom to
     
     - Returns:     None
     */
    func goToLocation(latitude: Double, longitude: Double){
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17)
        myMap.animate(to: camera)
    }
}
