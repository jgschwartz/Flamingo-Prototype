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
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
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
//    
//    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
//        if let stringUrl = imageUrl {
//            if let url = NSURL(string: stringUrl) {
//                if let data = NSData(contentsOfURL: url) {
//                    let image = UIImage(data: data)
//                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
//                    var initials = "Anon"
//                    if let firstname = defaults.stringForKey("firstname") {
//                        let lastname = defaults.stringForKey("lastname")
//                        initials = firstname.substringToIndex(1) + lastname?.substringToIndex(1)
//                    }
//                    let avatarImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
//                    avatars[name] = avatarImage
//                    return
//                }
//            }
//        }
//    
//        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
//        setupAvatarColor(name, incoming: incoming)
//    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = count(name)
//        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(3, nameLength)))
        var initials = "Anon"
        if let firstname = defaults.stringForKey("firstname") {
            let lastname = defaults.stringForKey("lastname")!
            initials = String(firstname[firstname.startIndex]) + String(lastname[lastname.startIndex])
        }
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationItem.title = "\(locationName)"
        groupsRef = Firebase(url: "https://startup-stuff.firebaseio.com/chatrooms/\(chatroom)/groups")
        
        // A way to track the accounts behind each message
        sender = defaults.stringForKey("username")
        sender = (sender != nil) ? sender : groupsRef.childByAutoId().key
        
        // See active groups and assign next number
//        println(groupsRef.parent)
//        println(groupsRef.parent.queryLimitedToLast(1).observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) in
//            
//            })
//        let lastGroup = groupsRef.valueForKey("Group 1")
//        if let lastGroup = groupsRef.queryOrderedByKey().queryLimitedToLast(1) {
//            // If no groups exist, groupName will default to Group 1
//            let lastArr = split(lastGroup) {$0 == " "} // Groups named as Group 1, Group 2, etc
//            let lastNum: Int = lastArr[1].toInt()!
//            groupName = "Group \(lastNum+1)"
//        }
        
        groupsRef.queryLimitedToLast(1).observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) in
            println("SNAPSHOT : \(snapshot)")

            if snapshot.childrenCount > 0 {
                println("CHILDREN: \(snapshot.children)")
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? FDataSnapshot {
                    let lastGroup = child.value.valueForKey("group") as! String
                    println("LASTGROUP: \(lastGroup)")
                    let lastArr = split(lastGroup) {$0 == " "} // Groups named as Group 1, Group 2, etc
                    println("LASTARR: \(lastArr)")
                    let lastNum: Int = lastArr[1].toInt()!
                    println("Group \(lastNum+1)")
                    self.groupName = "Group \(lastNum+1)"
                    println(self.groupName)
                    println("lastgroup: \(lastGroup)")
                }
                
                // If no groups exist, groupName will default to Group 1
//                for child in snapshot.children {
//                    let lastGroup = child.valueForKey("group") as! String
//                    let lastArr = split(lastGroup) {$0 == " "} // Groups named as Group 1, Group 2, etc
//                    let lastNum: Int = lastArr[1].toInt()!
//                    println("Group \(lastNum+1)")
//                    self.groupName = "Group \(lastNum+1)"
//                    println(self.groupName)
//                    println("lastgroup: \(lastGroup)")
//                }
            }
            self.addGroup()

            //            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            //            self.messages.append(message)
//            self.finishReceivingMessage()
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
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
//            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
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
}
