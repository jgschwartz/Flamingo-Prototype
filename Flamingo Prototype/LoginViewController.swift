//
//  LoginViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    var success = false

    // Go back to StartViewController when back button pressed
    @IBAction func backDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Login with username and password
    @IBAction func loginButton(sender: AnyObject) {
        let username = userText.text
        let password = passText.text
        
        userText.resignFirstResponder()
        passText.resignFirstResponder()
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            login(username, password: password) {
                (result: Bool) in
                println("Login successful: \(result)")
                self.success = result
                if(self.success){
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        // TODO: create cookie
                        let defaults = NSUserDefaults.standardUserDefaults()
                        if let user = defaults.stringForKey("user"){
                            println(user)
                        } else {
                            defaults.setValue(username, forKey: "user")
                            println("new user set")
                        }
                        self.performSegueWithIdentifier("successfulLogin", sender: self)
                    }
                } else {
                    self.alertBadLogin()
                    NSOperationQueue.mainQueue().addOperationWithBlock{
                        self.userText.text = nil
                        self.passText.text = nil
                    }
                }
            }
//        })
    }
    
    // On unsuccessful login, send alert telling them to try again
    func alertBadLogin(){
        if(NSClassFromString("UIAlertController") != nil){
            // iOS8 or later, AlertController exists
            var alert = UIAlertController(title: "Login Failed", message: "Your login failed due to bad credentials. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // iOS7 or earlier, must use AlertView
            let alert = UIAlertView()
            alert.title = "Login Failed"
            alert.message = "Your login failed due to bad credentials. Please try again."
            alert.addButtonWithTitle("Okay")
            alert.show()
        }
    }
    
    /* Text Field Delegate Functions */
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.autocorrectionType = UITextAutocorrectionType.No
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // Login function uses a POST request with username and password to confirm correct credentials
    func login(username: String, password: String, completion: (result: Bool) -> Void){
        var err: NSError?
        var json: NSJSONSerialization?
        
        // Must be formatted as x-www-form-urlencoded and not JSON
        var params = "username=\(username)&password=\(password)"
        var paramsLength = "\(count(params))"
        var requestBodyData = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create request and parameters
        var url = NSURL(string: "https://thawing-garden-5169.herokuapp.com/login")
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = requestBodyData
        request.addValue(paramsLength, forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Send request and parse response, send result to callback
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            if(error != nil){
                println("ERROR IS: \(error)")
            } else {
                
                println("Body: \(strData)")
                
                println("\n")
                
                println("Response: \(response)")
                
                if("\(strData)".rangeOfString("Hello") != nil){
                    completion(result: true)
                } else {
                    completion(result: false)
                }
                var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                println(json)
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        println(defaults.stringForKey("setKeyTest"))
        
        // Create gradient and add to blurEffect
        view.frame = CGRectMake(0.0, 0.0, view.bounds.width * 2, view.bounds.height * 2)
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor, UIColor.whiteColor().CGColor, UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor]
        blurEffect.layer.insertSublayer(gradient, atIndex: 1)
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = view.frame
        blurEffect.addSubview(effectView)
        
        userText.delegate = self
        passText.delegate = self
        
        passText.secureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("Memory?")
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
