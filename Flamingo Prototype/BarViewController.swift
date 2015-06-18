//
//  BarViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/10/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class BarViewController: LocationViewController, GMSMapViewDelegate {

    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var barHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var chatButton: UIButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        UIApplication.sharedApplication().openURL(NSURL(string: marker.userData as! String)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.type = "bars"
        
        mapView.delegate = self
        
        // set up activity indicator to be gray and fill screen
        activityIndicator.frame = self.view.frame
        activityIndicator.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.30).CGColor
        activityIndicator.opaque = false
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        getAllLocations({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    // Algorithm failed, no connection, etc
                    self.navigationItem.title = "Error"
                    self.barHeader.text = "Your search returned no results."
                    self.barHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                } else {
                    self.locationName = result["name"] as! String
                    println(self.city)
                    let address = (result["address"] as! String) + ", " + self.city
                    let query = (self.locationName + " " + self.city).stringByReplacingOccurrencesOfString(" ", withString: "+")
                    println("ADDRESS: \(address)")
                    
                    // Look up address and set map position
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            let newLat = placemark.location.coordinate.latitude
                            let newLong = placemark.location.coordinate.longitude
                            println("LAT: \(newLat), LONG: \(newLong)")
                            let position = CLLocationCoordinate2DMake(newLat, newLong)
                            let camera = GMSCameraPosition.cameraWithLatitude(newLat, longitude: newLong, zoom: 15)
                            self.mapView.camera = camera
                            let marker = GMSMarker(position: position)

                            marker.snippet = "Get Directions"
                            marker.userData = self.setURLScheme(newLat, destLong: newLong, query: query)
                            
                            
                            marker.title = self.locationName
                            marker.groundAnchor = CGPointMake(0.5, 0.5)
                            marker.map = self.mapView
                        }
                    })
                    
                    // Set text for bar result
                    println("We're going to \(self.locationName)!")
                    self.barHeader.text = self.locationName
                    self.barHeader.hidden = false
                    self.chatButton.hidden = false
                    
                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        // Set link to profile page if user is logged in
        if let user = defaults.stringForKey("username") {
            navigationItem.rightBarButtonItem = profileButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
