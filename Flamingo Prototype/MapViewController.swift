//
//  MapViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/25/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: CustomKoynViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var directionsButton: UIButton!
    var urlScheme: String!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var chatButton: UIButton!
    var taggedFriends: Dictionary<String, UIImage>!
    
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var age: Int!
    var price: Int!
    var type: String!
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        UIApplication.sharedApplication().openURL(NSURL(string: marker.userData as! String)!)
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
    
    @IBAction func getDirectionsButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: urlScheme)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        mapView.delegate = self
        
        if NSClassFromString("NSOperatingSystemVersion") == nil {
            directionsButton.contentEdgeInsets.left = 10
            chatButton.contentEdgeInsets.right = 10
        }
        
        directionsButton.layer.cornerRadius = 5
        chatButton.layer.cornerRadius = 5
        directionsButton.contentEdgeInsets.right += 5
        chatButton.contentEdgeInsets.left += 5
        directionsButton.backgroundColor = UIColor(red: 60/255, green: 173/255, blue: 212/255, alpha: 1)
        chatButton.backgroundColor = UIColor(red: 60/255, green: 173/255, blue: 212/255, alpha: 1)

        //(UIDeviceRGBColorSpace 0.929412 0.917647 0.886275 1)
        
        if let username = defaults.stringForKey("username") {
            navigationItem.rightBarButtonItem = profileButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        if let parentVC = parentViewController as? TabBarController {
            lat = parentVC.lat
            long = parentVC.long
            locationName = parentVC.locationName
            city = parentVC.city
            chatButton.hidden = true
        }
        
        let query = (locationName + " " + city).stringByReplacingOccurrencesOfString(" ", withString: "+")
        urlScheme = setURLScheme(lat, destLong: long, query: query)
        
        let position = CLLocationCoordinate2DMake(lat, long)
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: long, zoom: 15)
        self.mapView.camera = camera
        let marker = GMSMarker(position: position)
        marker.snippet = "Get Directions"
        marker.userData = urlScheme
        marker.title = locationName
        marker.groundAnchor = CGPointMake(0.5, 0.5)
        marker.map = self.mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tabSegue" {
            let tabVC = segue.destinationViewController as! TabBarController
            tabVC.city = city
            tabVC.locationID = locationID
            tabVC.locationName = locationName
            tabVC.groupSize = groupSize
            tabVC.lat = lat
            tabVC.long = long
            tabVC.type = type
            tabVC.age = age
            tabVC.price = price
            tabVC.taggedFriends = taggedFriends
        }
        if segue.identifier == "chatSegue" {
            let chatVC = segue.destinationViewController as! MessagesTabBarControllerViewController
            chatVC.city = city
            chatVC.locationID = locationID
            chatVC.locationName = locationName
            chatVC.groupSize = groupSize
        }
    }
    

}
