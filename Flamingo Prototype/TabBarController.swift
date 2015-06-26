//
//  TabBarController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/24/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    var type: String = ""
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var age: Int!
    var price: Int!
    var taggedFriends = Dictionary<String, UIImage>()
    var chatroom : String!
    var lat: Double!
    var long: Double!
    let sessionID = String(NSDate().hashValue)
    var tabBarVCs: [AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locItem = tabBar.items?.first as! UITabBarItem
        locItem.title = type.capitalizedString
        
        var tabBarArray = NSMutableArray(array: viewControllers!)
        let user = defaults.stringForKey("username")
        println("username: \(user)")
        let provider = defaults.stringForKey("")
        println("provider: \(provider)")
        
        if defaults.stringForKey("username") == nil {
            tabBarArray.removeObjectAtIndex(2) // remove friend tagging
            tabBarArray.removeObjectAtIndex(1) //
        } else if defaults.stringForKey("provider") == nil || defaults.stringForKey("provider") != "facebook"{
            tabBarArray.removeObjectAtIndex(2) // remove friend tagging if not connected through facebook
        }
        self.setViewControllers(tabBarArray as [AnyObject], animated: false)
        taggedFriends = Dictionary<String, UIImage>()
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
