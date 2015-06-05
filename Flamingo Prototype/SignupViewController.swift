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

class SignupViewController: UIViewController, FBSDKLoginButtonDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    
    var genderPickerView: UIPickerView = UIPickerView()
    let genderArray: [String] = ["Male", "Female", "Other"]
    var agePickerView: UIPickerView = UIPickerView()
    let ageArray: [Int] = [Int](18...100)
    var success: Bool = false
    
    // Go back to StartViewController when Back is pressed
    @IBAction func backDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Function to register a new user using signup button
    @IBAction func signupButton(sender: AnyObject) {
        // Get input from all the text fields
        let email = emailText.text
        let user = userText.text
        let first = firstnameText.text
        let last = lastnameText.text
        let age = ageText.text
        let gender = genderText.text
        let pass = passText.text

        // Use signup method to register, callback either goes to HomeViewController with success or alerts failed registration
        signup(["email": "\(email)", "username": "\(user)", "password": "\(pass)", "firstname": "\(first)", "lastname": "\(last)", "gender": "\(gender)", "age": "\(age)", "provider": "mobile"], url: "https://thawing-garden-5169.herokuapp.com/users"){
            (result: Bool, msg: String) in
            self.success = result
            println(self.success)
            if(self.success){
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    // TODO: add user info to keychain and user info, create cookie
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setValue("\(user)", forKey: "user")
                    defaults.setValue("\(age)", forKey: "age")
                    self.performSegueWithIdentifier("successfulSignup", sender: self)
                }
            } else {
                self.alertBadSignup()
            }
        }
    }
    
    // function to send an alert on the screen when a user cannot be registered
    func alertBadSignup(){
        if(NSClassFromString("UIAlertController") != nil){
            // iOS8 or later, AlertController exists
            var alert = UIAlertController(title: "Registration Failed", message: "Your registration failed due to bad credentials. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // iOS7 or earlier, must use AlertView
            let alert = UIAlertView()
            alert.title = "Registration Failed"
            alert.message = "Your registration failed due to bad credentials. Please try again."
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
    }
    
    /* Picker View Delegate Functions */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return ageArray.count
        } else {
            return genderArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(pickerView.tag == 0){
            return String(ageArray[row])
        } else {
            return genderArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0){
            ageText.text = String(ageArray[row])
            ageText.resignFirstResponder()
        } else {
            genderText.text = genderArray[row]
            genderText.resignFirstResponder()
        }
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
            signupFromFB()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    // Modified registration using signup() and FB profile info, modified from ReturnUserData() with signup() inside
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
                let pass: String = "password"
                let providerId: String = result.valueForKey("id") as! String
                
                self.signup(["email": "\(email)", "username": "\(username)", "password": "\(pass)", "firstname": "\(first)", "lastname": "\(last)", "provider": "facebook", "providerId": providerId], url: "https://thawing-garden-5169.herokuapp.com/users"){
                    (result: Bool, msg: String) in
                    self.success = result
                    println(self.success)
                    if(self.success){
                        NSOperationQueue.mainQueue().addOperationWithBlock{
                            self.performSegueWithIdentifier("successfulSignup", sender: self)
                        }
                    } else {
                        self.alertBadSignup()
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
    
    
    // Signup function (POST request with proper params)
    func signup(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        
        // An error is given on UIKeyboard if a text field is first responder during network request
        emailText.resignFirstResponder()
        userText.resignFirstResponder()
        firstnameText.resignFirstResponder()
        lastnameText.resignFirstResponder()
        passText.resignFirstResponder()
        
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
                postCompleted(succeeded: true, msg: "Posted")
            }
        })
        
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Registration"
        
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
        
        // Set up FB login button
        
        FBSDKLoginButton.initialize() // already initialized in appdelegate
        // check if user already logged in through facebook:
        if(FBSDKAccessToken.currentAccessToken() != nil){
            // already logged in
        } else {
 //           self.fbLogin = FBSDKLoginButton()

        }
        fbLogin.readPermissions = ["email", "public_profile", "user_friends"]
        fbLogin.delegate = self
        
        // Set up picker views for input on text fields
        agePickerView.delegate = self
        agePickerView.dataSource = self
        agePickerView.tag = 0
        ageText.inputView = agePickerView
        agePickerView.backgroundColor = UIColor.clearColor()
        agePickerView.selectRow(7, inComponent: 0, animated: false)
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        genderPickerView.tag = 1
        genderText.inputView = genderPickerView
        genderPickerView.backgroundColor = UIColor.clearColor()

        // Set up text field delegates
        emailText.delegate = self
        userText.delegate = self
        firstnameText.delegate = self
        lastnameText.delegate = self
        passText.delegate = self
        ageText.delegate = self
        genderText.delegate = self
        
        // set to obscure password input
        passText.secureTextEntry = true
        
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
