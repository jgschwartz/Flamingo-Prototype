//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    var groupSize: Int
    var groupName: String
    
//    convenience init(text: String?, sender: String?) {
//        self.init(text: text, sender: sender, groupSize:)
//    }
    
    init(text: String?, sender: String?, groupSize: Int?, group: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        if groupSize != nil {
            self.groupSize = groupSize!
        } else {
            self.groupSize = 0
        }
        self.groupName = group!
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }

    func date() -> NSDate! {
        return date_;
    }
//    
//    func groupSize() -> Int! {
//        return groupSize
//    }
//    
//    func groupName() -> String! {
//        return groupName
//    }
}