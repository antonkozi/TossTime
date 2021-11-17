//
//  GreenViewController.swift
//  Toss_Time
//
//  Created by Anton on 11/1/21.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class GreenViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var houseRulesTextView: UITextView!
    @IBOutlet weak var contactInfoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableImage.contentMode = .scaleAspectFit
        
        
        
        let db = Firestore.firestore()
        db.collection("Tables").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
                if let doc = doc, doc.exists {

                    let docData = doc.data()
                    let owner = docData!["owner"] as? String ?? ""
                    let houseRules = docData!["houseRules"] as? String ?? ""
                    let contactInfo = docData!["contactInfo"] as? String ?? ""

                    self.ownerLabel.text = owner
                    self.houseRulesTextView.text = houseRules
                    self.contactInfoLabel.text = contactInfo


                }
            else{
                print("Document does not exist")
            }
        }
        
        
        
  
       
        
        
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        transitionToEdit()
        
    }
    
    @IBAction func didTapMap(_ sender: Any) {
        transitionToHome()
    }
    
        
    func showActionSheet(){
        
        let actionSheet = UIAlertController(title: "Delete Table", message: "Are you sure you want to delete this table?", preferredStyle: .alert)
        
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel ", style: .default, handler: { action in
            print("Tapped Cancel")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            print("Tapped Delete")
            //delete info from the database
            //mapview should delete the marker 
            self.transitionToHome()
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    
    func transitionToHome(){
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        
        view.window?.rootViewController = mapViewController
        view.window?.makeKeyAndVisible()
    }
    
    func transitionToEdit(){
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.editController) as? EditViewController
        
        view.window?.rootViewController = mapViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    
    
    
}
