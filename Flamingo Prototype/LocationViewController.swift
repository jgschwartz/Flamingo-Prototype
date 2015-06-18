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
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    var type: String = ""
    var city: String!
    var locationName: String!
    let locationManager = CLLocationManager()
    var groupSize: Int!
    var age: Int!

    func getAllLocations(completion: (result: NSDictionary)->Void) -> Void{
        // just a GET request
        let url = NSURL(string: "\(homeURL)api/\(type)")
        var allLocations = NSArray()
        var location = NSDictionary()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("All Locations: \(json)")
            if(json != nil){
                allLocations = json as! NSArray
                location = self.chooseALocation(allLocations)
                completion(result: location)
            } else {
                completion(result: location)
            }
            
        }
        task.resume()
    }
    
    func chooseALocation(allLocations: NSArray) -> NSDictionary{
//        var possibles = [NSDictionary]()
//        var featured = [NSDictionary]()
//        for loc in allLocations {
//            let locCity = loc["city"] as! String
//            let ageMin = loc["ageMin"] as! Int
//            let ageMax = loc["ageMax"] as! Int
//            // TODO: make sure all ages are ints
//            // TODO: add groupsize, price
//            if(locCity == city && ageMin < age && ageMax > age) {
//                possibles.append(loc as! NSDictionary)
//                if(loc["featured"] as! String == "true") {
//                    featured.append(loc as! NSDictionary)
//                }
//            }
//        }
//        if(featured.count > 0){
//            return featured[0]
//        } else {
//            return possibles[0]
//        }
        return allLocations[1] as! NSDictionary
    }
    
    
    func setURLScheme(destLat: CLLocationDegrees, destLong: CLLocationDegrees, query: String) -> String {
        var urlScheme = ""
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            // user has google maps app installed
            urlScheme = "comgooglemaps-x-callback://?q=\(query)&daddr=\(destLat),\(destLong)&x-source=Flamingo&x-success=flamingo://"
        } else {
            // otherwise open with native Maps app
            urlScheme = "http://maps.apple.com/?q=\(query)&saddr=Current+Location&daddr=\(destLat),\(destLong)"
        }
        return urlScheme
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "messageSegue"){
            let messagesVC = segue.destinationViewController as! MessagesViewController
            messagesVC.locationName = self.locationName
            messagesVC.city = self.city
            messagesVC.groupSize = self.groupSize
            messagesVC.chatroom = (self.city + "-" + self.locationName).stringByReplacingOccurrencesOfString(" ", withString: "-")
        }
    }
    
}
