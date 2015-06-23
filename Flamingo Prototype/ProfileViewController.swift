//
//  ProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/4/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, UIAlertViewDelegate {

    var textFieldDict = Dictionary<UILabel, String>()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        let firstname = defaults.stringForKey("firstname")!
        let lastname = defaults.stringForKey("lastname")!
        nameLabel.text = "\(firstname) \(lastname)"
        
        textFieldDict.updateValue("email", forKey: emailLabel)
        textFieldDict.updateValue("username", forKey: userLabel)
        textFieldDict.updateValue("age", forKey: ageLabel)
        textFieldDict.updateValue("gender", forKey: genderLabel)
        
        for (key, value) in textFieldDict {
            key.text = defaults.stringForKey(value)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
