//
//  ReviewViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/23/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var diceView: UIImageView!
    @IBOutlet weak var ratingSlider: UISlider!

    var parentVC: TabBarController!
    let placeholder = "Leave your review here."
    
    @IBAction func sliderAction(sender: UISlider) {
        let fVal = round(sender.value)
        ratingSlider.setValue(fVal, animated: true)
        
        let value = Int(round(sender.value))
        diceView.image = UIImage(named: "Trans Star Dice \(value)")
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        titleText.resignFirstResponder()
        reviewText.resignFirstResponder()
        
        let title = titleText.text
        let review = reviewText.text
        let rating = Int(round(ratingSlider.value))
        let emptyTitle = title.isEmpty
        let emptyReview = review.isEmpty
        if emptyTitle != emptyReview {
            alertSubmit("Invalid Content", message: "Both title and review must be filled out or left blank.")
        }
//        else if review.isEmpty {
//            alertSubmit("Missing Content", message: "You must leave some kind of message reviewing the location.")
//        }
        submitReview(title, review: review, rating: rating, completion: {
            (result: Bool, id: String) in
            if result {
                println("SUCCESSFUL REVIEW")
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.reviewText.text = nil
                    self.titleText.text = nil
                    self.alertSubmit("Review Submitted", message: "Thanks for helping us make this place better for users like you!")
                    let reviewDict = ["title": title, "content": review, "rating": rating]
                    self.parentVC.submittedReview(reviewDict)
                }
            } else {
                println("Failed to post review")
                self.alertSubmit("Error", message: "Sorry, there was a problem processing your review. Please try again.")
            }
        })
    }
    
    // Login function uses a POST request with username and password to confirm correct credentials
    func submitReview(title: String, review: String, rating: Int, completion: (result: Bool, id: String) -> Void){
        var err: NSError?
        var json: NSJSONSerialization?
        
        // Must be formatted as x-www-form-urlencoded and not JSON
        var params = "title=\(title)&content=\(review)&rating=\(rating)&barNameAndCity=\(parentVC.locationName) \(parentVC.city)"
        if let user = defaults.stringForKey("username") {
            params += "&user=\(user)"
        }
        var paramsLength = "\(count(params))"
        var requestBodyData = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        // Create request and parameters
        var url = NSURL(string: "\(homeURL)api/\(parentVC.type)/\(parentVC.locationID)/reviews")
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
                if httpResponse.statusCode == 200 {
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

//        if defaults.stringForKey("provider") != nil && defaults.stringForKey("provider") == "facebook" {
//            parentVC = parentViewController?.parentViewController as! TabBarController
//        } else {
//            parentVC = parentViewController as! TabBarController
//        }
        parentVC = parentViewController as! TabBarController
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: bgImageName)?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        diceView.layer.cornerRadius = 5
        diceView.layer.borderColor = UIColor.blackColor().CGColor
        diceView.layer.borderWidth = 1.0
        diceView.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        locationLabel.text = parentVC.locationName
        reviewText.text = placeholder
        reviewText.textColor = UIColor.lightGrayColor()
        reviewText.delegate = self
        reviewText.layer.cornerRadius = 5
        reviewText.layer.borderWidth = 1.0
        titleText.layer.cornerRadius = 5
        titleText.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGrayColor()
        }
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
