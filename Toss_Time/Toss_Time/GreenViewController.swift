//
//  GreenViewController.swift
//  Toss_Time
//
//  Created by Anton on 11/1/21.
//

import UIKit

class GreenViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var field: UITextField!
    
    //var observer: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "vc") as! ViewController
        vc.completionHandler = { text in
            print("here")
            self.label.text = text
        }
        
//        observer = NotificationCenter.default.addObserver(forName: Notification.Name("notificationName"), object: nil, queue: .main, using: { notification in
//
//            guard let object = notification.object as? [String: UIColor] else{
//                return
//            }
//
//            guard let color = object["color"] else{
//                return
//            }
//
//            self.view.backgroundColor = color
//
//        })
    
    }
    
    @IBAction func didTapSave() {
        
        
        dismiss(animated: true, completion: nil)
    }

}
