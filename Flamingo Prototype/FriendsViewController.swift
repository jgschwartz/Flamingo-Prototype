//
//  FriendsViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/19/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FriendsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    let defaults = NSUserDefaults.standardUserDefaults()
    var filteredFriendsArray = [String]()
    var namePicDict = Dictionary<String, UIImage?>()
    var nameidDict = Dictionary<String, String>()
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    var autoCompleteArray = [String]()
    var selected = Dictionary<String, UIImage?>()
    var parentVC: TabBarController!
    
    @IBAction func tagButton(sender: AnyObject) {
        if !selected.isEmpty {
            filteredFriendsArray = filteredFriendsArray.filter({$0 != self.textField.text})
            parentVC.taggedFriends.updateValue(selected.values.first!!, forKey: selected.keys.first!)
            selected.removeAll(keepCapacity: true)
        }
        autoCompleteArray.removeAll(keepCapacity: false)
        autoCompleteTableView.reloadData()
        textField.text = nil
    }
    
    @IBAction func removeTags(sender: AnyObject) {
        parentVC.taggedFriends.removeAll(keepCapacity: false)
        filteredFriendsArray = [String](nameidDict.keys)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        autoCompleteTableView!.hidden = false
        var substring = (self.textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        searchautoCompleteEntriesWithSubstring(substring)
        return true
    }
    
    func searchautoCompleteEntriesWithSubstring(substring: String)
    {
        autoCompleteArray.removeAll(keepCapacity: false)
        for friend in filteredFriendsArray
        {
            var myString: NSString! = friend.lowercaseString as NSString
            var substringRange: NSRange! = myString.rangeOfString(substring.lowercaseString)
            if (substringRange.location == 0)
            {
                autoCompleteArray.append(friend as String)
            }
        }
        
        autoCompleteTableView!.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let autoCompleteRowIdentifier = "autoCompleteRowIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier) as? UITableViewCell
        
        if let tempo1 = cell
        {
            let index = indexPath.row as Int
            let name = autoCompleteArray[index]
            cell!.textLabel!.text = name
            if let image = namePicDict[name] {
                cell!.imageView?.image = image
            }
        } else
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if let name = selectedCell.textLabel!.text {
            textField.text = name
            selected.removeAll(keepCapacity: true)
            selected.updateValue(selectedCell.imageView?.image, forKey: name)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
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
        
        parentVC = parentViewController as! TabBarController
        
        let params = ["fields": "context.fields(mutual_friends)"]
//        let params = ["fields": "friends"]

        
        println("friends view controller did load")
        
        var friendID = ""
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                println("fetched data: \(result)")
                let context: NSDictionary = result.valueForKey("context") as! NSDictionary
                let friends = context.valueForKey("mutual_friends") as! NSDictionary
                
//                let friends = result.valueForKey("friends") as! NSDictionary
                
                let data = friends.valueForKey("data") as! [NSDictionary]
                for friend in data {
                    if let friendName: String = friend["name"] as? String {
                        println(friendName) // name
                        self.nameidDict.updateValue(friend["id"] as! String, forKey: friendName)
                    }
                }
            }
            // restrict choices to those not already tagged
            self.filteredFriendsArray = [String](self.nameidDict.keys).filter({!contains(self.parentVC.taggedFriends.keys, $0)})
            self.graphForPicture()
        })

        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.scrollEnabled = true
        autoCompleteTableView.hidden = true
        self.view.addSubview(autoCompleteTableView)
        
        textField.delegate = self
    }
    
    func graphForPicture(){
        
        for (key, value) in nameidDict {
            let id = value
            let name = key
            let url = NSURL(string: "http://graph.facebook.com/\(id)/picture?type=small")
            var userData = NSDictionary()
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                var parseError: NSError?
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
                
                let pic = UIImage(data: data)
                self.namePicDict.updateValue(pic, forKey: name)
                println("Response: \((response as! NSHTTPURLResponse).statusCode)")
            }
            task.resume()
        }
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
