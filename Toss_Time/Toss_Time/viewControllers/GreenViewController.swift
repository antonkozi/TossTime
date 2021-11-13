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


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableImage.contentMode = .scaleAspectFit
        
        
        
        let db = Firestore.firestore()
        
//        db.collection("Tables").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
//                if let doc = doc, doc.exists {
//
//                    let docData = doc.data()
//                    let owner = docData!["owner"] as? String ?? ""
//                    let houseRules = docData!["houseRules"] as? String ?? ""
//                    let contactInfo = docData!["contactInfo"] as? String ?? ""
//
//                    self.tableOwnerLabel.text = owner
//                    self.rulesLabel.text = houseRules
//                    self.contactInfoLabel.text = contactInfo
//                    print("HERE")
//                    print(owner)
//                    print(houseRules)
//                    print(contactInfo)
//
//                    Utilities.styleLabel(self.tableOwnerLabel)
//                    Utilities.styleLabel(self.rulesLabel)
//                    Utilities.styleLabel(self.contactInfoLabel)
//
//                }
//            else{
//                print("Document does not exist")
//            }
//        }
        
        
        
  
       
        
        
    }
}
