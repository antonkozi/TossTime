//
//  GreenViewController.swift
//  Toss_Time
//
//  Created by Anton on 11/1/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GreenViewController: UIViewController {
    
    var text:String = ""
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var field: UITextField!
    
    
    @IBOutlet weak var TableOwnerTextField: UITextField!
    
    @IBOutlet weak var HouseRulesTextField: UITextField!
    
    @IBOutlet weak var ContactInfoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label?.text = text
        
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
                if let doc = doc, doc.exists {
                    
                    let docData = doc.data().map(String.init(describing:)) ?? "nil"
                    print("\(docData)")
                    
                }
            else{
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func didTapSave() {
        dismiss(animated: true, completion: nil)
    }
}
