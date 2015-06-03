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
    
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var groupText: UITextField!
    
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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