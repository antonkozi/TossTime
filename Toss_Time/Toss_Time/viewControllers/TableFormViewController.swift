//
//  TableFormViewController.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/9/21.
//

import SwiftUI
import UIKit
import Photos
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class TableFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{
    
    @IBOutlet weak var TableOwnerTextField: UITextField!
    @IBOutlet weak var TableImage: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var houseRulesTextView: UITextView!
    @IBOutlet weak var ContactInfoTextField: UITextField!
    @IBOutlet weak var SubmitButtonTextField: UIButton!
    @IBOutlet weak var uploadImageFromLibraryButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var latitude = 0.0
    var longitude = 0.0
    var markerToLoad = ""
    var imagePickerController = UIImagePickerController()
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        setElements()
    }
    
    
    func setElements(){
        let db = Firestore.firestore()
        db.collection("Tables").document(markerToLoad).getDocument { (doc, err) in
                if let doc = doc, doc.exists {

                    let docData = doc.data()
                    let owner = docData!["owner"] as? String ?? ""
                    let houseRules = docData!["houseRules"] as? String ?? ""
                    let contactInfo = docData!["contactInfo"] as? String ?? ""

                    self.TableOwnerTextField.text = owner
                    self.houseRulesTextView.text = houseRules
                    self.ContactInfoTextField.text = contactInfo


                }
            else{
                print("Document does not exist")
            }
        }
    }
    
    func checkUser(){
        
    }
    
    func setCoordinates(coord: CLLocationCoordinate2D){
            latitude = coord.latitude
            longitude = coord.longitude
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .photoLibrary{
            checkPermissions()
            TableImage?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        else{
        TableImage?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        guard let imageData = TableImage.image?.pngData() else{
            return
        }
        
       
        
        storage.child("images/\(Auth.auth().currentUser!.uid).png").putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else{
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/\(Auth.auth().currentUser!.uid).png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else{
                    return
                }
                
                let db = Firestore.firestore()
                db.collection("Photos").document(Auth.auth().currentUser!.uid).setData(["id": Auth.auth().currentUser!.uid])
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                
                UserDefaults.standard.set(urlString, forKey: "url")
            })
            
            
        })
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkPermissions(){
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()})
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
        } else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("Access granted to use Photo Library")
        } else{
            print("We don't have access to your Photos")
        }
    }
    
    @IBAction func uploadImage(_ sender: Any){
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Go Back", style: .default, handler: { (alert: UIAlertAction!) in
            })

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Other action
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }
        
    }
    
    @IBAction func uploadImageFromLibrary(_ sender: Any){
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
   
    @IBAction func submitPressed(_ sender: Any) {
        //TODO: check everything is filled in
        
        let db = Firestore.firestore()
        
        db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["latitude": latitude, "longitude": longitude, "id": Auth.auth().currentUser!.uid, "owner": TableOwnerTextField.text!, "houseRules": houseRulesTextView.text!, "contactInfo" : ContactInfoTextField.text!])
        
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        self.view.window?.rootViewController = mapViewController
        withAnimation {
            self.view.window?.makeKeyAndVisible()
        }
        
    }
    
    
    @IBAction func editTapped(_ sender: Any) {
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        showActionSheet()
    }
    
    func showActionSheet(){
        
        let actionSheet = UIAlertController(title: "Delete Table", message: "Are you sure you want to delete this table?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel ", style: .default, handler: { action in
            print("Tapped Cancel")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            print("Tapped Delete")
            
            let coord = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            
            let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
            
            // mapview can delete the marker from map & database
            mapViewController?.remove_marker(coordinate: coord)
            
            self.transitionToHome()
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    func transitionToHome(){
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        
        view.window?.rootViewController = mapViewController
        view.window?.makeKeyAndVisible()
    }
    
}
