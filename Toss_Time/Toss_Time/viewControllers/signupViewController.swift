//
//  signupViewController.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/5/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


/**
View cotroller class that:
 1. Displays a signup page
 2. signs a user up with FirebaseAuth
 This class is linked to the storyboard memeber of the same name
 */
class signupViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
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
    Function styles UI fields
     
     - Parameters:N/A
     
     - Returns:     None
     */
    func setUpElements(){
        
        //Hide the error label
        errorLabel.alpha = 0
        
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    
    
    /**
    Function checks the fields and validates their correctsness, returns a string that is NIL if everything is okay, or contains an error message
     
     - Parameters:N/A
     
     - Returns:     String
     */
    func validateFields() -> String? {
        //Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        
        //TODO: check that the email is not already in use
        
        //check if email is properly formatted
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(emailID: email) == false {
                    return "Please Enter a valid email address"
                }
        
        //check if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password is at least 8 characters, contains a special character, and a number"
        }
        
        return nil
    
    }
    
    /**
    Function checks if SignUpButton was tapped
     
     - Parameters:
        - sender:   anything that sends a signal to the button
     
     - Returns:     None
     */
    @IBAction func signUpTapped(_ sender: Any) {
        
        //validate fields
        let error = validateFields()
        
        if error != nil{
            //fields not valid
            showError(error!)
        }
        else{
            //create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil{
                    self.showError("Error Creating user")
                }
                
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data:["first_name":firstName,"last_name":lastName, "uid":result!.user.uid]) { (error) in
                    if error != nil{
                        self.showError("Error saving user data")
                    }
                }
                
                //Transition to the home screen
                self.transitionToHome()
                
    
            }
            
        }
    }
    
    /**
    Function transitions from the signup screen to the map view
     
     - Parameters:N/A
     
     - Returns:     None
     */
    func transitionToHome(){
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storboard.mapController) as? ViewController
        
        view.window?.rootViewController = mapViewController
        view.window?.makeKeyAndVisible()
    }
    
    /**
    Function shows error message in error label
     
     - Parameters:
        - messsage:   a string containing an error messageV
     
     - Returns:     None
     */
    func showError( _ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
}
