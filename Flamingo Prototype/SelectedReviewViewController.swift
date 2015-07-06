//
//  SelectedReviewViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 7/1/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class SelectedReviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var contentView: UITextView!
    var review: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        let title = review["title"] as! String
        let content = review["content"] as! String
        let rating = review["rating"] as! Int
        titleLabel.text = title
        contentView.text = content
        ratingView.image = UIImage(named: "Dice \(rating)")
        
        contentView.scrollEnabled = false // this forces the text view to resize to fit the entire text
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