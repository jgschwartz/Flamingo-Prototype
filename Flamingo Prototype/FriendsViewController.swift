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

    var filteredFriendsArray = [String]()
    var namePicDict = Dictionary<String, UIImage?>()
    var nameidDict = Dictionary<String, String>()
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    var autoCompleteArray = [String]()
    var selected = Dictionary<String, UIImage?>()
    var taggedFriends: Dictionary<String, UIImage>!
    @IBOutlet weak var finishedTaggingButton: UIButton!
    
    var lat: Double!
    var long: Double!
    var city: String!
    var locationID: String!
    var locationName: String!
    var groupSize: Int!
    var age: Int!
    var price: Int!
    var type: String!
    
    @IBAction func tagButton(sender: AnyObject) {
        if !selected.isEmpty {
            filteredFriendsArray = filteredFriendsArray.filter({$0 != self.textField.text})
            taggedFriends.updateValue(selected.values.first!!, forKey: selected.keys.first!)
            selected.removeAll(keepCapacity: true)
        }
        autoCompleteArray.removeAll(keepCapacity: false)
        autoCompleteTableView.reloadData()
        textField.text = nil
    }
    
//    @IBAction func removeTags(sender: AnyObject) {
//        taggedFriends.removeAll(keepCapacity: false)
//        filteredFriendsArray = [String](nameidDict.keys)
//    }
    
    
    
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
        cell?.backgroundColor = UIColor.clearColor()
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
//        cell?.contentView.layer.borderColor = UIColor.blackColor().CGColor
//        cell?.contentView.layer.borderWidth = 1.0
//        cell?.contentView.layoutMargins.left = -15
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if let name = selectedCell.textLabel!.text {
//            selectedCell.textLabel?.textColor = view.tintColor
            let fontsize = selectedCell.textLabel!.font.pointSize
            selectedCell.textLabel?.font = UIFont.boldSystemFontOfSize(fontsize + 3)
            selectedCell.backgroundColor = UIColor.clearColor()
            selectedCell.layer.backgroundColor = UIColor.clearColor().CGColor
            textField.text = name
            selected.removeAll(keepCapacity: true)
            selected.updateValue(selectedCell.imageView?.image, forKey: name)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if let name = selectedCell.textLabel!.text {
            selectedCell.textLabel?.textColor = UIColor.blackColor()
            let fontsize = selectedCell.textLabel!.font.pointSize
            selectedCell.textLabel?.font = UIFont.systemFontOfSize(fontsize - 3)
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
        UIImage(named: bgImageName)?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        autoCompleteTableView.backgroundColor = UIColor.clearColor()
        autoCompleteTableView.contentInset.left = -15
        autoCompleteTableView.layoutMargins = UIEdgeInsetsZero
        autoCompleteTableView.separatorInset = UIEdgeInsetsZero
        autoCompleteTableView.separatorColor = UIColor.blackColor()
        
        let params = ["fields": "context.fields(mutual_friends)"]
//        let params = ["fields": "friends"]

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
            self.filteredFriendsArray = [String](self.nameidDict.keys).filter({!contains(self.taggedFriends.keys, $0)})
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
            }
            task.resume()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let parentVC = parentViewController as? TabBarController {
            taggedFriends = parentVC.taggedFriends
            finishedTaggingButton.hidden = true
        } else {
            let stackSize = navigationController?.viewControllers.count
            if let parentVC = navigationController?.viewControllers[stackSize!-2] as? BarViewController {
                taggedFriends = parentVC.taggedFriends
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let parentVC = parentViewController as? TabBarController {
            parentVC.taggedFriends = taggedFriends
        } else {
            let stackSize = navigationController?.viewControllers.count
            if let parentVC = navigationController?.viewControllers[stackSize!-2] as? BarViewController {
                parentVC.taggedFriends = taggedFriends
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if !selected.isEmpty {
            filteredFriendsArray = filteredFriendsArray.filter({$0 != self.textField.text})
            taggedFriends.updateValue(selected.values.first!!, forKey: selected.keys.first!)
            selected.removeAll(keepCapacity: true)
        }
        autoCompleteArray.removeAll(keepCapacity: false)
        autoCompleteTableView.reloadData()
        textField.text = nil
        
        if segue.identifier == "mapSegue" {
            let mapVC = segue.destinationViewController as! MapViewController
            mapVC.city = city
            mapVC.locationID = locationID
            mapVC.locationName = locationName
            mapVC.groupSize = groupSize
            mapVC.lat = lat
            mapVC.long = long
            mapVC.type = type
            mapVC.age = age
            mapVC.price = price
            mapVC.taggedFriends = taggedFriends
        }
    }
}
