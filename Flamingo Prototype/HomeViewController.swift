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

    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var groupText: UITextField!
    
    let groupArray = [Int](1...20)
    var groupPickerView = UIPickerView()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func go(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("goToResults", object: self)
    }
    
    @IBAction func signoutButton(sender: AnyObject) {
        signout("https://thawing-garden-5169.herokuapp.com/signout")
        
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
        
        view.frame = CGRectMake(0.0, 0.0, view.bounds.width * 2, view.bounds.height * 2)
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor, UIColor.whiteColor().CGColor, UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor]
        blurEffect.layer.insertSublayer(gradient, atIndex: 1)
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = view.frame
        blurEffect.addSubview(effectView)

        // Do any additional setup after loading the view.
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupText.inputView = groupPickerView
        groupPickerView.selectRow(4, inComponent: 0, animated: true)
        
        let user = defaults.stringForKey("username")
        
//        let url = NSURL(string: "https://thawing-garden-5169.herokuapp.com/users/")
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
//            var parseError: NSError?
//                        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
//                        if(json != nil){
//                            println(json!["username"])
//                        }
//        }
//        task.resume()
        
        
        // How to use Locksmith for Keychain
        
//        let service = NSBundle.mainBundle().bundleIdentifier
//        let saveError = Locksmith.saveData(["username":user!], forUserAccount: user!, inService: service!)
//        if saveError != nil {
//            println(saveError)
//        }
//        let (dict, loadError) = Locksmith.loadDataForUserAccount(user!, inService: service!)
//        println(dict)
//        Locksmith.clearKeychain()
        
//        let kSecClassValue = NSString(format: kSecClass)
//        let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
//        let kSecValueDataValue = NSString(format: kSecValueData)
//        let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
//        let kSecAttrServiceValue = NSString(format: kSecAttrService)
//        let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
//        let kSecReturnDataValue = NSString(format: kSecReturnData)
//        let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
//        
//        let password: NSData = "password".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//        let service: String = (NSBundle.mainBundle().bundleIdentifier as? String)!
//        let userr: String = user!
//        let dict: NSDictionary = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: userr, kSecValueData: password]
//        let objects: NSArray = [kSecClassGenericPassword, service, user!, password]
//        let keys: NSArray = [kSecClass,kSecAttrService, kSecAttrAccount, kSecValueData]
//        let query = NSDictionary(objects: objects as [AnyObject], forKeys: keys as [AnyObject])
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
