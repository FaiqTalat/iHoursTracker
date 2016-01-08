//
//  SetLocationVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SetLocationVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var initialLocation: CLLocation!
    
    var geoCoder: CLGeocoder!
    
    var isSearching = false
    
    var addJobVC: AddJobVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initialLocation = CLLocation(latitude: 37.332308, longitude: -122.030733)
        moveMapToLocation(initialLocation)
        
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = true // set not to follow constraints
        searchBar.returnKeyType = UIReturnKeyType.Search
        searchBar.showsCancelButton = true
        
        searchIconMakeDragable()
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveMapToLocation(location: CLLocation){
        let regionRadius: CLLocationDistance = 1000
        let coordinate = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinate, animated: true)
    }

    
    // search a location from map
    func searchLocationFromMap(keyword: String){
        
        if keyword.characters.count < 1 {return}
        
        if geoCoder == nil { geoCoder = CLGeocoder() }
        
        
        
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = keyword
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchRes, error) -> Void in
            
            iLog("localSearchRes: \(localSearchRes)")
            
            if localSearchRes == nil {return}
            self.addJobVC.searchedPlaces = [MKMapItem]() // reset
            if let searchedItems = localSearchRes?.mapItems {
                self.addJobVC.searchedPlaces = searchedItems
                self.addJobVC.searchedPlacesTV.reloadData()
                self.addJobVC.showSearchedPlacesTV()
                
            }
            
            
        }
        
        
        
    }
    
    
    // search Icon Dragable
    func searchIconMakeDragable(){
        
        // for moving...
        let panGesture = UIPanGestureRecognizer(target: self, action: "touchMoved:")
        self.searchBtn.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapOnCircle")
        self.searchBtn.addGestureRecognizer(tapGesture)
        
    }
    func touchMoved(sender: UIPanGestureRecognizer){
        let location = sender.locationInView(self.view)
        self.searchBtn.center = location
        
    }
    func tapOnCircle(){
        searchToggle()
    }
    
    // searching...
    @IBAction func searchToggle() {
        
        isSearching = !isSearching

        if self.isSearching {
            searchStart()
        }else{
            searchEnd()
        }
        
    }
    
    func searchStart(){
        
        isSearching = true
        
        // animation
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.searchBar.frame.size.width = self.view.frame.width
            self.searchBar.alpha = 1.0
            
            }) { (bool) -> Void in
                
                self.searchBar.becomeFirstResponder()
                
        }
        
        
    }
    func searchEnd(){
        
        
        self.addJobVC.hideSearchedPlacesTV()
        
        isSearching = false
        
        // animation
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            
            self.searchBar.alpha = 0.0
            
            
            }) { (bool) -> Void in
                
                self.searchBar.frame.size.width = 0.0
                self.searchBar.resignFirstResponder()
                
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchLocationFromMap(searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchLocationFromMap(searchBar.text!)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //searchEnd()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchEnd()
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
