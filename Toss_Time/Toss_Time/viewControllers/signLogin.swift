//
//  signLogin.swift
//  Toss_Time
//
//  Created by Anton Kozintsev on 11/5/21.
//

import UIKit
import AVKit

class signLogin: UIViewController {
    
    var videoPlayer:AVPlayer?
    
    var videoPlayerLayer:AVPlayerLayer?
    
   
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    override func viewWillAppear(_ animated:Bool){
        //setUpVideo()
    }
    
    func setUpElements(){
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    
    func setUpVideo(){
        //Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "", ofType: "mp4")
        
        //can't find path to resource
        guard bundlePath != nil else{
            return
        }
        //Create a url from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        //Create the video player item
        let item = AVPlayerItem(url: url)
        
        //create the player
        videoPlayer = AVPlayer(playerItem:  item)
        
        //create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        
        //adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y:0, width: self.view.frame.width*4, height:self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        //add it to the view and play it
        videoPlayer?.playImmediately(atRate: 1.5)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
