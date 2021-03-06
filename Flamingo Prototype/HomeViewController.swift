//
//  ProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class HomeViewController: CustomKoynViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var groupText: UITextField!
    @IBOutlet weak var locationSegment: UISegmentedControl!
    @IBOutlet weak var priceSegment: UISegmentedControl!
    
    var type: String!
    let groupArray = [Int](1...20)
    var groupPickerView = UIPickerView()
    
    @IBAction func go(sender: AnyObject) {
        if(groupText.text.isEmpty){
            let alertTitle = "Incomplete Form"
            var alertMessage = "You must fill out all sections to proceed."
            
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
        } else {
            switch locationSegment.selectedSegmentIndex {
            case 0:
                type = "bars"
                performSegueWithIdentifier("landingSegue", sender: self)
            case 1:
                type = "clubs"
                performSegueWithIdentifier("landingSegue", sender: self)
            case 2:
                type = "restaurants"
                performSegueWithIdentifier("landingSegue", sender: self)
            default:
                type = "restaurants"
                performSegueWithIdentifier("landingSegue", sender: self)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("goToResults", object: self)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groupArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(groupArray[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupText.text = String(groupArray[row])
        groupText.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupText.layer.cornerRadius = 5
        groupText.layer.borderWidth = 1.0

        // Do any additional setup after loading the view.
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupText.inputView = groupPickerView
        groupPickerView.selectRow(4, inComponent: 0, animated: true)
        
        // Get password from Keychain to authenticate session
        var user = ""
        if let username = defaults.stringForKey("username") {
            user = username
        } else {
            user = defaults.stringForKey("email")!
        }
        let service = NSBundle.mainBundle().bundleIdentifier
        let (dict, loadError) = Locksmith.loadDataForUserAccount(user, inService: service!)
        if loadError != nil {
            println("Keychain load error: \(loadError)")
        }
        // instantiate login view controller to control login and start session with server
        let loginVC = LoginViewController()
        
//        if let provider = defaults.stringForKey("provider") {
//            println("Provider: \(provider)")
//            if provider == "facebook" {
//                FBSDKLoginManager.renewSystemCredentials({result, error -> Void in
//                    println("Renew result: \(result)")
//                    if error != nil {
//                        println(error)
//                    }
//                })
//            }
//        }
        groupText.resignFirstResponder()
        
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            let curDate = NSDate()
            let expDate = fbAccessToken.expirationDate
            let calendar = NSCalendar.currentCalendar()
            let unit = NSCalendarUnit.CalendarUnitDay
            let time = calendar.components(unit, fromDate: curDate, toDate: expDate, options: nil)
            if time.day < 30 {
                FBSDKAccessToken.refreshCurrentAccessToken({connection, result, error in
                    if error != nil {
                        println("Token Refresh Error: \(error)")
                    }
                })
            }
        }
        
        if let pass = dict?.valueForKey("password") as? String {
            let password  = pass as String
            println("Current password: \(password)")
            loginVC.login(user, password: password){
                (result: Bool, id: String) in
                if result {
                    println("Logged in successfully. Welcome!")
                } else {
                    println("Login failed from Home VC")
                    // log user out of facebook on failure
                    if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                        let fbLoginManager = FBSDKLoginManager()
                        fbLoginManager.logOut()
                    }
                    self.performSegueWithIdentifier("startSegue", sender: self)
                }
            }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "landingSegue" {
            
            let barVC = segue.destinationViewController as! BarViewController
            barVC.groupSize = groupText.text.toInt()
            barVC.age = defaults.integerForKey("age")
            if let city = defaults.stringForKey("city") {
                barVC.city = city
            } else {
                barVC.city = "Basel"
            }
            barVC.price = priceSegment.selectedSegmentIndex + 1 // database uses 1, 2, 3 instead of 0, 1, 2
            barVC.type = type
        }
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
