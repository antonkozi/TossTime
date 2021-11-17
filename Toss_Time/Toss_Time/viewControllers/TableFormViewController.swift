//
//  TableFormViewController.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/9/21.
//

import UIKit
import Photos
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class TableFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var latitude = 0.0
    var longitude = 0.0
    

    @IBOutlet weak var TableOwnerTextField: UITextField!
    
    @IBOutlet weak var TableImage: UIImageView!
    
    @IBOutlet weak var uploadImageButton: UIButton!
    
    @IBOutlet weak var houseRulesTextView: UITextView!
    
    
    @IBOutlet weak var ContactInfoTextField: UITextField!
    
    @IBOutlet weak var SubmitButtonTextField: UIButton!
    
    @IBOutlet weak var uploadImageFromLibraryButton: UIButton!
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var imagePickerController = UIImagePickerController()
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        

        // Do any additional setup after loading the view.
    }
    
    func setCoordinates(coord: CLLocationCoordinate2D){
        latitude = coord.latitude
        longitude = coord.longitude
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
    


    @IBAction func submitPressed(_ sender: Any) {
        //check everything is filled in
        
        let db = Firestore.firestore()
        
        db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["id": Auth.auth().currentUser!.uid, "owner": TableOwnerTextField.text!, "houseRules": houseRulesTextView.text!, "contactInfo" : ContactInfoTextField.text!])
        

        db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["latitude": latitude, "longitude": longitude, "id": Auth.auth().currentUser!.uid, "owner": TableOwnerTextField.text!, "houseRules": houseRulesTextView.text!, "contactInfo" : ContactInfoTextField.text!])

    }
    
}
