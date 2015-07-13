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
    var fieldsToUpdate = [String]()
    
    @IBAction func updateAccount(sender: AnyObject) {
        dataToUpdate.removeAll(keepCapacity: true)
        fieldsToUpdate.removeAll(keepCapacity: false)
        
        let email = defaults.stringForKey("email")!
        let username = defaults.stringForKey("username")!
        let firstname = defaults.stringForKey("firstname")!
        let lastname = defaults.stringForKey("lastname")!
        let provider = defaults.stringForKey("provider")!
        let gender = defaults.stringForKey("gender")!
        let birthday = defaults.stringForKey("birthday")!
        
        dataToUpdate.updateValue(email, forKey: "email")
        dataToUpdate.updateValue(username, forKey: "username")
        dataToUpdate.updateValue(firstname, forKey: "firstname")
        dataToUpdate.updateValue(lastname, forKey: "lastname")
        dataToUpdate.updateValue(provider, forKey: "provider")
        dataToUpdate.updateValue(gender, forKey: "gender")
        dataToUpdate.updateValue(birthday, forKey: "birthday")
        
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
                fieldsToUpdate.append("email")
            }
        }
        
        if(!birthdayText.text.isEmpty){
            dataToUpdate.updateValue(birthdayText.text, forKey: "birthday")
            fieldsToUpdate.append("birthday")

        }
        
        if(!cityText.text.isEmpty){
            dataToUpdate.updateValue(cityText.text, forKey: "city")
            fieldsToUpdate.append("city")

        }
        if !dataToUpdate.isEmpty {
            let service = NSBundle.mainBundle().bundleIdentifier
            let username = defaults.valueForKey("username") as! String
            
            let (dict, loadError) = Locksmith.loadDataForUserAccount(username, inService: service!)
            let password = dict?.valueForKey("password") as! String
            dataToUpdate.updateValue(password, forKey: "password") // password must be included for changes to take place
            let id = defaults.stringForKey("id")!
            updateUser(dataToUpdate, url: "\(homeURL)users/\(id)") {
                (succeeded: Bool, msg: String) in
                if succeeded {
                    defaults.setValuesForKeysWithDictionary(self.dataToUpdate)

                    // calculate new age if birthday is updated
                    if !self.birthdayText.text.isEmpty {
                        var dateformatter = NSDateFormatter()
                        dateformatter.dateFormat = "MM/dd/yyyy"
                        let startDate = dateformatter.dateFromString(self.birthdayText.text)
                        let curDate = NSDate()
                        let calendar = NSCalendar.currentCalendar()
                        let unit = NSCalendarUnit.CalendarUnitYear
                        let age = calendar.components(unit, fromDate: startDate!, toDate: curDate, options: nil)
                        println(age)
                        defaults.setValue(age.year, forKey: "age")
                    }
                    
                    var updateMessage = ""
                    for field in self.fieldsToUpdate {
                        if updateMessage.isEmpty || self.dataToUpdate.count == 2 {
                            updateMessage += field.capitalizedString
                        } else if self.fieldsToUpdate.count == 1 {
                            updateMessage += " and \(field)"
                        } else {
                            updateMessage += ", \(field)"
                        }
                        self.dataToUpdate.removeValueForKey(field)
                    }
                    updateMessage += " successfully updated!"
                    
                    self.alertUpdate("Update Successful!", message: updateMessage)
                } else {
                    if msg != "" {
                        self.alertUpdate("Update Failed", message: msg)
                    } else {
                        self.alertUpdate("Update Failed", message:
                            "Sorry, your user information could not be updated.")
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
                    if let message = json!.valueForKey("message") as? String {
                        println("Failed: \(message)")
                        msg = message
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
        UIImage(named: bgImageName)?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        self.title = "Preferences"
        self.navigationItem.backBarButtonItem?.title = "Profile"
        
        // Set up picker views for input on text fields
        datePickerView.datePickerMode = UIDatePickerMode.Date
        let birthday = defaults.stringForKey("birthday")
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yyyy"
        datePickerView.date = dateformatter.dateFromString(birthday!)!
        
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
