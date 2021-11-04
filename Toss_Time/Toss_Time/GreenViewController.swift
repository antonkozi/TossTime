//
//  GreenViewController.swift
//  Toss_Time
//
//  Created by Anton on 11/1/21.
//

import UIKit

class GreenViewController: UIViewController {
    
    var text:String = ""
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label?.text = text
    }
    
    @IBAction func didTapSave() {
        dismiss(animated: true, completion: nil)
    }
}
