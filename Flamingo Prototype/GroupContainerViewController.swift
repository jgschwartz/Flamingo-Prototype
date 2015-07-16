//
//  GroupContainerViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 7/15/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class GroupContainerViewController: CustomKoynViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSegue" {
            let gtVC = segue.destinationViewController as! GroupTableViewController
            gtVC.parentVC = parentViewController as! TabBarController
        }
    }


}
