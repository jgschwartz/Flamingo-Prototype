//
//  HomeViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class StartViewController: CustomKoynViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let ageArray = [Int](13...100)
    var agePickerView: UIPickerView = UIPickerView()

    let cityArray = ["Basel"]
    var cityPickerView: UIPickerView = UIPickerView()
    
    let groupArray = [Int](1...20)
    var groupPickerView: UIPickerView = UIPickerView()
    
    var type: String!
    
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var groupText: UITextField!
    @IBOutlet weak var locationSegment: UISegmentedControl!
    @IBOutlet weak var priceSegment: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func go(sender: AnyObject) {
        println(locationSegment.highlighted)
        println(locationSegment.selectedSegmentIndex)
        if(ageText.text.isEmpty || cityText.text.isEmpty || groupText.text.isEmpty){
            let alertTitle = "Incomplete Form"
            var alertMessage = "You must fill out all sections to proceed."
            
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
        } else {
            switch locationSegment.selectedSegmentIndex {
            case 0:
                type = "bars"
                performSegueWithIdentifier("landingSegue", sender: self)
            case 1:
                type = "clubs"
                performSegueWithIdentifier("landingSegue", sender: self)
            case 2:
                type = "restaurants"
                performSegueWithIdentifier("landingSegue", sender: self)
            default:
                type = "restaurants"
                performSegueWithIdentifier("landingSegue", sender: self)
            }
        }
    }
    
    /* Picker Delegate Functions */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return ageArray.count
        } else if(pickerView.tag == 1){
            return cityArray.count
        } else {
            return groupArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(pickerView.tag == 0){
            return String(ageArray[row])
        } else if(pickerView.tag == 1){
            return cityArray[row]
        } else {
            return String(groupArray[row])
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0){
            ageText.text = String(ageArray[row])
            ageText.resignFirstResponder()
        } else if(pickerView.tag == 1) {
            cityText.text = String(cityArray[row])
            cityText.resignFirstResponder()
        } else {
            groupText.text = String(groupArray[row])
            groupText.resignFirstResponder()
        }
    }
    
    
    /* Text Field Delegate Functions */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonArray = [loginButton, signupButton, goButton]
        
//        for button in buttonArray {
////            button.backgroundColor = UIColor(red: 230/255, green: 210/255, blue: 170/255, alpha: 1);            button.setTitleColor(UIColor(red: 115/255, green: 0/255, blue: 10/255, alpha: 1), forState: UIControlState.Normal)
//            button.layer.cornerRadius = 5
//            button.layer.borderColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1).CGColor
//            button.layer.borderWidth = 1.0
//            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
////            button.layer.shadowColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1).CGColor
////            button.layer.shadowOffset = CGSize(width: 5, height: 5)
////            button.layer.shadowOpacity = 1
////            button.layer.shadowRadius = 5
//            button.sizeToFit()
//        }
        
        //        goingButton.layer.cornerRadius = 5
        //        goingButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //        goingButton.layer.borderColor = UIColor.blackColor().CGColor
        //        goingButton.layer.borderWidth = 1.0
        //        goingButton.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        //        goingButton.layer.shadowColor = UIColor.blackColor().CGColor
        //        goingButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        //        goingButton.layer.shadowOpacity = 1
        //        goingButton.layer.shadowRadius = 10

        
        /* Set up the picker views as input on the text fields */
        
        agePickerView.delegate = self
        agePickerView.dataSource = self
        agePickerView.tag = 0
        ageText.inputView = agePickerView
        groupPickerView.backgroundColor = UIColor.clearColor()
        agePickerView.selectRow(12, inComponent: 0, animated: false)

        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.tag = 1
        cityText.inputView = cityPickerView
        cityPickerView.backgroundColor = UIColor.clearColor()
        cityPickerView.selectRow(4, inComponent: 0, animated: false)
        
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        groupPickerView.tag = 2
        groupText.inputView = groupPickerView
        groupPickerView.backgroundColor = UIColor.clearColor()
        groupPickerView.selectRow(4, inComponent: 0, animated: false)
        
        ageText.layer.cornerRadius = 5
        cityText.layer.cornerRadius = 5
        groupText.layer.cornerRadius = 5
        ageText.layer.borderWidth = 1.0
        cityText.layer.borderWidth = 1.0
        groupText.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(animated: Bool) {
        // clear user defaults; will clear the session ID from an anonymous search
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "landingSegue" {
            let barVC = segue.destinationViewController as! BarViewController
            barVC.groupSize = groupText.text.toInt()
            barVC.age = ageText.text.toInt()
            barVC.city = cityText.text
            barVC.type = type
            barVC.price = priceSegment.selectedSegmentIndex + 1 // database uses 1, 2, 3 instead of 0, 1, 2
        }
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
