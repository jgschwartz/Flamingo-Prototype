//
//  BarViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/10/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import MapKit

class BarViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var barHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let regionRadius: CLLocationDistance = 1000
    
    func getAllBars(completion: (result: NSDictionary)->Void) -> Void{
        // just a GET request
        let url = NSURL(string: "\(homeURL)api/bars")
        var allBars = NSArray()
        var bar = NSDictionary()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("All Bars: \(json)")
            if(json != nil){
                allBars = json as! NSArray
                bar = self.chooseABar(allBars)
                completion(result: bar)
            } else {
                completion(result: bar)
            }

        }
        task.resume()
    }
    
    func chooseABar(allBars: NSArray) -> NSDictionary{
        return allBars[1] as! NSDictionary
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedAlways, CLAuthorizationStatus.AuthorizedWhenInUse:
            manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
//            centerMapOnLocation(mapView.userLocation.location)
        default: break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        centerMapOnLocation(location)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self

        
        // set up activity indicator to be gray and fill screen
        activityIndicator.frame = self.view.frame
        activityIndicator.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.30).CGColor
        activityIndicator.opaque = false
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Create gradient layer and add to blurEffect
        view.frame = CGRectMake(0.0, 0.0, view.bounds.width * 2, view.bounds.height * 2)
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor, UIColor.whiteColor().CGColor, UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor]
        blurEffect.layer.insertSublayer(gradient, atIndex: 1)
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = view.frame
        blurEffect.addSubview(effectView)
        
        getAllBars({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    self.navigationItem.title = "Error"
                    self.barHeader.text = "Your search returned no results."
                    self.barHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                } else {
                    let barName = result["name"] as! String
                    let address = (result["address"] as! String) + (result["city"] as! String)
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        }
                    })
                    println("We're going to \(barName)!")
                    self.barHeader.text = barName
                    self.barHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                }
            }
            })
        
//        mapView.showsUserLocation = true
//        println(mapView.userLocation.coordinate.latitude)
//        println(mapView.userLocation.coordinate.longitude)
//        centerMapOnLocation(mapView.userLocation.location)
        // Dispose of any resources that can be recreated.
        if let user = defaults.stringForKey("username") {
            navigationItem.rightBarButtonItem = profileButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
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
