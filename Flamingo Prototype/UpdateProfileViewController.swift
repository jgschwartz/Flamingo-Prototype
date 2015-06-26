//
//  UpdateProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/22/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class UpdateProfileViewController: UIViewController, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var newEmailText: UITextField!
    @IBOutlet weak var confirmEmailText: UITextField!

    @IBOutlet weak var birthdayText: UITextField!
    @IBOutlet weak var cityText: UITextField!

    var cityPickerView: UIPickerView = UIPickerView()
    let cityArray = ["Basel"]
    var datePickerView: UIDatePicker = UIDatePicker()
    let ageArray: [Int] = [Int](18...100)
    
    var dataToUpdate = Dictionary<String, String>()
    let defaults = NSUserDefaults.standardUserDefaults()
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    
    @IBAction func updateAccount(sender: AnyObject) {
        dataToUpdate.removeAll(keepCapacity: true)
        
        newEmailText.resignFirstResponder()
        confirmEmailText.resignFirstResponder()
        birthdayText.resignFirstResponder()
        cityText.resignFirstResponder()
        
        if(!newEmailText.text.isEmpty && !confirmEmailText.text.isEmpty){
            if (newEmailText != confirmEmailText || newEmailText.text.rangeOfString(".+@.+[.].+$", options: NSStringCompareOptions.RegularExpressionSearch) == nil) {
                alertUpdate("Invalid Email", message: "Please input a valid email address to update your profile information.")
                return
            } else {
                dataToUpdate.updateValue(newEmailText.text, forKey: "email")
            }
        }
        
        if(!birthdayText.text.isEmpty){
            dataToUpdate.updateValue(birthdayText.text, forKey: "birthday")
        }
        
        if(!cityText.text.isEmpty){
            dataToUpdate.updateValue(cityText.text, forKey: "city")
        }
        if !dataToUpdate.isEmpty {
            let id = defaults.stringForKey("id")!
            updateUser(dataToUpdate, url: "\(homeURL)users/\(id)") {
                (succeeded: Bool, msg: String) in
                println("Succeeded? \(succeeded)")
                if succeeded {
                    self.defaults.setValuesForKeysWithDictionary(self.dataToUpdate)
                    
                    var updateMessage = ""
                    for (key, value) in self.dataToUpdate {
                        if updateMessage.isEmpty || self.dataToUpdate.count == 2 {
                            updateMessage += key.capitalizedString
                        } else if self.dataToUpdate.count == 1 {
                            updateMessage += " and \(key.capitalizedString)"
                        } else {
                            updateMessage += ", \(key.capitalizedString)"
                        }
                        self.dataToUpdate.removeValueForKey(key)
                    }
                    updateMessage += " successfully updated!"
                    
                    self.alertUpdate("Update Successful!", message: updateMessage)
                } else {
                    self.alertUpdate("Update Failed", message:
                        "Your user information could not be updated.")
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
    
    
    /* Picker View Delegate Functions */
    
    // Functions for birthday picker, don't use picker delegate
    @IBAction func birthdayEditing(sender: UITextField) {
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yyyy"
        birthdayText.text = dateformatter.stringFromDate(sender.date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if(pickerView.tag == 2){
            return cityArray.count
//        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        if(pickerView.tag == 2){
            return cityArray[row]
//        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if(pickerView.tag == 2){
            cityText.text = cityArray[row]
            cityText.resignFirstResponder()
//        }
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
        
        self.title = "Preferences"
        self.navigationItem.backBarButtonItem?.title = "Profile"
        
        // Set up picker views for input on text fields
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.tag = 2
        cityText.inputView = cityPickerView
        cityPickerView.backgroundColor = UIColor.clearColor()
        
        newEmailText.delegate = self
        confirmEmailText.delegate = self
        birthdayText.delegate = self
        cityText.delegate = self
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
