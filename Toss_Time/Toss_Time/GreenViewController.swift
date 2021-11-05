//
//  GreenViewController.swift
//  Toss_Time
//
//  Created by Anton on 11/1/21.
//

import UIKit

class GreenViewController: UIViewController {
    
    var text:String = ""
    @IBOutlet weak var TablePicture: UIImageView!
    @IBOutlet weak var Edit: roundButton!
    @IBOutlet weak var Rules: UILabel!
    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var Table: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Curve the edges
        Table.layer.cornerRadius = 7
        
        Rules.layer.cornerRadius = 7
        TablePicture.layer.cornerRadius = 7
        
        //Set Table name to value from marker
        Table?.text = text
    }
    
    @IBAction func didTapSave() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapEdit() {
        dismiss(animated: true, completion: nil)
    }
    
    class roundButton: UIButton{
        override func didMoveToWindow() {
            self.backgroundColor = UIColor.red
            self.layer.cornerRadius = self.frame.height/2
        }
    }
}
