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
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var groupText: UITextField!
    @IBOutlet weak var locationSegment: UISegmentedControl!
    
    @IBAction func go(sender: AnyObject) {
        if(ageText.text.isEmpty || cityText.text.isEmpty || groupText.text.isEmpty || !locationSegment.highlighted)
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
        
        /* Create gradient layer for background and add it to the blur effect view */
        
        view.frame = CGRectMake(0.0, 0.0, view.bounds.width * 2, view.bounds.height * 2)
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor, UIColor.whiteColor().CGColor, UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1).CGColor]
        blurEffect.layer.insertSublayer(gradient, atIndex: 1)
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = view.frame
        blurEffect.addSubview(effectView)

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
