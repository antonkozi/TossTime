//
//  signLogin.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/5/21.
//

import UIKit
import AVKit

class signLogin: UIViewController {
    
    @IBOutlet weak var LogoImage: UIImageView!
   
    
   
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements(){
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }

}
