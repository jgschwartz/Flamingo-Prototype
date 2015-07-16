//
//  ContainerViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/25/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ContainerViewController: CustomKoynViewController {
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    var parentVC: GroupTableViewController!
    var parentparent: TabBarController!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewMain: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
//        // ios 7 has issues with padding on the left and right
//        if NSClassFromString("NSOperatingSystemVersion") == nil {
//            containerViewMain.bounds = CGRectInset(containerViewMain.frame, -10.0, -10.0);
//        }
        
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
                messagesVC.parentVC = self
            }
        } else if segue.identifier == "groupEmbedSegue" {
                if let groupVC = segue.destinationViewController as? GroupMessagesViewController {
                    groupVC.locationName = parentparent.locationName
                    groupVC.city = parentparent.city
                    groupVC.groupSize = parentparent.groupSize
                    groupVC.sessionID = parentparent.sessionID
                    groupVC.parentVC = self
                    groupVC.groupOther = parentVC.groupOther
                    groupVC.groupSelf = parentparent.groupName
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
