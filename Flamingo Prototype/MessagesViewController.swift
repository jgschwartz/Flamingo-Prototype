//
//  MessagesViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 6/16/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//  Borrowed from the Firechat-Swift project under the MIT license.

import UIKit
import Foundation

class MessagesViewController: JSQMessagesViewController {
    
//    var user: FAuthData?
    
    var chatroom: String!
    var locationName: String!
    var city: String!
    var groupName = "Group 1"
    var groupSize: Int!
    var sessionID: String!
    var parentVC: ContainerViewController!
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    var colorArray: [UIColor] = [
    UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1), // blue
    UIColor(red: 153/255, green: 51/255, blue: 255/255, alpha: 1), // purple
    UIColor(red: 204/255, green: 0/255, blue: 102/255, alpha: 1), // dark magenta
    UIColor(red: 0/255, green: 102/255, blue: 204/255, alpha: 1), // lighter blue
    UIColor(red: 153/255, green: 0/255, blue: 51/255, alpha: 1), // reddish-brown
    UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1), // forest green
    UIColor(red: 0/255, green: 102/255, blue: 102/255, alpha: 1), // sea blue
    UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1), // royal purple
    UIColor(red: 0/255, green: 0/255, blue: 153/255, alpha: 1), // royal blue
    UIColor(red: 153/255, green: 0/255, blue: 102/255, alpha: 1), // magenta
    UIColor(red: 102/255, green: 0/255, blue: 204/255, alpha: 1), // violet
    UIColor(red: 204/255, green: 51/255, blue: 0/255, alpha: 1), // burnt orange
    UIColor(red: 88/255, green: 218/255, blue: 132/255, alpha: 1), // light green
    UIColor(red: 255/255, green: 127/255, blue: 33/255, alpha: 1), // cleveland orange
    UIColor(red: 38/255, green: 124/255, blue: 201/255, alpha: 1), // sea blue
    UIColor(red: 25/255, green: 197/255, blue: 179/255, alpha: 1), // aquamarine
    UIColor(red: 28/255, green: 214/255, blue: 91/255, alpha: 1) // algae
    ]
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    var groupsRef: Firebase!
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = Firebase(url: "https://startup-stuff.firebaseio.com/chatrooms/\(chatroom)/main")
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.queryLimitedToFirst(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let text = snapshot.value["text"] as? String
            let sender = snapshot.value["sender"] as? String
            let groupSize = snapshot.value["groupSize"] as? Int
            let group = snapshot.value["group"] as? String
            
            let message = Message(text: text, sender: sender, groupSize: groupSize, group: group)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
    }
    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        messagesRef.childByAutoId().setValue([
            "text":text,
            "sender":sender,
            "group":groupName,
            "groupSize":groupSize
            ])
    }
    
    func addGroup() {
        groupsRef.childByAutoId().setValue([
            "sender":sender,
            "group": groupName,
            "groupSize": groupSize])
        println(groupName + " added")
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    var initials = split(groupName) {$0 == " "} [1] as String
                    let color = UIColor.blueColor()
//                    if let firstname = defaults.stringForKey("firstname") {
//                        let lastname = defaults.stringForKey("lastname")
//                        initials = firstname.substringToIndex(1) + lastname?.substringToIndex(1)
//                    }
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
    
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)

        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        var color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        let groupNum = split(name) {$0 == " "} [1].toInt()!
        color = colorArray[groupNum % colorArray.count]
        color = UIColor.blueColor()
        var initials = split(name) {$0 == " "} [1] as String
        
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatroom = (self.city + "-" + self.locationName).stringByReplacingOccurrencesOfString(" ", withString: "-")
        
//        performSegueWithIdentifier("groupMessageSegue", sender: self)
 //       println("segueing")

        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationItem.title = "\(locationName)"
        navigationController?.navigationBar.topItem?.title = "\(locationName)"
        title = "\(locationName)"
        groupsRef = Firebase(url: "https://startup-stuff.firebaseio.com/chatrooms/\(chatroom)/groups")
        
        if (defaults.stringForKey("username") != nil){
            sender = defaults.stringForKey("username")
        } else if sessionID != nil {
            sender = sessionID
        } else {
            sessionID = String(NSDate().hashValue)
            sender = sessionID
        }
        colorArray = sorted(colorArray) {_, _ in arc4random() % 2 == 0} // shuffle array
        var groupArray = [String]()
        var groupFound = false
        groupsRef.observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) in
            println("SNAPSHOT : \(snapshot)")
            let childrenCount = snapshot.childrenCount
            var curChild: UInt = 1
            if childrenCount > 0 {
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? FDataSnapshot {
                    let tempSender = child.value.valueForKey("sender") as! String
                    if self.sender == tempSender {
                        self.groupName = child.value.valueForKey("group") as! String
                        groupFound = true
                    } else {
                        let group = child.value.valueForKey("group") as! String
                        groupArray.append(group) // add all groups to array except self for group2group

                        if curChild == childrenCount && !groupFound { // NSEnumerator has no hasNext() function...
                            let lastGroup = child.value.valueForKey("group") as! String
                            let lastArr = split(lastGroup) {$0 == " "} // Groups named as Group 1, Group 2, etc
                            let lastNum: Int = lastArr[1].toInt()!
                            self.groupName = "Group \(lastNum+1)"
                            self.addGroup()
                        }
                    }
                    curChild += 1 // iterate to next child
                }
            } else {
                self.addGroup()
            }
            
            let tabbarVC = self.parentVC.parentViewController as! TabBarController
            tabbarVC.groupArray = groupArray
            tabbarVC.groupName = self.groupName
            println("ALL GROUPS: \(groupArray)")
        })
        
        setupFirebase()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ref != nil {
            ref.unauth()
        }
    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        println("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        let groupArray = split(message.groupName) {$0 == " "} // Groups named as Group 1, Group 2, etc
        let groupNum: Int = groupArray[1].toInt()!
        
        var color = colorArray[groupNum % colorArray.count] // mod to make sure no groupNum is outside of range
        let cicolor = CIColor(color: color)
//        println("\(message.groupName), \(groupNum)")
//        println("red: \(cicolor!.red() * 255), green: \(cicolor!.green() * 255), blue: \(cicolor!.blue() * 255)")
        
        incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(color)
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarColor(message.groupName, incoming: true)
            return UIImageView(image:avatars[message.sender()])
//            return nil
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
//        // Sent by me, skip
//        if message.sender() == sender {
//            let previousMessage = messages[indexPath.item - 1];
//            if previousMessage.sender() == message.sender() {
//                return nil;
//            } else {
//                
//            }
//        }
//        
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        let dem = message.groupSize > 1 ? "people" : "person"
        return NSAttributedString(string: "\(message.groupName), \(message.groupSize) \(dem)")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
//        // Sent by me, skip
//        if message.sender() == sender {
//            return CGFloat(0.0);
//        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "groupMessageSegue" {
            println("to group meßage")
            let groupVC = segue.destinationViewController as! GroupMessagesViewController
            groupVC.sessionID = sessionID
        }
    }
}
