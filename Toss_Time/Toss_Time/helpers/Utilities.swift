//
//  Utilities.swift
//  customauth
//
//  Created by Christopher Ching on 2019-05-09, modified by Anton Kozintsev
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import Foundation
import UIKit


/**
This class contains helpful methods for styling UIElements, and also validating passwords and emails
 */
class Utilities {
    
    
    /**
    Function styles a text field
     
     - Parameters:
        - textfield     UITextField that needs to be styled
     
     - Returns:     None
     */
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    /**
    Function styles a label field
     
     - Parameters:
        - label     UILabel that needs to be styled
     
     - Returns:     None
     */
    static func styleLabel(_ label:UILabel){
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: label.frame.height - 2, width: label.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
                
        // Add the line to the text field
        label.layer.addSublayer(bottomLine)
        
    }
    
    /**
    Function styles a filled button
     
     - Parameters:
        - button     UIButton that needs to be styled
     
     - Returns:     None
     */
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    /**
    Function styles a hollow button
     
     - Parameters:
        - button     UIButton that needs to be styled
     
     - Returns:     None
     */
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    /**
    Function checks to see if a password is valid/strong enough
     
     - Parameters:
        - password     the users password
     
     - Returns:     Bool
     */
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    /**
    Function checks to see if an email is properly formatted
     
     - Parameters:
        - emailID     the users email as a string
     
     - Returns:     Bool
     */
    static func isValidEmail(emailID:String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: emailID)
        }
    
}
