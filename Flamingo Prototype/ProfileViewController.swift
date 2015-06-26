//
//  ProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/4/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var pink : UIColor! //UIColor(red: 227/255, green: 97/255, blue: 250/255, alpha: 1)
    var sectionArray = [String]()
    var sectionDict = Dictionary<String, [String]>()
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func deleteAccount(){
        // just a GET request to sign the user out
        let signoutURL = NSURL(string: "\(homeURL)signout")
        
        var task = NSURLSession.sharedSession().dataTaskWithURL(signoutURL!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            if(json != nil){
                println(json)
            }
        }
        task.resume()
        
        // log user out of facebook as well
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
        }
        
        // delete user from database
        let id = defaults.stringForKey("id")
        let url = "\(homeURL)users/\(id)"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        })
        
        task.resume()
        
        // clear user defaults
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        defaults.removePersistentDomainForName(appDomain!)
        
        // clear keychain
        Locksmith.clearKeychain()
        
        // go to main logged-out scene
        self.performSegueWithIdentifier("startSegue", sender: self)
    }
    
    func signout(sUrl: String){
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
        }
        
        // just a GET request
        let url = NSURL(string: sUrl)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            //            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            //            if(json != nil){
            //                println(json)
            //            }
        }
        task.resume()
    }
    
    // function to show an alert on the screen to ensure a user's choice, used for signout and delete account
    func showAlert(title: String, message: String, completion: () -> ()){
        let alertTitle = title
        var alertMessage = message
        
        if(NSClassFromString("UIAlertController") != nil){
            // iOS8 or later, AlertController exists
            var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) in
                println("handler reached")
                completion()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // iOS7 or earlier, must use AlertView
            let alert = UIAlertView()
            alert.title = alertTitle
            alert.delegate = self
            alert.message = alertMessage
            alert.addButtonWithTitle("Okay")
            alert.addButtonWithTitle("Cancel")
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Sign Out" {
            if alertView.buttonTitleAtIndex(buttonIndex) == "Okay" {
                self.signout("\(self.homeURL)signout")
                let appDomain = NSBundle.mainBundle().bundleIdentifier
                self.defaults.removePersistentDomainForName(appDomain!)
                
                self.performSegueWithIdentifier("startSegue", sender: self)
            }
        } else if alertView.title == "Delete Account" {
            if alertView.buttonTitleAtIndex(buttonIndex) == "Okay" {
                self.deleteAccount()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        pink = view.tintColor
        
        let firstname = defaults.stringForKey("firstname")!
        let lastname = defaults.stringForKey("lastname")!
        navigationItem.title = "\(firstname) \(lastname)"
        
        sectionArray = ["Details", "Options"]
        sectionDict.updateValue(["email","username","age","gender"], forKey: "Details")
        sectionDict.updateValue(["Change Preferences", "Change Password", "Sign Out", "Delete Account"], forKey: "Options")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sectionArray[indexPath.section]
        if section == "Options" {
            let cellTitles = sectionDict[section]!
            let curTitle = cellTitles[indexPath.row]
            
            if curTitle == "Change Preferences" {
                performSegueWithIdentifier("preferencesSegue", sender: self)
            }
            
            else if curTitle == "Change Password" {
                performSegueWithIdentifier("changePasswordSegue", sender: self)
            }
            
            else if curTitle == "Sign Out" {
                showAlert("Sign Out", message: "Are you sure you want to sign out of your account? You will be sent to the start page.",
                    completion: {
                        self.signout("\(self.homeURL)signout")
                        let appDomain = NSBundle.mainBundle().bundleIdentifier
                        self.defaults.removePersistentDomainForName(appDomain!)
                        
                        self.performSegueWithIdentifier("startSegue", sender: self)
                })
            }
            
            else if curTitle == "Delete Account" {
                showAlert("Sign Out", message: "Are you sure you want to delete your account? All of your information will be permanently erased.",
                    completion: {
                        self.deleteAccount()
                })
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDict[sectionArray[section]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

        let section = sectionArray[indexPath.section]
        let cellTitles = sectionDict[section]!
        

        if section == "Details" {
            // section 1: details - age, username, etc
            var cell = tableView.dequeueReusableCellWithIdentifier("subtitle") as? UITableViewCell

            let detail = cellTitles[indexPath.row].capitalizedString
            let title = defaults.stringForKey(detail.lowercaseString)
            
            if let tempo = cell {
                cell?.textLabel?.text = title
                cell?.detailTextLabel?.text = detail
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
                cell?.textLabel?.text = title
                cell?.detailTextLabel!.text = detail
            }
//            cell?.detailTextLabel?.textColor = pink
            return cell!

        } else {
            // section 2: options - change password, sign out, etc
            var cell = tableView.dequeueReusableCellWithIdentifier("basic") as? UITableViewCell

            if let tempo = cell {
                cell?.textLabel?.text = cellTitles[indexPath.row]
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
                cell?.textLabel?.text = cellTitles[indexPath.row]
            }
            let title = cellTitles[indexPath.row]
            if title == "Delete Account" {
                cell?.textLabel?.textColor = UIColor.redColor()
            } else {
                cell?.textLabel?.textColor = pink
            }
            return cell!

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let firstname = defaults.stringForKey("firstname")!
        let lastname = defaults.stringForKey("lastname")!
        navigationItem.title = "\(firstname) \(lastname)"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.title = "Profile"
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
