//
//  TaggedFriendsTableViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/19/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class TaggedFriendsTableViewController: CustomKoynTableViewController {

    var taggedFriends = Dictionary<String, UIImage>()
    var taggedArray = [String]()
    var parentVC: BarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Friends Attending"
        
        taggedFriends = parentVC.taggedFriends
        
        taggedArray = [String](taggedFriends.keys)

//        tableView.contentInset.right = -15
//        tableView.contentInset.left = -15
//        tableView.separatorInset.left = 0
//        tableView.separatorInset.right = -15
//        tableView.contentInset = UIEdgeInsetsZero
//        tableView.separatorInset.left = 0
        tableView.separatorColor = UIColor.blackColor()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return taggedFriends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendReuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        let name = taggedArray[indexPath.row]
        cell.textLabel!.text = name
        cell.imageView?.image = taggedFriends[name]
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
