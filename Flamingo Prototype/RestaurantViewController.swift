//
//  ResultsViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/3/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet var profileButton: UIBarButtonItem!
    @IBOutlet weak var restaurantHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func getAllRestaurants(completion: (result: NSDictionary)->Void) -> Void{
        // just a GET request
        let url = NSURL(string: "\(homeURL)api/restaurants")
        var allRestaurants = NSArray()
        var restaurant = NSDictionary()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("All Restaurants: \(json)")
            if(json != nil){
                allRestaurants = json as! NSArray
                restaurant = self.chooseARestaurant(allRestaurants)
                completion(result: restaurant)
            } else {
                completion(result: restaurant)
            }
        }
        task.resume()
    }
    
    func chooseARestaurant(allRestaurants: NSArray) -> NSDictionary{
        return allRestaurants[0] as! NSDictionary
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        

        
        getAllRestaurants({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    self.navigationItem.title = "Error"
                    self.restaurantHeader.text = "Your search returned no results."
                    self.restaurantHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                } else {
                    let restaurantName = result["name"] as! String
                    println("We're going to \(restaurantName)!")
                    self.restaurantHeader.text = restaurantName
                    self.restaurantHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                }
            }
        })
        
        // Dispose of any resources that can be recreated.
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
