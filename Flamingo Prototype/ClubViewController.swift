//
//  ClubViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/10/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ClubViewController: UIViewController {
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var clubHeader: UILabel!
    let activityIndicator = UIActivityIndicatorView()

    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func getAllClubs(completion: (result: NSDictionary)->Void) -> Void{
        // just a GET request
        let url = NSURL(string: "\(homeURL)api/clubs")
        var allClubs = NSArray()
        var club = NSDictionary()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("All Clubs: \(json)")
            if(json != nil){
                allClubs = json as! NSArray
                club = self.chooseAClub(allClubs)
                completion(result: club)
            } else {
                completion(result: club)
            }
        }
        task.resume()
    }
    
    func chooseAClub(allClubs: NSArray) -> NSDictionary{
        return allClubs[0] as! NSDictionary
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
        
        
        getAllClubs({
            (result: NSDictionary) in
            NSOperationQueue.mainQueue().addOperationWithBlock{
                if(result.count == 0){
                    self.navigationItem.title = "Error"
                    self.clubHeader.text = "Your search returned no results and you suck. You'll never find a good club because you don't make anything of value. Peter, you suck."
                    self.clubHeader.hidden = false
                    self.activityIndicator.stopAnimating()
                } else {
                    let clubName = result["name"] as! String
                    println("We're going to \(clubName)!")
                    self.clubHeader.text = clubName
                    self.clubHeader.hidden = false
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
