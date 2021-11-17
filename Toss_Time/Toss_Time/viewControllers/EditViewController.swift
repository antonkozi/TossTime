//
//  EditViewController.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/13/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditViewController: UIViewController {
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var TableOwnerTextField: UITextField!
    @IBOutlet weak var houseRulesTextField: UITextView!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let db = Firestore.firestore()
                //show user the current data
                db.collection("Tables").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
                        if let doc = doc, doc.exists {
        
                            let docData = doc.data()
                            let owner = docData!["owner"] as? String ?? ""
                            let houseRules = docData!["houseRules"] as? String ?? ""
                            let contactInfo = docData!["contactInfo"] as? String ?? ""
        
                            self.TableOwnerTextField.text = owner
                            self.houseRulesTextField.text = houseRules
                            self.contactInfoTextField.text = contactInfo
        
                        }
                    else{
                        print("Document does not exist")
                    }
                }

    }
    
    @IBAction func updateTablePressed(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("Tables").document(Auth.auth().currentUser!.uid).setData(["owner": TableOwnerTextField.text!, "houseRules": houseRulesTextField.text!, "contactInfo": contactInfoTextField.text!])
        transitonToTable()
    }
    
    func transitonToTable(){
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.tableController) as? GreenViewController
        
        view.window?.rootViewController = mapViewController
        view.window?.makeKeyAndVisible()
    }
    
}
