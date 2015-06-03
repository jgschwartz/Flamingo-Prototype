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

class SignupViewController: UIViewController, FBSDKLoginButtonDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    @IBOutlet weak var agePicker: UIPickerView!
    @IBOutlet weak var genderPicker: UIPickerView!
    
    let genderArray = ["Male", "Female", "Other"]
    let ageArray = [Int](18...100)
    var success = false
    
    @IBAction func backDismiss(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signupButton(sender: AnyObject) {
        let email = emailText.text
        let user = userText.text
        let first = firstnameText.text
        let last = lastnameText.text
        let age = ageArray[agePicker.selectedRowInComponent(0)]
        let gender = genderArray[genderPicker.selectedRowInComponent(0)]
        let pass = passText.text
        println("GENDER: \(gender)")
        signup(["email": "\(email)", "username": "\(user)", "password": "\(pass)", "firstname": "\(first)", "lastname": "\(last)", "gender": "\(gender)", "age": "\(age)", "provider": "mobile"], url: "https://thawing-garden-5169.herokuapp.com/users"){
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
    
    // Facebook Delegate Methods
    
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
//            returnUserData()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
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
    
    func returnUserData()
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
                let userName : NSString = result.valueForKey("name") as! NSString
                println("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                println("User Email is: \(userEmail)")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        FBSDKLoginButton.initialize() // already initialized in appdelegate
        // check if user already logged in through facebook:
        if(FBSDKAccessToken.currentAccessToken() != nil){
            // already logged in
        } else {
 //           self.fbLogin = FBSDKLoginButton()

        }
        self.fbLogin.readPermissions = ["email", "public_profile", "user_friends"]
        self.fbLogin.delegate = self
        
        self.agePicker.delegate = self
        self.agePicker.dataSource = self
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self

        // Do any additional setup after loading the view.
//        FBSDKLoginButton.initialize() // already initialized in appdelegate
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signup(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        emailText.resignFirstResponder()
        userText.resignFirstResponder()
        firstnameText.resignFirstResponder()
        lastnameText.resignFirstResponder()
        passText.resignFirstResponder()
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
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
                postCompleted(succeeded: true, msg: "Posted")
            }
        })
        
        task.resume()
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
