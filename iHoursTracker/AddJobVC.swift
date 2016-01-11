//
//  AddJobVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit
import MapKit

class AddJobVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var searchedPlacesTV: UITableView!
    @IBOutlet weak var jobName: ITextField!
    @IBOutlet weak var rateValue: ITextField!
    @IBOutlet weak var rateType: UIPickerView!
    
    @IBOutlet weak var locationSegmentControl: UISegmentedControl!
    @IBOutlet weak var addJobBtn: UIButton!
    
    @IBOutlet weak var locationContainerView: UIView!
    var locationContainerVC: SetLocationVC!
    
    static let rateTypeData = ["Daily", "Weekly", "Monthly", "Hourly", "Quarterly", "Yearly"]
    
    var searchedPlaces = [MKMapItem]()
    
    var searchedPlacesTVOrignalFrame: CGRect!
    var isSeenSearchedPlacesTV = false
    
    var isAnimateSearchedPlacesTV = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addJobBtn.setCornerRadiusRound(2.0)
        rateType.selectRow(3, inComponent: 0, animated: true)
        setLocationContainerViewHide()
        
        searchedPlacesTV.translatesAutoresizingMaskIntoConstraints = true
        searchedPlacesTV.frame.origin.y = self.locationContainerView.frame.origin.y
        
        locationSegmentControlStateChanged(self.locationSegmentControl) // set according to current selected segment
        
        jobName.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.Default, isRequired: true)
        rateValue.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.NumberPad, isRequired: true)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GeoFencing.sharedObj.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        GeoFencing.sharedObj.locationManager.stopUpdatingLocation()
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getSearchedPlacesTVOrignalFrame()
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AddJobVC.rateTypeData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AddJobVC.rateTypeData[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Chalkboard SE", size: 14)
            pickerLabel?.textColor = appGreenColor
            pickerLabel?.textAlignment = .Center
        }
        pickerLabel?.text = AddJobVC.rateTypeData[row]
        
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

    
    @IBAction func addJobBtnPressed(sender: UIButton) {
        
        if !self.view.validateAllTextFields() {
            return
        }
        
        iLog("ready to go.")
        
        let jobRateAsFloat = rateValue.text?.convertToFloat()
        
        if jobRateAsFloat == nil { iLog("error jobRateAsFloat: \(jobRateAsFloat)"); return }
    
        let locationRadius = Float(self.locationContainerVC.currentRadius)
        
        let rateTypeIndex = rateType.selectedRowInComponent(0)
        
        iLog("New Job Going To Add, \(jobName.text!) | \(jobRateAsFloat!) | \(rateTypeIndex) | \(self.locationContainerVC.currentAnnotationCoordinate) | \(locationRadius)")
        
        let isError = DB.addJob(jobName.text!, rate: jobRateAsFloat!, rateType: rateTypeIndex, locationCordinate: self.locationContainerVC.currentAnnotationCoordinate, radius: locationRadius)
    
        if isError != nil {
            iLog("isError: \(isError)")
            return
        }
        
        //DB.logJobs()
        
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
        
        let place = self.searchedPlaces[indexPath.row]
        
        
        cell.backgroundColor = UIColor.grayColor()
        
        var displayName = ""
        
        if place.name != nil {
            displayName = "\(place.name!)"
        }
        
//        if place.vicinity != nil {
//            displayName = "\(displayName), \(place.vicinity!)"
//        }
        
        if place.formattedAddress != nil {
            displayName = "\(displayName), \(place.formattedAddress!)"
        }
        
        
        cell.textLabel?.text = displayName
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont(name: cell.textLabel!.font.fontName, size: 10.0)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        cell?.textLabel?.textColor = appGreenColor
        
        let item = self.searchedPlaces[indexPath.row]
        
        self.locationContainerVC.currentPlace = item
        
        self.locationContainerVC.moveMapToLocation(CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
        
        
        self.locationContainerVC.setCamera(item.placemark.coordinate)
        self.locationContainerVC.setAnnotation(item.name, subTitle: item.formattedAddress, coordinate: item.placemark.coordinate)
        self.locationContainerVC.currentRadius = kDefaultRadiusForNewPlace
        self.locationContainerVC.radiusSlider.value = self.locationContainerVC.radiusSlider.maximumValue / 2.0
        self.locationContainerVC.oldRadiusSliderValue = self.locationContainerVC.radiusSlider.value
        self.locationContainerVC.setOverlay(item.placemark.coordinate)
        
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        cell?.textLabel?.textColor = UIColor.whiteColor()
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if isAnimateSearchedPlacesTV {
            cell.layer.transform = CATransform3DMakeScale(0.5,0.5,1)
            UIView.animateWithDuration(0.4, animations: {
                cell.layer.transform = CATransform3DMakeScale(1,1,1)
                },completion: { finished in
                    
            })
        }else{
            cell.alpha = 0.0
            UIView.animateWithDuration(0.5, animations: {
                cell.alpha = 1.0
                },completion: { finished in
                    
            })
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.locationContainerVC.searchBar.resignFirstResponder() // hide keyboard when scroll search results
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.isAnimateSearchedPlacesTV = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isAnimateSearchedPlacesTV = false
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
