//
//  MessagesTabBarControllerViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 7/7/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class MessagesTabBarControllerViewController: UITabBarController {

    var groupArray = [String]()
    var groupName: String!
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    let sessionID = String(NSDate().hashValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }


}
