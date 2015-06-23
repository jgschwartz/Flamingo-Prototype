//
//  ReviewViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/23/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var reviewText: UITextView!
    
    var type : String!
    var locationName : String!
    var id : String!
    let homeURL = "https://thawing-garden-5169.herokuapp.com/"
    
    @IBAction func submitButton(sender: AnyObject) {
        let title = titleText.text
        let review = reviewText.text
        if title.isEmpty {
            alertSubmit("Missing Title", message: "Your review must have a title to be submitted.")
        } else if review.isEmpty {
            alertSubmit("Missing Content", message: "You must leave some kind of message reviewing the location.")
        }
        submitReview(title, review: review, rating: nil, completion: {
            (result: Bool, id: String) in
            println("SUCCESSFUL REVIEW")
        })
    }
    
    // Login function uses a POST request with username and password to confirm correct credentials
    func submitReview(title: String, review: String, rating: Int?, completion: (result: Bool, id: String) -> Void){
        var err: NSError?
        var json: NSJSONSerialization?
        
        // Must be formatted as x-www-form-urlencoded and not JSON
        var params = "title=\(title)&content=\(review)"
        var paramsLength = "\(count(params))"
        var requestBodyData = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create request and parameters
        var url = NSURL(string: "\(self.homeURL)api/\(type)/\(id)/reviews")
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
                
                //                println("Body: \(strData)")
                
                println("\n")
                
                println("Response: \(response)")
                
                let httpResponse = response as! NSHTTPURLResponse
                println(httpResponse.statusCode)
                let responseURL = httpResponse.URL?.absoluteString
                println(httpResponse.allHeaderFields["id"])
                let id = httpResponse.allHeaderFields["id"] as! String
                if httpResponse.statusCode == 200 && responseURL == url {
                    completion(result: true, id: id)
                } else {
                    completion(result: false, id: id)
                }
                
                var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves,  error: &err) as? NSDictionary
                println("JSON: \(json)")
                
            }
        })
        task.resume()
    }
    
    // function to send an alert on the screen when a user attempts to submit a review
    func alertSubmit(title: String, message: String){
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        locationLabel.text = locationName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
