//
//  MessagesViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 7/6/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//  Borrowed from the Firechat-Swift project under the MIT license.

import UIKit
import Foundation

class GroupMessagesViewController: JSQMessagesViewController {

    var chatroom: String!
    var locationName: String!
    var city: String!
    var groupSelf: String!
    var groupOther: String!
    var groupSize: Int!
    var sessionID: String!
    var group2group: String!
    var parentVC: ContainerViewController!
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    var groupsRef: Firebase!
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = Firebase(url: "https://startup-stuff.firebaseio.com/chatrooms/\(chatroom)/group2group/\(group2group)")
        
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
            "group":groupSelf
            ])
    }
    
    func addGroup() {
        groupsRef.childByAutoId().setValue([
            "sender":sender,
            "group": groupSelf])
        println(groupSelf + " added")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatroom = (self.city + "-" + self.locationName).stringByReplacingOccurrencesOfString(" ", withString: "-")
        
        if groupSelf < groupOther {
            group2group = groupSelf + "-" + groupOther
        } else {
            group2group = groupOther + "-" + groupSelf
        }
        
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationItem.title = "You and \(groupOther)"
        groupsRef = Firebase(url: "https://startup-stuff.firebaseio.com/chatrooms/\(chatroom)/groups")
        
//        if (defaults.stringForKey("username") != nil){
//            sender = defaults.stringForKey("username")
//        } else if sessionID != nil {
//            sender = sessionID
//        } else {
//            sessionID = String(NSDate().hashValue)
//            sender = sessionID
//        }
//        colorArray = sorted(colorArray) {_, _ in arc4random() % 2 == 0} // shuffle array
        sender = groupSelf

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
        // Simulate receiving message
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
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
           // return UIImageView(image:avatars[message.sender()])
            return nil
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
