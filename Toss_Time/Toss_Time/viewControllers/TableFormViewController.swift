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


/**
View cotroller class that:
 1. Displays table form
 2. Allows user to fill out table form
 3. Allows user to delete, edit, and post their table
 4. Allows user to upload an optional image of their table
 5.  Allows other users to view but not edit table or delete table form
 This class is linked to the storyboard memeber of the same name
 */
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
        //set the fields of the table
        setElements()
    
    }
    
    /**
    Function dismisses keyboard when tapping outside the keyboard
     
     - Parameters:
        - touches       UITouch library that tracks user touch
        - event            UIEvent that tracks events
     
     - Returns:     None
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /**
    Function set's up all the elements of the table by pulling the information from firebase, extracting it into a string format,
     and then setting the labels, images, and text fields to their appropriate values. In addition, if the current user is not the
     author then all th buttons are disabled
     
     - Parameters: N/A
     
     - Returns:     None
     */
    func setElements(){
        //create database instance and retrieve table info for the marker that was clicked on
        let db = Firestore.firestore()
        db.collection("Tables").document(markerToLoad).getDocument { (doc, err) in
                if let doc = doc, doc.exists {
                    
                    //set up database entries as strings
                    let docData = doc.data()
                    let owner = docData!["owner"] as? String ?? ""
                    let houseRules = docData!["houseRules"] as? String ?? ""
                    let contactInfo = docData!["contactInfo"] as? String ?? ""
                    let id = docData!["id"] as? String ?? ""
                    print("id is \(id)")
                    
                    
                    //set table image
                    let photoRef = self.storage.child("images/\(id).png")
                    photoRef.getData(maxSize: 1024*1024*1024) { Data, Error in
                        if let Error = Error{
                            print("could not load image \(Error)")
                        }
                        else{
                            let tablePhoto = UIImage(data: Data!)
                            self.TableImage.image = tablePhoto
                        }
                    }

                    //set text fields
                    self.TableOwnerTextField.text = owner
                    self.houseRulesTextView.text = houseRules
                    self.ContactInfoTextField.text = contactInfo
                    
                    //upon viewing of a table, don't allow user to edit
                    self.TableOwnerTextField.isUserInteractionEnabled = false
                    self.ContactInfoTextField.isUserInteractionEnabled = false
                    self.houseRulesTextView.isUserInteractionEnabled = false
                    
                    //If the table does not belong to the current user, dont allow the to change anything
                    if self.isAuthor(id: id) == false{
                        self.deleteButton.isUserInteractionEnabled = false
                        self.editButton.isUserInteractionEnabled = false
                        self.SubmitButtonTextField.isUserInteractionEnabled = false
                        self.uploadImageButton.isUserInteractionEnabled = false
                        self.uploadImageFromLibraryButton.isUserInteractionEnabled = false
                        self.SubmitButtonTextField.alpha = 0
                        self.editButton.alpha = 0
                        self.deleteButton.alpha = 0
                        self.uploadImageButton.alpha = 0
                        self.uploadImageFromLibraryButton.alpha = 0
                        
                    }
                    
                }
            else{
                print("Document does not exist")
            }
        }
        
       
        
    }
    
    /**
    Returns true if the person who is viewing the table is also the table owner
     
     - Parameters:
        - id                  The current users id
     
     - Returns:     Boolean
     */
    func isAuthor(id: String) -> Bool{
        if Auth.auth().currentUser!.uid == id{
            return true
        }
        return false
        
    }
    
    /**
    Function sets table coordinates, not actually visable to the user but needed for data retrieval
     
     - Parameters:
        - coord              coordinates of the table
     
     - Returns:     None
     */
    func setCoordinates(coord: CLLocationCoordinate2D){
            latitude = coord.latitude
            longitude = coord.longitude
        }
    
    /**
    Function sets table coordinates, not actually visable to the user but needed for data retrieval
     
     - Parameters:
        - picker         allows photo picking in user library
        - info             infoKey of image
     
     - Returns:     None
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker.sourceType == .photoLibrary{
            //make sure app has permission to access photo library
            checkPermissions()
            TableImage?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        else{
        TableImage?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        guard let imageData = TableImage.image?.pngData() else{
            return
        }
        
       
        //store image in the firebase path "images/\(Auth.auth().currentUser!.uid"
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
    
    /**
    Function checks if photo library access was given
     
     - Parameters: N/A
     
     - Returns:     None
     */
    func checkPermissions(){
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()})
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
        } else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    /**
    Function handles authorization status
     
     - Parameters:
        - Status               photo authorization status
     
     - Returns:     None
     */
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("Access granted to use Photo Library")
        } else{
            print("We don't have access to your Photos")
        }
    }
    
    /**
    Function uploads image from camera
     
     - Parameters:
        - Sender               whatever is transmitting
     
     - Returns:     None
     */
    @IBAction func uploadImage(_ sender: Any){
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            //check if user has camera with alert controller
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            //go back to table page
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
    
    /**
    Function the validates if everything minus the photo is filled in
     
     - Parameters: N/A
     
     - Returns:    String with error message
     */
    func validateFields() -> String? {
        //Check that all fields are filled in
        if TableOwnerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || ContactInfoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || houseRulesTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        return nil
    
    }
    
    /**
    Function uploads image from photo library
     
     - Parameters:
        - Sender        whatever is transmitting
     
     - Returns:     None
     */
    @IBAction func uploadImageFromLibrary(_ sender: Any){
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    /**
    Function submits table to firebase if all the fields are filled out, and returns user to the map
     
     - Parameters:
        - Sender         whatever is transmitting
     
     - Returns:     None
     */
    @IBAction func submitPressed(_ sender: Any) {
        //TODO: check everything is filled in
        let error = validateFields()
        if error == nil{
            //create firestore refrence
            let db = Firestore.firestore()
            
            //create new document with all the information from the user
            db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["latitude": latitude, "longitude": longitude, "id": Auth.auth().currentUser!.uid, "owner": TableOwnerTextField.text!, "houseRules": houseRulesTextView.text!, "contactInfo" : ContactInfoTextField.text!])
            
            self.TableOwnerTextField.isUserInteractionEnabled = false
            self.houseRulesTextView.isUserInteractionEnabled = false
            self.ContactInfoTextField.isUserInteractionEnabled = false
            
            let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
            self.view.window?.rootViewController = mapViewController
            withAnimation {
                self.view.window?.makeKeyAndVisible()
            }
        }
        else{
            //show user message saying not all fields are filled in
            showInvalidActionSheet()
        }
            
    
        
    }
    
    /**
    Function enables editing of fields
     
     - Parameters:
        - Sender         whatever is transmitting
     
     - Returns:     None
     */
    @IBAction func editTapped(_ sender: Any) {
        TableOwnerTextField.isUserInteractionEnabled = true
        ContactInfoTextField.isUserInteractionEnabled = true
        houseRulesTextView.isUserInteractionEnabled = true
        
    }
    
    /**
    Function displays action sheet with options if user wants to delete
     
     - Parameters:
        - Sender         whatever is transmitting
     
     - Returns:     None
     */
    @IBAction func deleteTapped(_ sender: Any) {
        showDeleteActionSheet()
    }
    
    /**
    Function displays action sheet for deleting a table
     
     - Parameters:N/A
     
     - Returns:     None
     */
    func showDeleteActionSheet(){
        
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
        
        //show action sheet
        present(actionSheet, animated: true)
    }
    
    /**
    Function displays action sheet if user does not fill out the table properly
     
     - Parameters:
        - Sender         whatever is transmitting
     
     - Returns:     None
     */
    func showInvalidActionSheet(){
        
        let actionSheet = UIAlertController(title: "Some fields are missing", message: "Please fill in all fields, or go back to the map", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Back to Table", style: .default, handler: { action in
            print("Tapped Back to Table")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Back To Map", style: .destructive, handler: { action in
            print("Tapped Back To Map")
            
            //take user back to map
            self.transitionToHome()
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    /**
    Function takes user back to map screen
     
     - Parameters:N/A
     
     - Returns:     None
     */
    func transitionToHome(){
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        view.window?.rootViewController = mapViewController
        mapViewController?.go_to_current_location()
        view.window?.makeKeyAndVisible()
    }
    
}
