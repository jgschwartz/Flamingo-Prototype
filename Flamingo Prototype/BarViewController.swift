//
//  BarViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/10/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import GoogleMaps

class BarViewController: CustomKoynViewController, UITableViewDelegate, UITableViewDataSource {

    var type: String!
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var age: Int!
    var price: Int!
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var taggedFriends: Dictionary<String, UIImage>!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    var reviewArray = [NSDictionary]()
    var selectedPath: NSIndexPath!
    @IBOutlet weak var totalRating: UIImageView!
    
    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var barHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()    
    @IBOutlet weak var taggedFriendsButton: UIButton!
    var parentVC : TabBarController!
    
    @IBAction func goingPressed(sender: AnyObject) {
        if let provider = defaults.stringForKey("provider") {
            if provider == "facebook" {
                performSegueWithIdentifier("tagSegue", sender: self)
            } else {
                performSegueWithIdentifier("mapSegue", sender: self)
            }
        } else {
            performSegueWithIdentifier("mapSegue", sender: self)
        }
    }
    
    // Called when a review is submitted from the app
    func addReview(review: NSDictionary) {
        reviewArray = [review] + reviewArray
        self.reviewTableView.reloadData()
    }
    
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
                completion(result: ["Error":"No Connection"])
            }
            if(json != nil){
                allLocations = json as! NSArray
                location = self.chooseALocation(allLocations)
                completion(result: location)
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
            } else {
                completion(result: location)
            }
        }
        task.resume()
    }
    
    func chooseALocation(allLocations: NSArray) -> NSDictionary{
        var possibles = [NSDictionary]()
        var featured = [NSDictionary]()
        for loc in allLocations {
            let locCity = loc["city"] as! String
            let ageMin = loc["ageMin"] as! Int
            let ageMax = loc["ageMax"] as! Int
            let priceRange = loc["price"] as! Int
            // TODO: make sure all ages are ints
            // TODO: add groupsize, price
            if(locCity == city && ageMin < age && ageMax > age && priceRange < price) {
                possibles.append(loc as! NSDictionary)
                if let featureFeature = loc["featured"] as? String {
                    if featureFeature == "true" {
                        featured.append(loc as! NSDictionary)
                    }
                }
            }
        }
        if(featured.count > 0){
            return featured[0]
        } else if possibles.count > 0 {
            return possibles[0]
        } else {
            return allLocations[0] as! NSDictionary
        }
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
                var index = allReviews.count - 1
                let revEnum = allReviews.reverseObjectEnumerator()
                var fetched = 0
                var single = NSDictionary()
                // get only reviews with content, but no more than 5
                var sumRatings = 0.0
                for i in 0..<allReviews.count {
                    single = revEnum.nextObject() as! NSDictionary
                    let rating = single.valueForKey("rating") as! Int
                    sumRatings += Double(rating)
                    
                    if fetched < 5 {
                        let rbool = (single.valueForKey("title") as! String) != ""
                        if rbool {
                            review.append(single)
                            fetched++
                        }
                    }
                    index--
                }
                println("RATINGS TOTAL : \(sumRatings)")
                println("REVIEWS COUNT: \(allReviews.count)")
                let rating: Int = Int(round(sumRatings / Double(allReviews.count)))
                println(rating)
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.totalRating.image = UIImage(named: "Trans Star Dice \(rating)")
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
        
        var tabbar = false
        var tabItems = [UITabBarItem]()
        if let parent = parentViewController as? TabBarController {
            tabbar = true
            parentVC = parent
            type = parentVC.type
            city = parentVC.city
            age = parentVC.age
            groupSize = parentVC.groupSize
            price = parentVC.price
            
            // disable tab bar until location is retrieved and loaded
            tabItems = parentVC.tabBar.items as! [UITabBarItem]
            for item in tabItems {
                item.enabled = false
            }
        }
        
        totalRating.layer.cornerRadius = 5
        totalRating.layer.borderColor = UIColor.blackColor().CGColor
        totalRating.layer.borderWidth = 1.0
        
        barHeader.hidden = true
        addressLabel.hidden = true
        infoLabel.hidden = true
        infoText.hidden = true
        reviewLabel.hidden = true
        reviewTableView.hidden = true
        goingButton.hidden = true
        
        if NSClassFromString("NSOperatingSystemVersion") == nil {
            taggedFriendsButton.contentEdgeInsets.right = 10
        }
        
        reviewTableView.tintColor = view.tintColor
        reviewTableView.contentInset.left = -15
        reviewTableView.separatorColor = UIColor.blackColor()
        reviewTableView.separatorInset = UIEdgeInsetsZero
        
        // set up activity indicator to be gray and fill screen
        activityIndicator.frame = self.view.frame
        activityIndicator.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.30).CGColor
        activityIndicator.opaque = false
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        
        lat = 50
        long = 50
        
        activityIndicator.startAnimating()
        getAllLocations({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    // Algorithm failed, no connection, etc
                    self.navigationItem.title = "Error"
                    self.barHeader.text = "No Connection."
                    self.barHeader.hidden = false
                    self.infoLabel.text = "Could not connect to server."
                    self.activityIndicator.stopAnimating()
                } else {
                    self.locationName = result["name"] as! String
                    if tabbar {
                        self.parentVC.locationName = self.locationName
                        let firstItem = self.parentVC.tabBar.items?.first as! UITabBarItem
                        firstItem.title = self.locationName
                    }
                    self.locationID = result["_id"] as! String
//                    self.parentVC.locationID = self.locationID
                    let address = result["address"] as! String
                    let query = (self.locationName + " " + self.city).stringByReplacingOccurrencesOfString(" ", withString: "+")
                    println("ADDRESS: \(address)")
                    
                    // Look up address and get map coordinates
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString("\(address), \(self.city)", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            self.lat = placemark.location.coordinate.latitude
                            self.long = placemark.location.coordinate.longitude
                            println("LAT: \(self.lat), LONG: \(self.long)")
//                            self.parentVC.lat = newLat
//                            self.parentVC.long = newLong
                        }
                    })
                    
                    if let info = result["information"] as? String {
                        self.infoText.text = info
                    }
                    
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
                    
                    if tabbar {
                        for item in tabItems {
                            item.enabled = true
                        }
                        var constraint = NSLayoutConstraint(item: self.goingButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0)
                        self.view.addConstraint(constraint)
                        constraint = NSLayoutConstraint(item: self.goingButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
                        self.view.addConstraint(constraint)
//                        constraint = NSLayoutConstraint(item: self.reviewTableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10)
//                        self.view.addConstraint(constraint)
//                        constraint = NSLayoutConstraint(item: self.infoText, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: self.bottomLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10)
//                        self.view.addConstraint(constraint)
                    } else {
                        self.goingButton.hidden = false
                    }

                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        navigationController?.navigationItem.title = locationName
        navigationItem.title = locationName
        title = locationName
        
        infoText.scrollRangeToVisible(NSMakeRange(0, 0))
        
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
            cell?.backgroundColor = UIColor.clearColor()
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
                cell?.imageView?.image = UIImage(named: "Trans Star Dice \(rating)")
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
                cell?.textLabel?.text = reviewArray[row].valueForKey("title") as? String
                cell?.textLabel?.textColor = view.tintColor
                let rating = reviewArray[row].valueForKey("rating") as! Int
                cell?.imageView?.image = UIImage(named: "Trans Star Dice \(rating)")
            }
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            cell?.textLabel?.text = "No reviews have been posted yet"
        }
        cell?.backgroundColor = UIColor.clearColor()
        cell?.contentView.layer.borderColor = UIColor.blackColor().CGColor
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        //            cell?.contentView.layer.borderWidth = 1.0
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
        if parentVC != nil {
            taggedFriends = parentVC.taggedFriends
        } else {
            if let data = defaults.objectForKey("taggedFriends") as? NSData {
                taggedFriends = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, UIImage>
            } else {
                taggedFriends = Dictionary<String, UIImage>()
            }
        }
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
            taggedVC.parentVC = self
        } else if segue.identifier == "selectedReviewSegue" {
            let selVC = segue.destinationViewController as! SelectedReviewViewController
            selVC.review = reviewArray[selectedPath.row]
        } else if segue.identifier == "tagSegue" {
            let friendsVC = segue.destinationViewController as! FriendsViewController
            friendsVC.city = city
            friendsVC.locationID = locationID
            friendsVC.locationName = locationName
            friendsVC.groupSize = groupSize
            friendsVC.lat = lat
            friendsVC.long = long
            friendsVC.type = type
            friendsVC.age = age
            friendsVC.price = price
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(taggedFriends)
            defaults.setValue(data, forKey: "taggedFriends")
            
        } else if segue.identifier == "mapSegue" {
            let mapVC = segue.destinationViewController as! MapViewController
            mapVC.city = city
            mapVC.locationID = locationID
            mapVC.locationName = locationName
            mapVC.groupSize = groupSize
            mapVC.lat = lat
            mapVC.long = long
            mapVC.type = type
            mapVC.age = age
            mapVC.price = price
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
