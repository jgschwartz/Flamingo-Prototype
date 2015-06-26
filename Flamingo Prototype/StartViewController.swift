//
//  HomeViewController.swift
//  Flamingo Prototype
//
//  Created by Jared Schwartz on 5/30/15.
//  Copyright (c) 2015 Jared Schwartz. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let ageArray = [Int](18...100)
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
                performSegueWithIdentifier("tabSegue", sender: self)
            case 1:
                type = "clubs"
                performSegueWithIdentifier("tabSegue", sender: self)
            case 2:
                type = "restaurants"
                performSegueWithIdentifier("tabSegue", sender: self)
            default:
                type = "restaurants"
                performSegueWithIdentifier("tabSegue", sender: self)
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
        
        // Set background to gradient image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "FlamingoGradientPNG.png")?.drawInRect(self.view.bounds)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)

        /* Set up the picker views as input on the text fields */
        
        agePickerView.delegate = self
        agePickerView.dataSource = self
        agePickerView.tag = 0
        ageText.inputView = agePickerView
        groupPickerView.backgroundColor = UIColor.clearColor()
        agePickerView.selectRow(7, inComponent: 0, animated: false)

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
        if segue.identifier == "tabSegue" {
            let tabVC = segue.destinationViewController as! TabBarController
            tabVC.groupSize = groupText.text.toInt()
            tabVC.age = ageText.text.toInt()
            tabVC.city = cityText.text
            tabVC.type = type
            tabVC.price = priceSegment.selectedSegmentIndex + 1 // database uses 1, 2, 3 instead of 0, 1, 2
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
