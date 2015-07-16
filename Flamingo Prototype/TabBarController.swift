//
//  TabBarController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/24/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var type: String!
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var age: Int!
    var price: Int!
    var taggedFriends: Dictionary<String, UIImage>!
    var chatroom : String!
    var lat: Double!
    var long: Double!
    let sessionID = String(NSDate().hashValue)
    var tabBarVCs: [AnyObject]!
    var groupName: String!
    var groupArray = [String]()
    var tabBarArray: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSClassFromString("NSOperatingSystemVersion") == nil {
            tabBar.translucent = false
//            tabBar.alpha = 0.5
        }
        let locItem = tabBar.items?.first as! UITabBarItem
        locItem.title = type.capitalizedString
        
        tabBarArray = NSMutableArray(array: viewControllers!)
        if defaults.stringForKey("username") == nil {
            tabBarArray.removeObjectAtIndex(5) // remove reviews
        }
//            tabBarArray.removeObjectAtIndex(1) // remove friend tagging
//        } else if defaults.stringForKey("provider") == nil || defaults.stringForKey("provider") != "facebook"{
//            tabBarArray.removeObjectAtIndex(1) // remove friend tagging if not connected through facebook
//        }
        tabBarArray.removeObjectAtIndex(1) // should have already tagged friends; remove the option
        self.setViewControllers(tabBarArray as [AnyObject], animated: false)
        
        if taggedFriends == nil {
            taggedFriends = Dictionary<String, UIImage>()
        }
        
        var navStack = NSMutableArray()
        if let navController = navigationController {
            navStack.addObject(navController.viewControllers.first!)
            navStack.addObject(navController.viewControllers.last!)
            navigationController?.viewControllers = navStack as [AnyObject]
        }
        
//        if defaults.stringForKey("provider") != nil && defaults.stringForKey("provider") == "facebook" {
//            self.selectedIndex = 3
//        } else {
//            self.selectedIndex = 2
//        }
        self.selectedIndex = 2
    }
    
    // Remove form to submit reviews after user submits one review
    func submittedReview(review: NSDictionary){
        self.selectedIndex = 0
        tabBarArray.removeObjectAtIndex(tabBarArray.count-1)
        self.setViewControllers(tabBarArray as [AnyObject], animated: true)
        let barVC = tabBarArray.firstObject as! BarViewController
        barVC.addReview(review)
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
