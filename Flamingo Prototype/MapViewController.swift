//
//  MapViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/25/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        let parentVC = parentViewController as! TabBarController
        let lat = parentVC.lat
        let long = parentVC.long
        let query = (parentVC.locationName + " " + parentVC.city).stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        println("query: \(query)")
        
        let position = CLLocationCoordinate2DMake(lat, long)
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: long, zoom: 15)
        self.mapView.camera = camera
        let marker = GMSMarker(position: position)
        marker.snippet = "Get Directions"
        marker.userData = self.setURLScheme(lat, destLong: long, query: query)
        marker.title = parentVC.locationName
        marker.groundAnchor = CGPointMake(0.5, 0.5)
        marker.map = self.mapView
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
