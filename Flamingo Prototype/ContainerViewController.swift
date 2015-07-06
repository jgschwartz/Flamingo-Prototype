//
//  ContainerViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/25/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = defaults.stringForKey("username") {
            navigationItem.rightBarButtonItem = profileButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "embedSegue"){
            if let messagesVC = segue.destinationViewController as? MessagesViewController {
                let parentVC = parentViewController as! TabBarController
                messagesVC.locationName = parentVC.locationName
                messagesVC.city = parentVC.city
                messagesVC.groupSize = parentVC.groupSize
                messagesVC.sessionID = parentVC.sessionID
//                messagesVC.chatroom = (self.city + "-" + self.locationName).stringByReplacingOccurrencesOfString(" ", withString: "-")
            }
        }
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
