//
//  loginViewController.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/5/21.
//

import UIKit
import FirebaseAuth
import SwiftUI


/**
View cotroller class that:
 1. Displays a login page
 2. Logs a user in with FirebaseAuth
 This class is linked to the storyboard memeber of the same name
 */
class loginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
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
    Function styles buttons and labels
     
     - Parameters:N/A
     
     - Returns:     None
     */
    func setUpElements(){
        errorLabel.alpha = 0
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    /**
    Function logs user in and transitions to the map view
     
     - Parameters:
        - sender        Anything that sends a signal to the button
     
     - Returns:     None
     */
    @IBAction func loginTapped(_ sender: Any) {
        
        //validate Text Fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else{
                let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
                self.view.window?.rootViewController = mapViewController
                withAnimation {
                    self.view.window?.makeKeyAndVisible()
                }
                mapViewController?.go_to_current_location()
                
            }
        
        }
    }
}
