//
//  AddJobVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit
import MapKit

class AddJobVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var searchedPlacesTV: UITableView!
    @IBOutlet weak var jobName: ITextField!
    @IBOutlet weak var rateValue: ITextField!
    @IBOutlet weak var rateType: UIPickerView!
    
    @IBOutlet weak var locationSegmentControl: UISegmentedControl!
    @IBOutlet weak var addJobBtn: UIButton!
    
    @IBOutlet weak var locationContainerView: UIView!
    var locationContainerVC: SetLocationVC!
    
    let rateTypeData = ["Hourly", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly"]
    
    var searchedPlaces = [MKMapItem]()
    
    var searchedPlacesTVOrignalFrame: CGRect!
    var isSeenSearchedPlacesTV = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addJobBtn.setCornerRadiusRound(2.0)
        rateType.selectRow(3, inComponent: 0, animated: true)
        setLocationContainerViewHide()
        
        searchedPlacesTV.translatesAutoresizingMaskIntoConstraints = true
        searchedPlacesTV.frame.origin.y = self.locationContainerView.frame.origin.y
        
    }
    
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getSearchedPlacesTVOrignalFrame()
        
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
        pickerLabel?.text = rateTypeData[row]
        
        return pickerLabel!
    }
    
    @IBAction func locationSegmentControlStateChanged(sender: UISegmentedControl) {
        iLog("\(__FUNCTION__), selectedSegmentIndex: \(sender.selectedSegmentIndex)")
        
        if sender.selectedSegmentIndex == 0 {
            setLocationContainerViewShow()
        }else if sender.selectedSegmentIndex == 1 {
            setLocationContainerViewHide()
        }
        
    }

    
    
    
    
    
    
    
    func setLocationContainerViewHide(){
        
        self.locationContainerView.translatesAutoresizingMaskIntoConstraints = true
        self.locationContainerVC.mapView.translatesAutoresizingMaskIntoConstraints = true
        
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.locationContainerVC.mapView.frame.size.height = 0.0
            self.locationContainerVC.view.layoutIfNeeded()
            
            self.locationContainerView.frame.size.height = 0.0
            self.view.layoutIfNeeded()
            

            
            }) { (bool) -> Void in // animation completed
                
                self.locationContainerVC.resetSearch()
            
        }
        
        
    }
    
    func setLocationContainerViewShow(){
        
        locationContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.locationContainerVC.mapView.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()

            self.locationContainerVC.view.layoutIfNeeded()
            
            }) { (bool) -> Void in
                self.locationContainerVC.viewWillAppear(true)
        }
        
    }
    
    
    
    // searched places table view methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.grayColor()
        cell.textLabel?.text = self.searchedPlaces[indexPath.row].name
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.searchedPlaces[indexPath.row]
        
        self.locationContainerVC.mapView.centerCoordinate = item.placemark.coordinate
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.layer.transform = CATransform3DMakeScale(0.5,0.5,1)
        UIView.animateWithDuration(0.4, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            },completion: { finished in
                
        })
        
    }
    
    func getSearchedPlacesTVOrignalFrame(){
        self.searchedPlacesTVOrignalFrame = self.searchedPlacesTV.frame
    }
    func setSearchedPlacesTVOrignalFrame(){
        self.searchedPlacesTV.frame = self.searchedPlacesTVOrignalFrame
    }
    
    func showSearchedPlacesTV(){
        if isSeenSearchedPlacesTV || self.searchedPlaces.count < 1 { return }
        
        isSeenSearchedPlacesTV = true
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0.2, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            self.searchedPlacesTV.frame.origin.y = self.topTitle.frame.maxY
            self.searchedPlacesTV.frame.size.height = self.locationContainerView.frame.origin.y - self.topTitle.frame.maxY
            
            }) { (bool) -> Void in
                
                
        }

        
    }
    func hideSearchedPlacesTV(){
        if !isSeenSearchedPlacesTV { return }
        
        isSeenSearchedPlacesTV = false
        
        UIView.animateKeyframesWithDuration(0.3, delay: 0.2, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            
            self.setSearchedPlacesTVOrignalFrame()
            
            }) { (bool) -> Void in
                
                
        }
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "GotoSetLocationVC"{
            if let _vc = segue.destinationViewController as? SetLocationVC{
                locationContainerVC = _vc
                locationContainerVC.addJobVC = self
            }
        }
        
    }
    

}
