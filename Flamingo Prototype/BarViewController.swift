//
//  BarViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/10/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class BarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    var type: String = ""
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var age: Int!
    var price: Int!
    var taggedFriends = Dictionary<String, UIImage>()
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    var reviewArray = [NSDictionary]()
    var selectedPath: NSIndexPath!
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var barHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()    
    @IBOutlet weak var taggedFriendsButton: UIButton!
    let defaults = NSUserDefaults.standardUserDefaults()
    var parentVC : TabBarController!
    
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
            if response == nil {
                completion(result: ["Error":"Non Connection"])
            }
            if(json != nil){
                allLocations = json as! NSArray
                location = self.chooseALocation(allLocations)
                completion(result: location)
            } else {
                completion(result: location)
            }
            // Set up info fields and reviews
            let id = location["_id"] as! String
            println("location id: \(id)")
            self.getReviews(id, completion: {
                (result: [NSDictionary]) in
                self.reviewArray = result
                println(result)
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.reviewTableView.reloadData()
                }
            })
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
        //              let priceRange = loc["price"]
        //            // TODO: make sure all ages are ints
        //            // TODO: add groupsize, price
        //            if(locCity == city && ageMin < age && ageMax > age && priceRange < price) {
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
    
    func getReviews(id: String, completion: (result: [NSDictionary])->Void) -> Void{
        // just a GET request
        let url = NSURL(string: "\(homeURL)api/\(type)/\(id)/reviews")
        println("reviews url: \(url)")
        var allReviews = NSArray()
        var review = [NSDictionary]()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("All Reviews: \(json)")
            if(json != nil){
                allReviews = json as! NSArray
                println("allReviews: \(allReviews.count)")
                var index = 0
                var fetched = 0
                // get only reviews with content, but no more than 5
                while index < allReviews.count && fetched < 5 {
                    let rbool = ((allReviews[index] as! NSDictionary).valueForKey("title") as! String) != ""
                    if rbool {
                        review.append(allReviews[index] as! NSDictionary)
                        fetched++
                    }
                    index++
                }
                completion(result: review)
            } else {
                completion(result: review)
            }
            
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parentVC = parentViewController as! TabBarController
        self.type = parentVC.type
        
        city = parentVC.city
        age = parentVC.age
        groupSize = parentVC.groupSize
        price = parentVC.price
        
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        // disable tab bar until location is retrieved and loaded
        let tabItems = parentVC.tabBar.items as! [UITabBarItem]
        for item in tabItems {
            item.enabled = false
        }
        
        barHeader.hidden = true
        addressLabel.hidden = true
        infoLabel.hidden = true
        infoText.hidden = true
        reviewLabel.hidden = true
        reviewTableView.hidden = true
        
        
        // set up activity indicator to be gray and fill screen
        activityIndicator.frame = self.view.frame
        activityIndicator.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.30).CGColor
        activityIndicator.opaque = false
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        getAllLocations({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    // Algorithm failed, no connection, etc
                    self.navigationItem.title = "Error"
                    self.barHeader.text = "No Connecion."
                    self.barHeader.hidden = false
                    self.infoLabel.text = "Could not connect to server."
                    self.activityIndicator.stopAnimating()
                } else {
                    self.locationName = result["name"] as! String
                    self.parentVC.locationName = self.locationName
                    let firstItem = self.parentVC.tabBar.items?.first as! UITabBarItem
                    firstItem.title = self.locationName
                    self.locationID = result["_id"] as! String
                    self.parentVC.locationID = self.locationID
                    let address = result["address"] as! String
                    let query = (self.locationName + " " + self.city).stringByReplacingOccurrencesOfString(" ", withString: "+")
                    println("ADDRESS: \(address)")
                    
                    // Look up address and get map coordinates
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString("\(address), \(self.city)", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            let newLat = placemark.location.coordinate.latitude
                            let newLong = placemark.location.coordinate.longitude
                            println("LAT: \(newLat), LONG: \(newLong)")
                            self.parentVC.lat = newLat
                            self.parentVC.long = newLong
                        }
                    })
                    
                    // Set text for bar result
                    println("We're going to \(self.locationName)!")
                    self.barHeader.text = self.locationName
                    self.barHeader.hidden = false
                    self.addressLabel.text = address
                    self.addressLabel.hidden = false
                    
                    self.infoText.hidden = false
                    self.infoLabel.hidden = false
                    self.reviewTableView.hidden = false
                    self.reviewLabel.hidden = false
                    
                    for item in tabItems {
                        item.enabled = true
                    }

                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        // Set link to profile page if user is logged in
        if let user = defaults.stringForKey("username") {
            println("has username: true")
            
            navigationController?.navigationItem.rightBarButtonItem = profileButton
            navigationItem.rightBarButtonItem = profileButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let image = cell?.imageView?.image {
            // selected cell is a valid review
            selectedPath = indexPath
            performSegueWithIdentifier("selectedReviewSegue", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        let row = indexPath.row
        if !reviewArray.isEmpty {
            if let temp = cell {
                cell?.textLabel?.text = reviewArray[row].valueForKey("title") as? String
                cell?.textLabel?.textColor = view.tintColor
                let rating = reviewArray[row].valueForKey("rating") as! Int
                cell?.imageView?.image = UIImage(named: "Dice \(rating)")
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
                cell?.textLabel?.text = reviewArray[row].valueForKey("title") as? String
                cell?.textLabel?.textColor = view.tintColor
                let rating = reviewArray[row].valueForKey("rating") as! Int
                cell?.imageView?.image = UIImage(named: "Dice \(rating)")
            }
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            cell?.textLabel?.text = "No reviews have been posted yet"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewArray.count > 0 {
            return reviewArray.count
        } else {
            return 1
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        taggedFriends = parentVC.taggedFriends
        if taggedFriends.count > 0 {
            let count = taggedFriends.count
            let friendsPlural = count > 1 ? "Friends" : "Friend"
            taggedFriendsButton.setTitle("\(count) \(friendsPlural)", forState: UIControlState.Normal)
            taggedFriendsButton.hidden = false
        } else {
            self.taggedFriendsButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if(segue.identifier == "taggedFriendsSegue"){
            let taggedVC = segue.destinationViewController as! TaggedFriendsTableViewController
            taggedVC.taggedFriends = taggedFriends
            taggedVC.parentVC = parentVC
        } else if segue.identifier == "selectedReviewSegue" {
            let selVC = segue.destinationViewController as! SelectedReviewViewController
            selVC.review = reviewArray[selectedPath.row]
        }
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
