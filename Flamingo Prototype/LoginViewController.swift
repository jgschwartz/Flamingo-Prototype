//
//  LoginViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    let activityIndicator = UIActivityIndicatorView()
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    var success = false
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Login with username and password
    @IBAction func loginButton(sender: AnyObject) {
        let username = userText.text
        let password = passText.text
        
        userText.resignFirstResponder()
        passText.resignFirstResponder()
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        activityIndicator.startAnimating()
            login(username, password: password) {
                (result: Bool, id: String) in
                println("Login successful: \(result)")
                self.success = result
                if(self.success){
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let sURL = "\(self.homeURL)users/\(id)"
                        self.getUserData(sURL){
                            (dict: NSDictionary) in
//                            dict.setValue("", forKey: "password")
                            self.defaults.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
                            self.defaults.setValue("", forKey: "password")
                            println(dict)
                        }
//                        if let user = defaults.stringForKey("username"){
//                            println(user)
                        println("user data FOUND")
//                        } else {
//                            defaults.setValue(username, forKey: "username")
//                            println("new user set")
//                        }
                        self.defaults.setValue(true, forKey: "loggedin")
                        self.defaults.setValue(id, forKey: "id")
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("successfulLogin", sender: self)
                    }
                } else {
                    self.alertBadLogin("")
                    NSOperationQueue.mainQueue().addOperationWithBlock{
                        self.userText.text = nil
                        self.passText.text = nil
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
//        })
    }
    
    // On unsuccessful login, send alert telling them to try again
    func alertBadLogin(message: String){
        let alertTitle = "Login Failed"
        var alertMessage = "Your login failed due to bad credentials. Please try again."
        if !message.isEmpty {
            alertMessage = message
        }
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
    
    
    // Login function uses a POST request with username and password to confirm correct credentials
    func login(username: String, password: String, completion: (result: Bool, id: String) -> Void){
        var err: NSError?
        var json: NSJSONSerialization?
        
        // Must be formatted as x-www-form-urlencoded and not JSON
        var params = "username=\(username)&password=\(password)"
        var paramsLength = "\(count(params))"
        var requestBodyData = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create request and parameters
        var url = NSURL(string: "\(self.homeURL)login")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = requestBodyData
        request.addValue(paramsLength, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Send request and parse response, send result to callback
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            if(error != nil){
                println("ERROR IS: \(error)")
            } else {
                
                println("Body: \(strData)")
                
                println("\n")
                
                println("Response: \(response)")
                
                let httpResponse = response as! NSHTTPURLResponse
                println(httpResponse.statusCode)
                let responseURL = httpResponse.URL?.absoluteString
                println(httpResponse.allHeaderFields["id"])
                let id = httpResponse.allHeaderFields["id"] as! String
                if httpResponse.statusCode == 200 && responseURL == self.homeURL {
                    completion(result: true, id: id)
                } else {
                    completion(result: false, id: id)
                }
                
                var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves,  error: &err) as? NSDictionary
                println("JSON: \(json)")
                
            }
        })
        task.resume()
    }
    
    func getUserData(sUrl: String, completion: (dict: NSDictionary) -> Void) {
        // just a GET request
        let url = NSURL(string: sUrl)
        var userData = NSDictionary()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
            println("User data: \(json)")
            println("Response: \((response as! NSHTTPURLResponse).statusCode)")
            println(json.dynamicType)
            if(json != nil){
                userData = json as! NSDictionary
                completion(dict: userData)
            } else {
                completion(dict: userData)
            }
        }
        task.resume()
        println(userData)
    }
    
    /* Facebook Delegate Methods */
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            loginFromFB()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    // Modified login/registration for Facebook; it is combined because the builtin fbLoginButton is easier to use without throwing exceptions for a successful login but unsuccessful registration or login, e.g. the user logs in from the loginVC but their FB account is not in the database
    func loginFromFB()
    {
        activityIndicator.startAnimating()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                println("fetched user: \(result)")
                let first: String = result.valueForKey("first_name") as! String
                let email: String = result.valueForKey("email") as! String
                let emailSplit: [String] = email.componentsSeparatedByString("@")
                let username: String = emailSplit[0]
                let last: String = result.valueForKey("last_name") as! String
                let pass: String = "password"
                let providerId: String = result.valueForKey("id") as! String
                let birthday: String = result.valueForKey("birthday") as! String
                var gender: String = (result.valueForKey("gender") as! String).capitalizedString
                if gender != "Male" && gender != "Female" {
                    gender = "Other"
                }
                
                println("FB credentials: \(email), \(username), \(pass), \(first), \(last), \(gender), \(birthday)")
                
                self.login(email, password: pass){
                    (result: Bool, id: String) in
                    
                    self.success = result
                    println(self.success)
                    if(self.success){
                        NSOperationQueue.mainQueue().addOperationWithBlock{
                            self.defaults.setValue("\(email)", forKey: "email")
                            self.defaults.setValue("\(username)", forKey: "username")
                            self.defaults.setValue(true, forKey: "loggedin")
                            self.defaults.setValue(id, forKey: "id")
                            self.defaults.setValue("\(first)", forKey: "firstname")
                            self.defaults.setValue("\(last)", forKey: "lastname")
                            self.defaults.setValue("\(gender)", forKey: "gender")
                            self.defaults.setValue("\(birthday)", forKey: "age")
                            self.activityIndicator.stopAnimating()
                            self.performSegueWithIdentifier("successfulLogin", sender: self)
                        }
                    } else {
                        // instantiate new SignupViewController to use its signup method so it doesn't need to be duplicated
                        let signupVC = SignupViewController()
                        signupVC.signup(["email": "\(email)", "username": "\(username)", "password": "\(pass)", "firstname": "\(first)", "lastname": "\(last)", "provider": "facebook", "providerId": "\(providerId)", "providerCheck": "facebook"], url: "https://thawing-garden-5169.herokuapp.com/register"){
                            (result: Bool, msg: String, id: String) in
                            self.success = result
                            println(self.success)
                            if(self.success){
                                NSOperationQueue.mainQueue().addOperationWithBlock{
                                    self.defaults.setValue("\(username)", forKey: "username")
                                    self.defaults.setValue("\(email)", forKey: "email")
                                    self.defaults.setValue(true, forKey: "loggedin")
                                    self.defaults.setValue(id, forKey: "id")
                                    self.defaults.setValue("\(first)", forKey: "firstname")
                                    self.defaults.setValue("\(last)", forKey: "lastname")
                                    self.defaults.setValue("\(gender)", forKey: "gender")
                                    self.defaults.setValue("\(birthday)", forKey: "age")
                                    self.performSegueWithIdentifier("successfulLogin", sender: self)
                                }
                            } else {
                                self.alertBadLogin("")
                            }
                        }
                    }
                }
            }
        })
    }
    
    /* Text Field Delegate Functions */
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.autocorrectionType = UITextAutocorrectionType.No
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
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
        
        // Create gradient and add to blurEffect
        view.frame = CGRectMake(0.0, 0.0, view.bounds.width * 2, view.bounds.height * 2)
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor, UIColor.whiteColor().CGColor, UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor]
        blurEffect.layer.insertSublayer(gradient, atIndex: 1)
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = view.frame
        blurEffect.addSubview(effectView)
        
        fbLogin.delegate = self
        userText.delegate = self
        passText.delegate = self
        
        passText.secureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("Memory?")
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
