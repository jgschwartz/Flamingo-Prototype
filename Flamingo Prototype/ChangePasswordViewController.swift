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
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func updatePasswordButton(sender: AnyObject) {
        
        oldPassText.resignFirstResponder()
        newPassText.resignFirstResponder()
        confirmPassText.resignFirstResponder()
        
        if(!oldPassText.text.isEmpty && !newPassText.text.isEmpty && !confirmPassText.text.isEmpty){
            if newPassText.text != confirmPassText.text {
                alertUpdate("Mismatched Passwords", message: "New password and confirm password fields must match.")
                return
            } else if count(newPassText.text) < 8 {
                alertUpdate("Invalid Password", message: "Passwords must be greater than 8 characters.")
                return
            } else {
                let id = defaults.stringForKey("id")!
                updateUser(["password": newPassText.text], url: "\(homeURL)users/\(id)") {
                    (succeeded: Bool, json: String) in
                    println("Succeeded? \(succeeded)")
                    if succeeded {
                        self.alertUpdate("Update Successful!", message: "Password successfully updated!")
                    } else {
                        self.alertUpdate("Update Failed", message:
                            "Sorry, your password could not be updated.")
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
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
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
