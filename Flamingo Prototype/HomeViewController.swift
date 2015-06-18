//
//  ProfileViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class HomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var groupText: UITextField!
    @IBOutlet weak var locationSegment: UISegmentedControl!
    
    let groupArray = [Int](1...20)
    var groupPickerView = UIPickerView()
    
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
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
                performSegueWithIdentifier("barSegue", sender: self)
            case 1:
                performSegueWithIdentifier("clubSegue", sender: self)
            case 2:
                performSegueWithIdentifier("restaurantSegue", sender: self)
            default:
                performSegueWithIdentifier("restaurantSegue", sender: self)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("goToResults", object: self)
    }
    
    @IBAction func signoutButton(sender: AnyObject) {
        signout("\(homeURL)signout")
        
        defaults.setValue(false, forKey: "loggedin")
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        defaults.removePersistentDomainForName(appDomain!)
    }

    func signout(sUrl: String){
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
        }
        
        // just a GET request
        let url = NSURL(string: sUrl)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var parseError: NSError?
//            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
//            if(json != nil){
//                println(json)
//            }
        }
        task.resume()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)

        // Do any additional setup after loading the view.
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupText.inputView = groupPickerView
        groupPickerView.selectRow(4, inComponent: 0, animated: true)
        
        let user = defaults.stringForKey("username")
        
//        // How to use Locksmith for Keychain
//        
//        let service = NSBundle.mainBundle().bundleIdentifier
//        let saveError = Locksmith.saveData(["username":user!], forUserAccount: user!, inService: service!)
//        if saveError != nil {
//            println(saveError)
//        }
//        let (dict, loadError) = Locksmith.loadDataForUserAccount(user!, inService: service!)
//        println(dict)
//        Locksmith.clearKeychain()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil ? contains(["barSegue", "clubSegue", "restaurantSegue"], segue.identifier!) : false {
            println("Segueing to LocationViewer")
            let locVC = segue.destinationViewController as! LocationViewController
            locVC.groupSize = groupText.text.toInt()
            locVC.age = 23
            locVC.city = "Basel"
            //        locVC.age = defaults.integerForKey("age")
            //        locVC.city = defaults.stringForKey("city")
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
