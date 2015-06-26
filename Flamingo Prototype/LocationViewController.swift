//
//  LocationViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/17/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        

        

    }
    
    override func viewWillDisappear(animated: Bool) {
        if let parentVC = parentViewController as? TabBarController {
            
            println("locname: \(locationName), city: \(city), groupSize: \(groupSize)")
            
            parentVC.locationName = self.locationName
            parentVC.city = self.city
            parentVC.groupSize = self.groupSize
            parentVC.chatroom = (self.city + "-" + self.locationName).stringByReplacingOccurrencesOfString(" ", withString: "-")
        }
    }

    
}
