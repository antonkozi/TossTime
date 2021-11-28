//
//  signLogin.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/5/21.
//

import UIKit
import AVKit

/**
View cotroller class that:
 1. Displays a page with login and sign in options
 2. takes the user to the appropriate view based on what button they pressed
 This class is linked to the storyboard memeber of the same name
 */
class signLogin: UIViewController {
    
    @IBOutlet weak var LogoImage: UIImageView!
   
    
   
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    /**
    Function styles buttons
     
     - Parameters: N/A
     
     - Returns:     None
     */
    func setUpElements(){
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }

}
