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

class SetLocationVC: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var initialLocation: CLLocation!
    
    var geoCoder: CLGeocoder!
    
    var isSearching = false
    var searchIsRunning = false
    
    var addJobVC: AddJobVC!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mapView.delegate = self
        
        initialLocation = CLLocation(latitude: 37.332308, longitude: -122.030733)
        setAnnotation("Current Location", subTitle: "", coordinate: initialLocation.coordinate)
        setOverlay(initialLocation.coordinate)
        moveMapToLocation(initialLocation)
        
        initializeSearch()
        
        //searchIconMakeDragable()
        
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
    func searchLocation(keyword: String){
        
        
        if keyword.characters.count < 1 {
            self.searchIsRunning = false
            return
        }
        
        self.addJobVC.searchedPlaces = [MKMapItem]() // reset
        self.addJobVC.searchedPlacesTV.reloadData()
        
        getPlacesFromGoogleAPI(keyword) { (places) -> Void in // google search if available
            
            if places != nil { // success
                
                self.addJobVC.searchedPlaces = places!
                
                self.searchIsRunning = false
                
                backgroundThread(0.0, background: nil, completion: { () -> Void in
                    
                    self.addJobVC.searchedPlacesTV.reloadData()
                    
                    if self.isSearching {
                        self.addJobVC.showSearchedPlacesTV()
                    }
                    
                })
                
                
            }else{ // error
                
                
                getPlacesFromLocalSearch(keyword, completion: { (places) -> Void in // local search without internet
                    
                    self.searchIsRunning = false
                    
                    if places != nil { // success
                        self.addJobVC.searchedPlaces = places!
                        
                        backgroundThread(0.0, background: nil, completion: { () -> Void in
                            
                            self.addJobVC.searchedPlacesTV.reloadData()
                            
                            if self.isSearching {
                                self.addJobVC.showSearchedPlacesTV()
                            }
                            
                        })
                        
                        
                    }else{ // error
                        
                        iLog("getPlacesFromLocalSearch error.")
                        
                        self.addJobVC.searchedPlacesTV.reloadData()
                        
                        if self.isSearching {
                            self.addJobVC.showSearchedPlacesTV()
                        }
                        
                    }
                    
                })
                
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
    
    func initializeSearch(){
        
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = true // set not to follow constraints
        searchBar.returnKeyType = UIReturnKeyType.Search
        searchBar.showsCancelButton = true
        
        var cancelButton: UIButton
        let topView: UIView = searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKindOfClass(NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitle("Done", forState: UIControlState.Normal)
            }
        }
        
    }
    
    func resetSearch(){
        searchBar.text = ""
        searchEnd()
    }
    
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
                
                self.searchBar.text = ""
                
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

        if searchIsRunning {return}
        
        searchIsRunning = true
        backgroundThread(0.5, background: nil) { () -> Void in
            
            self.searchLocation(searchBar.text!)
            
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchIsRunning {return}
        
        searchIsRunning = true
        backgroundThread(0.2, background: nil) { () -> Void in
            
            self.searchLocation(searchBar.text!)
            
        }
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //searchEnd()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchLocation(searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchEnd()
    }
    
    // mapkit methods

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = appGreenColor
            circle.fillColor = UIColor.lightTextColor()
            circle.lineWidth = 1.5
            return circle
        }else{
            return MKOverlayRenderer(overlay: overlay)
        }
        
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        view.draggable = true
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        iLog("oldState: \(oldState.hashValue) | newState: \(newState.hashValue) | ")
        
        if newState.hashValue == 1 || newState.hashValue == 2 { // annotation will up
            
            backgroundThread(0.0, background: nil, completion: { () -> Void in
                self.mapView.removeOverlays(self.mapView.overlays) // remove all old
            })
            
        }else if newState.hashValue == 4 || newState.hashValue == 0 { // annotation will down
            self.setOverlay(view.annotation!.coordinate)
        }
        
        self.setOverlay(view.annotation!.coordinate)
        
    }

    func setCamera(coordinate: CLLocationCoordinate2D){
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setOverlay(coordinate: CLLocationCoordinate2D){
        self.mapView.removeOverlays(self.mapView.overlays) // remove all old
        let circle = MKCircle(centerCoordinate: coordinate, radius: 50)
        self.mapView.addOverlay(circle)
    }
    func setAnnotation(title: String?, subTitle: String?, coordinate: CLLocationCoordinate2D){
        self.mapView.removeAnnotations(self.mapView.annotations) // remove all old
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if title != nil {
            annotation.title = title
        }
        if subTitle != nil {
            annotation.subtitle = subTitle
        }
        self.mapView.addAnnotation(annotation)
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
