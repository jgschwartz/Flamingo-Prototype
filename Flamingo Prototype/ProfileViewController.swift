//
//  ProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/4/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    var textFieldDict = Dictionary<UITextField, String>()
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var deleteButton: UIButton!
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBAction func deleteUserButton(sender: AnyObject) {
        let id = defaults.stringForKey("id")!
        let url = "\(homeURL)users/\(id)"
        
        let alertTitle = "Delete User Account"
        var alertMessage = "Are you sure you want to delete your account? All your information will be erased."
        
        if(NSClassFromString("UIAlertController") != nil){
            // iOS8 or later, AlertController exists
            var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.deleteUser(url)}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // iOS7 or earlier, must use AlertView
            let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: "Cancel")
            alert.addButtonWithTitle("Delete")
            alert.tag = 1
            alert.setValue(url, forKey: "url")
            alert.show()
        }
    }
    
    // Respond to delete user click from Alert View in deleteUserButton() using url set as key in alert
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(alertView.tag == 1){
            if(buttonIndex != alertView.cancelButtonIndex){
                deleteUser(alertView.valueForKey("url") as! String)
            }
        }
    }
    
    @IBAction func updateUserButton(sender: AnyObject) {
        var requestString = Dictionary<String, String>()
        
        if(!emailText.text.isEmpty && emailText.text.rangeOfString(".+@.+[.].+$", options: NSStringCompareOptions.RegularExpressionSearch) == nil){
            alertUpdate("Invalid Email", message: "Please input a valid email address to update your profile information.")
            return
        }
        
        if(!passText.text.isEmpty && count(passText.text) < 8){
            alertUpdate("Invalid Password", message: "Passwords must be greater than 8 characters.")
            return
        }
        
        for (key, value) in textFieldDict {
            key.resignFirstResponder()
            if !key.text.isEmpty {
                requestString.updateValue(key.text, forKey: value)
            }
        }

        let id = defaults.stringForKey("id")!
        updateUser(requestString, url: "\(homeURL)users/\(id)") {
            (succeeded: Bool, msg: String) in
            println("Succeeded? \(succeeded)")
            if succeeded {
                self.defaults.setValuesForKeysWithDictionary(requestString)
                
                // update info displayed on profile to show new information
                for (key, value) in self.textFieldDict {
                    key.placeholder = self.defaults.stringForKey(value)
                }
                
                self.alertUpdate("Update Successful!", message: "")
            } else {
                self.alertUpdate("Update Failed", message:
                    "Your user information could not be updated.")
            }
        }
        
    }
    
    func updateUser(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()){
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments,  error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println()
                println(err!)
                println()
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                println(json)
                postCompleted(succeeded: true, msg: "Updated")
            }
        })
        
        task.resume()
    }
    
    func deleteUser(url: String){
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
        println(url)
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
        self.performSegueWithIdentifier("deleteUser", sender: self)
    }
    
    // function to send an alert on the screen when a user attempts to update their profile
    func alertUpdate(title: String, message: String){
        let alertTitle = title
        var alertMessage = message
        
        if(NSClassFromString("UIAlertController") != nil){
            // iOS8 or later, AlertController exists
            var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // iOS7 or earlier, must use AlertView
            let alert = UIAlertView()
            alert.title = alertTitle
            alert.message = alertMessage
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "FlamingoGradientPNG")!)
        
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
        
        textFieldDict.updateValue("email", forKey: emailText)
        textFieldDict.updateValue("username", forKey: userText)
        textFieldDict.updateValue("firstname", forKey: firstnameText)
        textFieldDict.updateValue("lastname", forKey: lastnameText)
        textFieldDict.updateValue("password", forKey: passText)
        textFieldDict.updateValue("age", forKey: ageText)
        textFieldDict.updateValue("gender", forKey: genderText)
        
        for (key, value) in textFieldDict {
            key.placeholder = defaults.stringForKey(value)
        }
        
        passText.secureTextEntry = true
        
        // Do any additional setup after loading the view.
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
