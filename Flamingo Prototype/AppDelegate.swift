//
//  AppDelegate.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/27/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import Security
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import GoogleMaps

let bgImageName = "KOYNBlueGradient.png"
let homeURL = "http://www.koyn.io/"
let defaults = NSUserDefaults.standardUserDefaults()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        defaults.removeObjectForKey("taggedFriends")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)

        UIButton.appearance().tintColor = self.window?.tintColor

        if let user = defaults.stringForKey("username") {
            
            
            
            var initialViewController = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            self.window?.rootViewController = storyboard.instantiateInitialViewController() as! UINavigationController
        }
        
        // Enable Google Maps API
        GMSServices.provideAPIKey("AIzaSyBTBZ81wJ1gn0OnIi7r8XVwK9PXVlFj7Bo")
        
        // Enable Facebook login
        FBSDKLoginButton.initialize()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

