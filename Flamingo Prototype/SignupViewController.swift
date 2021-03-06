//
//  SignupViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SignupViewController: CustomKoynViewController, FBSDKLoginButtonDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    let activityIndicator = UIActivityIndicatorView()
    
    var cityPickerView: UIPickerView = UIPickerView()
    let cityArray = ["Basel"]
    var genderPickerView: UIPickerView = UIPickerView()
    let genderArray: [String] = ["Male", "Female", "Other"]
    var datePickerView: UIDatePicker = UIDatePicker()
    let ageArray: [Int] = [Int](18...100)
    var success: Bool = false
    
    // Function to register a new user using signup button
    @IBAction func signupButton(sender: AnyObject) {
        // Get input from all the text fields
        let email = emailText.text
        let user = userText.text
        let first = firstnameText.text
        let last = lastnameText.text
        let age = ageText.text
        let gender = genderText.text
        let city = cityText.text
        let pass = passText.text
        
        // Check to see that all forms are filled correctly
        if(email.isEmpty || email.rangeOfString(".+@.+[.].+$", options: NSStringCompareOptions.RegularExpressionSearch) == nil){
            alertBadSignup("Invalid email. Please input a valid address and try again.")
            return
        }
        if user.isEmpty {
            alertBadSignup("Please input a username and try again.")
            return
        }
        if first.isEmpty {
            alertBadSignup("Please input a first name and try again.")
            return
        }
        if last.isEmpty {
            alertBadSignup("Please input a last name and try again.")
            return
        }
        if age.isEmpty {
            alertBadSignup("Please input an age and try again.")
            return
        }
        if gender.isEmpty {
            alertBadSignup("Please input a gender and try again.")
            return
        }
        if count(pass) < 8 {
            alertBadSignup("Password must be at least 8 characters.")
            return
        }
        if city.isEmpty {
            alertBadSignup("Please input a gender and try again.")
            return
        }
        
        activityIndicator.startAnimating()
        
        // Use signup method to register, callback either goes to HomeViewController with success or alerts failed registration
        signup(["provider": "mobile", "email": "\(email)", "username": "\(user)", "password": "\(pass)", "firstname": "\(first)", "lastname": "\(last)", "gender": "\(gender)", "birthday": "\(age)", "city": "\(city)"], url: "\(homeURL)register"){
            (result: Bool, msg: String, id: String) in
            self.success = result
            println(self.success)
            if(self.success){
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    let sURL = "\(homeURL)users/\(id)"
                    println("GETTING USER")
                    self.getUserData(sURL){
                        (dict: NSDictionary) in
                        defaults.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
                        defaults.setValue("", forKey: "password")
                        println("User data fetched frpom getuserdata: \(dict)")
                        // Save password to Keychain for future authentifications
                        let service = NSBundle.mainBundle().bundleIdentifier
                        let saveError = Locksmith.saveData(["password":pass], forUserAccount: user, inService: service!)
                        if saveError != nil {
                            println("Keychain save error: \(saveError)")
                        }
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("successfulSignup", sender: self)
                    }
                }
            } else if msg == "No Connection" {
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.activityIndicator.stopAnimating()
                    self.alertBadSignup("Could not connect to the server. Please check your internet connection and try again later.")
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.activityIndicator.stopAnimating()
                    self.alertBadSignup("")
                }
            }
        }
    }
    
    // function to send an alert on the screen when a user cannot be registered
    func alertBadSignup(message: String){
        let alertTitle = "Registration Failed"
        var alertMessage = "Your registration failed due to bad credentials. Please try again."
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
    
    // Signup function (POST request with proper params)
    func signup(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String, id: String) -> ()) {
        
        // An error is given on UIKeyboard if a text field is first responder during network request
        // Check for nil because of this method's use in LoginViewController
        if emailText != nil {
            self.emailText.resignFirstResponder()
            self.userText.resignFirstResponder()
            self.firstnameText.resignFirstResponder()
            self.lastnameText.resignFirstResponder()
            self.passText.resignFirstResponder()
            cityText.resignFirstResponder()
            ageText.resignFirstResponder()
            genderText.resignFirstResponder()
        }
        
        // Create request and format correctly
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Make request and parse the response
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //            println("Body: \(strData)")
            var err: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments,  error: &err) as? NSDictionary
            
            var succeeded = false
            if response == nil {
                postCompleted(succeeded: false, msg: "No Connection", id: "")
            } else if let httpResponse = response as? NSHTTPURLResponse {
                println(httpResponse.statusCode)
                println(httpResponse.URL)
                let responseURL = httpResponse.URL?.absoluteString
                if httpResponse.statusCode == 200 && responseURL == homeURL{
                    succeeded = true
                }
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    println()
                    println(err!)
                    println()
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    //                println("Error could not parse JSON: '\(jsonStr)'")
                    if let id = httpResponse.allHeaderFields["id"] as? String {
                        postCompleted(succeeded: succeeded, msg: "Error", id: httpResponse.allHeaderFields["id"] as! String)
                    } else {
                        postCompleted(succeeded: succeeded, msg: "Error", id: "")
                    }
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    let newID = json?.valueForKey("id") as! String
                    println("JSON: \(newID)")
                    postCompleted(succeeded: succeeded, msg: "Posted", id: newID)
                }
            }
        })
        
        task.resume()
    }
    
    /* Picker View Delegate Functions */
    
    // Functions for birthday picker, don't use picker delegate
    @IBAction func datePickerEditing(sender: UITextField) {
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yyyy"
        ageText.text = dateformatter.stringFromDate(sender.date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1){
            return genderArray.count
        } else {
            return cityArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(pickerView.tag == 1){
            return String(genderArray[row])
        } else {
            return cityArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1){
            genderText.text = genderArray[row]
            genderText.resignFirstResponder()
        } else {
            cityText.text = cityArray[row]
            cityText.resignFirstResponder()
        }
    }
    
    /* Facebook Delegate Methods */
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        self.emailText.resignFirstResponder()
        self.userText.resignFirstResponder()
        self.firstnameText.resignFirstResponder()
        self.lastnameText.resignFirstResponder()
        self.passText.resignFirstResponder()
        cityText.resignFirstResponder()
        ageText.resignFirstResponder()
        genderText.resignFirstResponder()
        
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
            
            if !(result.grantedPermissions.contains("email") && result.grantedPermissions.contains("user_birthday") && result.grantedPermissions.contains("user_friends")) {
                alertBadSignup("We need all permissions for the app to work properly.\n\nWe need your email to identify you and allow logins from other devices.\nWe need your birthday to provide appropriate, age-related recommendations.\nWe need your friend list to connect you to other friends using the app (we cannot see anyone not using the app).\n\nIf you have any issue with granting these permissions, please sign up through the normal form and not through Facebook.")
            } else {
                signupFromFB()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    // Modified login/registration for Facebook; it is combined because the builtin fbLoginButton is easier to use without throwing exceptions for a successful login but unsuccessful registration or login, e.g. the user logs in from the loginVC but their FB account is not in the database
    func signupFromFB()
    {
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
                let providerId: String = result.valueForKey("id") as! String
                let birthday: String = result.valueForKey("birthday") as! String
                var gender: String = (result.valueForKey("gender") as! String).capitalizedString
                if gender != "Male" && gender != "Female" {
                    gender = "Other"
                }
                
                var pass = "password"
                let service = NSBundle.mainBundle().bundleIdentifier
                let (dict, loadError) = Locksmith.loadDataForUserAccount(username, inService: service!)
                if loadError != nil {
                    println("Error loading from keychain: \(loadError)")
                } else if let password = dict?.valueForKey("password") as? String {
                    pass = password
                }
                
                println("FB Credentials: \(email), \(username), \(pass), \(first), \(last), \(gender), \(birthday)")
                
                self.signup(["email": "\(email)", "username": "\(username)", "password": "\(pass)", "gender": "\(gender)", "firstname": "\(first)", "lastname": "\(last)", "birthday": "\(birthday)", "provider": "facebook", "providerId": "\(providerId)", "providerCheck": "facebook"], url: "\(homeURL)register"){
                    (result: Bool, msg: String, id: String) in
                    self.success = result
                    println(self.success)
                    if(self.success){
                        NSOperationQueue.mainQueue().addOperationWithBlock{
                            let sURL = "\(homeURL)users/\(id)"
                            println("GETTING USER")
                            self.getUserData(sURL){
                                (dict: NSDictionary) in
                                defaults.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
                                defaults.setValue("", forKey: "password")
                                println("User data fetched from getuserdata: \(dict)")
                                // Save password to Keychain for future authentifications
                                let service = NSBundle.mainBundle().bundleIdentifier
                                let saveError = Locksmith.saveData(["password":pass], forUserAccount: username, inService: service!)
                                if saveError != nil {
                                    println("Keychain save error: \(saveError)")
                                }
                                self.activityIndicator.stopAnimating()
                                self.performSegueWithIdentifier("successfulSignup", sender: self)
                            }
                        }
                    } else {
                        let loginVC = LoginViewController()
                        loginVC.login(email, password: pass){
                            (result: Bool, id: String) in
                            
                            self.success = result
                            println(self.success)
                            if(self.success){
                                NSOperationQueue.mainQueue().addOperationWithBlock{
                                    let sURL = "\(homeURL)users/\(id)"
                                    println("GETTING USER")
                                    self.getUserData(sURL){
                                        (dict: NSDictionary) in
                                        defaults.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
                                        defaults.setValue("", forKey: "password")
                                        println("User data fetched frpom getuserdata: \(dict)")
                                        // Save password to Keychain for future authentifications
                                        let service = NSBundle.mainBundle().bundleIdentifier
                                        let saveError = Locksmith.saveData(["password":pass], forUserAccount: username, inService: service!)
                                        if saveError != nil {
                                            println("Keychain save error: \(saveError)")
                                        }
                                        self.activityIndicator.stopAnimating()
                                        self.performSegueWithIdentifier("successfulSignup", sender: self)
                                    }
                                }
                            } else {
                                 NSOperationQueue.mainQueue().addOperationWithBlock{
                                    // log user out of facebook on failure
                                    if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                                        let fbLoginManager = FBSDKLoginManager()
                                        fbLoginManager.logOut()
                                    }
                                    self.activityIndicator.stopAnimating()
                                    self.alertBadSignup("")
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    /* Text Field Delegate Functions */
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.autocorrectionType = UITextAutocorrectionType.No
        if(textField.tag == 2 || textField.tag == 3){
            textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        }
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
        
        // Set up FB login button
        
        // check if user already logged in through facebook:
        if(FBSDKAccessToken.currentAccessToken() != nil){
            // already logged in
        } else {
            //           self.fbLogin = FBSDKLoginButton()
        }
        fbLogin.readPermissions = ["email", "public_profile", "user_friends", "user_birthday"]
        fbLogin.delegate = self
        
        // Set up picker views for input on text fields
        datePickerView.datePickerMode = UIDatePickerMode.Date
        let calendar = NSCalendar.currentCalendar()
        var legalDrinkingAge = NSDate()
        if (NSClassFromString("NSOperatingSystemVersion") != nil) {
            // iOS 8 and later
            legalDrinkingAge = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitYear, value: -21, toDate: NSDate(), options: nil)!
        } else {
            let component = NSDateComponents()
            component.year = -21
            legalDrinkingAge = NSCalendar.currentCalendar().dateByAddingComponents(component, toDate: NSDate(), options: NSCalendarOptions.SearchBackwards)!
        }
        datePickerView.date = legalDrinkingAge
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        genderPickerView.tag = 1
        genderText.inputView = genderPickerView
        genderPickerView.backgroundColor = UIColor.clearColor()
        
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.tag = 2
        cityText.inputView = cityPickerView
        cityPickerView.backgroundColor = UIColor.clearColor()
        
        let textFieldDict = [emailText: "Email", userText: "Username", firstnameText: "First", lastnameText: "Last", passText: "Password", ageText: "Age", genderText: "Gender", cityText: "City"]
        
        for field in textFieldDict.keys {
            field.delegate = self
            field.layer.cornerRadius = 5
            field.layer.borderWidth = 1.0
            field.placeholder = textFieldDict[field]
        }

        // extra text field configurations
        passText.secureTextEntry = true
        emailText.keyboardType = UIKeyboardType.EmailAddress
        ageText.keyboardType = UIKeyboardType.NumberPad
        
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
