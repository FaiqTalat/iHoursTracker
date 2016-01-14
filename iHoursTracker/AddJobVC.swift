//
//  AddJobVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 14/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit

class AddJobVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var jobName: ITextField!
    @IBOutlet weak var rateValue: ITextField!
    @IBOutlet weak var rateType: UIPickerView!
    @IBOutlet weak var addLocationBtn: UIButton!
    @IBOutlet weak var saveJobBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rateType.selectRow(3, inComponent: 0, animated: true)
        
        jobName.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.Default, isRequired: true)
        rateValue.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.NumberPad, isRequired: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rateTypeData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rateTypeData[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Chalkboard SE", size: 14)
            pickerLabel?.textColor = appGreenColor
            pickerLabel?.textAlignment = .Center
        }
        pickerLabel?.text = AddJobVC2.rateTypeData[row]
        
        return pickerLabel!
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
