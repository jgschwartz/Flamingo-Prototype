//
//  ChangePasswordViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/26/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var oldPassText: UITextField!
    @IBOutlet weak var newPassText: UITextField!
    @IBOutlet weak var confirmPassText: UITextField!
    
    @IBAction func updatePasswordButton(sender: AnyObject) {
        
        oldPassText.resignFirstResponder()
        newPassText.resignFirstResponder()
        confirmPassText.resignFirstResponder()
        
        if(!oldPassText.text.isEmpty && !newPassText.text.isEmpty && !confirmPassText.text.isEmpty){
            let username = defaults.stringForKey("username")!
            let service = NSBundle.mainBundle().bundleIdentifier
            let (dict, loadError) = Locksmith.loadDataForUserAccount(username, inService: service!)
            if loadError != nil {
                println("Keychain load error: \(loadError)")
            }
            var password = "password"
            if let pass: AnyObject = dict?.valueForKey("password") as? String {
                password  = pass as! String
            }
            
            if newPassText.text != confirmPassText.text {
                alertUpdate("Mismatched Passwords", message: "New password and confirm password fields must match.")
                return
            } else if count(newPassText.text) < 8 {
                alertUpdate("Invalid Password", message: "Passwords must be greater than 8 characters.")
                return
            } else if password != oldPassText.text {
                alertUpdate("Incorrect Password", message: "The inputted password does not match your current password.")
                return
            } else {
                let id = defaults.stringForKey("id")!
                let email = defaults.stringForKey("email")!
                let firstname = defaults.stringForKey("firstname")!
                let lastname = defaults.stringForKey("lastname")!
                let provider = defaults.stringForKey("provider")!
                let gender = defaults.stringForKey("gender")!
                let birthday = defaults.stringForKey("birthday")!
                
                updateUser(["email": "\(email)", "username": "\(username)", "firstname": "\(firstname)", "lastname": "\(lastname)", "provider": "\(provider)", "gender": "\(gender)", "birthday": "\(birthday)", "password": newPassText.text], url: "\(homeURL)users/\(id)") {
                    (succeeded: Bool, msg: String) in
                    if succeeded {
                        // Replace password in Keychain with new one
                        let service = NSBundle.mainBundle().bundleIdentifier
                        Locksmith.deleteDataForUserAccount(username, inService: service!)
                        let saveError = Locksmith.saveData(["password":self.newPassText.text], forUserAccount: username, inService: service!)
                        if saveError != nil {
                            println("Keychain save error: \(saveError)")
                        }

                        self.alertUpdate("Update Successful!", message: "Password successfully updated!")
                    } else {
                        if msg != "" {
                            self.alertUpdate("Update Failed", message: msg)
                        } else {
                            self.alertUpdate("Update Failed", message:
                                "Sorry, your password could not be updated.")
                        }
                    }
                }
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
//            if(err != nil) {
//                println()
//                println(err!)
//                println()
//                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//                println("Error could not parse JSON: '\(jsonStr)'")
//                postCompleted(succeeded: false, msg: "")
//            } else
            if response == nil {
                postCompleted(succeeded: false, msg: "Could not connect to the server. Please check your internet connection and try again later.")
            } else
            if let httpResponse = response as? NSHTTPURLResponse {
                let statusCode = httpResponse.statusCode
                let id = httpResponse.allHeaderFields["id"] as? String
                
                if statusCode == 200 && id != nil{
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    println(json)
                    postCompleted(succeeded: true, msg: "Updated")
                } else {
                    var msg = ""
                    if let j = json {
                        if let message = json!.valueForKey("message") as? String {
                            println("Failed: \(message)")
                            msg = message
                        }
                    }
                    postCompleted(succeeded: false, msg: msg)
                }
            } else {
                postCompleted(succeeded: false, msg: "Could not connect to the server. Please check your internet connection and try again later.")
            }
        })
        
        task.resume()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: bgImageName)?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        self.title = "Change Password"
        
        oldPassText.delegate = self
        newPassText.delegate = self
        confirmPassText.delegate = self
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
