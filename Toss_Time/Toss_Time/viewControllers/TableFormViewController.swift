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

class TableFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var TableOwnerTextField: UITextField!
    
    @IBOutlet weak var TableImage: UIImageView!
    
    @IBOutlet weak var uploadImageButton: UIButton!
    
    @IBOutlet weak var HouseRulesTextField: UITextField!
    
    @IBOutlet weak var ContactInfoTextField: UITextField!
    
    @IBOutlet weak var SubmitButtonTextField: UIButton!
    
    @IBOutlet weak var uploadImageFromLibraryButton: UIButton!
    
    
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self

        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func submitPressed(_ sender: Any) {
        //check everything is filled in
        
        let db = Firestore.firestore()
        
        db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["id": Auth.auth().currentUser!.uid, "owner": TableOwnerTextField.text!, "houseRules": HouseRulesTextField.text!, "contactInfo" : ContactInfoTextField.text!])
        
    }
    
}
