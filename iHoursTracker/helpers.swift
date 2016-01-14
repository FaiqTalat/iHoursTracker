//
//  helpers.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

var isAppLog = true
var statusBarTopView = UIView(frame: UIApplication.sharedApplication().statusBarFrame)

let appGreenColor = UIColor(red: 101.0/255.0, green: 178.0/255.0, blue: 137.0/255.0, alpha: 1.0)

let googleAPIKey = "AIzaSyA2bV8iPoGiZF_8ct2dmpTYbjhxHW9FaRQ"

let kDefaultRadiusForNewPlace = 100.0 // meter

func getPlacesFromGoogleAPI(address: String, completion: (places: [MKMapItem]?) -> Void){
    
    if !Reachability.isConnectedToNetwork() {
        iLog("Internet is not available!a")
        completion(places: nil)
        return
    }
    
    var urlString = "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=\(address)&key=\(googleAPIKey)"
    
    urlString = getUrlEncoded(urlString)
    
    let nsUrl = NSURL(string: urlString)
    
    if nsUrl == nil {
        completion(places: nil)
        return
    }
    
    showNetworkActivityIndicator()

    let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!) { (data, response, error) -> Void in
        hideNetworkActivityIndicator()
        if data != nil {
            
            
            parseQueryPlacesFromData(data!, completion: { (places) -> Void in
                
                if places.count > 0 {
                    completion(places: places)
                }else{
                    completion(places: nil)
                }
                
            })
            
        }else{
            completion(places: nil)
        }
        
        
    }
    // 5
    task.resume()
}

func parseQueryPlacesFromData(data : NSData, completion: (places: [MKMapItem])->Void) {
    
    var mapItems = [MKMapItem]()
    
    do{
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        let results = json["predictions"] as? Array<NSDictionary>
        print("results = \(results!.count)")
        
        if results?.count < 1 { completion(places: mapItems) }
        
        for result in results! {
            
            var description = result["description"] as? String
            
            if description == nil { description = "" }
            
            if let placeID = result["place_id"] as? String {
                
                getDetailPlaceFromPlaceID(placeID, completion: { (place) -> Void in
                    
                    if place != nil {
                        mapItems.append(place!)
                    }
                    
                    iLog("mapItems: \(mapItems)")
                    
                    completion(places: mapItems)
                    
                    
                })
                
                
                
            }
            
        }
        
    }catch{
        
    }
    
    
    
}

func getDetailPlaceFromPlaceID(placeID: String, completion: (place: MKMapItem?) -> Void){
    
    if !Reachability.isConnectedToNetwork() {
        iLog("Internet is not available!a")
        completion(place: nil)
        return
    }
    
    var urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=\(googleAPIKey)"
    
    urlString = getUrlEncoded(urlString)
    
    let nsUrl = NSURL(string: urlString)
    
    if nsUrl == nil {
        completion(place: nil)
        return
    }
    
    showNetworkActivityIndicator()
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!) { (data, response, error) -> Void in
        
        hideNetworkActivityIndicator()
        
        if data != nil {
            
            do{
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                
                if let result = json["result"] as? [String: AnyObject] {
                    
                    var coordinate : CLLocationCoordinate2D!
                    
                    if let geometry = result["geometry"] as? NSDictionary {
                        if let location = geometry["location"] as? NSDictionary {
                            let lat = location["lat"] as? CLLocationDegrees
                            let long = location["lng"] as? CLLocationDegrees
                            coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                            
                            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                            let mapItem = MKMapItem(placemark: placemark)
                            
                            mapItem.name = "Title Not Found."
                            
                            if let name = result["name"] as? String{
                                mapItem.name = "\(name)"
                            }
                            if let formattedAddress = result["formatted_address"] as? String{
                                mapItem.formattedAddress = "\(formattedAddress)"
                            }
                            if let vicinity = result["vicinity"] as? String{
                                mapItem.vicinity = "\(vicinity)"
                            }

                            
                            completion(place: mapItem)
                            return
                        }
                    }
                    
                }
                
                
            }catch{
                
            }

        }
        
        completion(place: nil)
        
    }
    
    // 5
    task.resume()
    
}

func getPlacesFromLocalSearch(address: String, completion: (places: [MKMapItem]?) -> Void){
    
    iLog("\(__FUNCTION__), address: \(address)")
    
    var searchedPlaces = [MKMapItem]()
    
    let localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = address
    let localSearch = MKLocalSearch(request: localSearchRequest)
    
    showNetworkActivityIndicator()
    localSearch.startWithCompletionHandler { (localSearchRes, error) -> Void in
        hideNetworkActivityIndicator()
        iLog("localSearchRes: \(localSearchRes), error: \(error)")
        
        if localSearchRes == nil || error != nil {
            completion(places: nil)
            return
        }
        
        if let searchedItems = localSearchRes?.mapItems {
            searchedPlaces = searchedItems
            completion(places: searchedPlaces)
        }else{
            completion(places: nil)
        }
        
    }
    
}

func getUrlEncoded(url: String) -> String{
    
    //let encodedUrl = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    
    let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    iLog("\(__FUNCTION__) | url: \(url) | encodedUrl: \(encodedUrl)")
    return encodedUrl!
}


func setTopStatusBarColor(color: UIColor){
    let delegate = UIApplication.sharedApplication().delegate
    let window = delegate?.window
    // set app status bar
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    statusBarTopView.backgroundColor = color
    window??.rootViewController!.view.addSubview(statusBarTopView)
    window??.makeKeyAndVisible()
}

func updateTopStatusBarFrame(){
    statusBarTopView.frame = UIApplication.sharedApplication().statusBarFrame
}


func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}


func iLog(data: AnyObject?){
    if isAppLog {
        print("iLog: time: \(currentTime())")
        
        if data != nil {
            print(data!)
        }else{
            print(data)
        }
        
        print("")
        
    }
}


func currentTime() -> String {
    let time = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle)
    return time
}

func showNetworkActivityIndicator(){
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
}
func hideNetworkActivityIndicator(){
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
}

extension NSDate {
    func getDateAsString()->String{
        let time = NSDateFormatter.localizedStringFromDate(self, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
        return time
    }
}

extension String {
    
    func convertToInt()->Int?{
        
        let asInt = Int(self)
        if asInt == nil { return nil }
        
        return asInt!
    }
    
    func convertToDouble()->Double?{
        
        let asDouble = Double(self)
        if asDouble == nil { return nil }
        
        return asDouble!
    }
    
    func convertToFloat()->Float?{
        
        let asFloat = Float(self)
        if asFloat == nil { return nil }
        
        return asFloat!
    }
    
    
}

extension UIView{
    func setCornerRadiusRound(cornerRadius: CGFloat){
        self.layer.cornerRadius = cornerRadius
    }
    
    func roundRadius(){
        self.layer.cornerRadius = self.frame.width / 2
    }
    func roundRadius(borderWidth: CGFloat){
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = borderWidth
    }
    func roundRadius(borderWidth: CGFloat, borderColor: UIColor){
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
    }
    
}

extension MKMapItem {
    
    private struct addresses {
        static var formatted_address: String?
        static var vicinity: String?
    }

    var formattedAddress: String? {
        get{
            return addresses.formatted_address
        }
        set{
            addresses.formatted_address = newValue
        }
    }
    
    var vicinity: String? {
        get{
            return addresses.vicinity
        }
        set{
            addresses.vicinity = newValue
        }
    }
    



}

public extension Double {
    func roundToDecimals(decimals: Int = 2) -> Double {
        let multiplier = Double(10^decimals)
        return round(multiplier * self) / multiplier
    }
}









// MARK: settings
let appStatusBarBgColor = UIColor(red: 83.0/255.0, green: 147.0/255.0, blue: 112.0/255.0, alpha: 1.0)

// public variables and constants
let appStatusBarView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))


// public methods
func appDefaults(){
    _log("\(__FUNCTION__)")
    
    let _app = UIApplication.sharedApplication()
    //let _appDelegate = UIApplication.sharedApplication().delegate
    let _window = UIApplication.sharedApplication().delegate?.window
    
    if let tabBarVC = _window??.rootViewController as? UITabBarController {
        rootTabBarVC = tabBarVC
    }
    
    setTopStatusBarColor(appGreenColor)
    
    // reset app badge number
    _app.applicationIconBadgeNumber = 0
    
    // start internet connectivity monitoring
    //Reachability.startReachability()
    
    DB.loadJobs()
    
    Notification.localNotify("1111")

    
    setAppStatusBar()
    
}

func setAppStatusBar(){
    _log("\(__FUNCTION__)")
    
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    appStatusBarView.backgroundColor = appStatusBarBgColor
    UIApplication.sharedApplication().delegate?.window??.rootViewController?.view.addSubview(appStatusBarView)
    UIApplication.sharedApplication().delegate?.window??.makeKeyAndVisible()
    
}



// helper func's
func _log(data: AnyObject?){
    if isAppLog {
        print("appLog: time: \(currentTime())")
        
        if data != nil {
            print(data!)
        }else{
            print(data)
        }
        
        print("")
        
    }
}

func getColorFromRGB(r: CGFloat,g: CGFloat,b: CGFloat)->UIColor{
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

// extensions

extension UIColor
{
    class func generate(red: Int, green: Int, blue: Int)->UIColor
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

// for custom menu button

class MenuIcon{
    var bar1: UIView!
    var bar2: UIView!
    var bar3: UIView!
    
    let bar1FrameOrignal: CGRect!
    let bar2FrameOrignal: CGRect!
    let bar3FrameOrignal: CGRect!
    let bgViewFrameOrignal: CGRect!
    
    let bgView: UIView!
    
    var state = 0
    
    init(bar1: UIView, bar2: UIView, bar3: UIView, bgView: UIView){
        self.bar1 = bar1
        self.bar2 = bar2
        self.bar3 = bar3
        self.bgView = bgView
        
        self.bar1FrameOrignal = bar1.frame
        self.bar2FrameOrignal = bar2.frame
        self.bar3FrameOrignal = bar3.frame
        self.bgViewFrameOrignal = bgView.frame
        
    }
    
    func _bar1Rotate315Degrees() {
        
        self.bar1.frame.size.width -= self.bar1.frame.size.width / 3
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.bar1.frame.origin.x = 14.7 + (self.bar1.frame.size.width / 3)
            self.bar1.frame.origin.y = 14.0 + 0.3
            self.bar1.transform = CGAffineTransformMakeRotation(315.01)
            
            }, completion: nil)
        
        
        
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.bgView.frame.origin.x = 50
            self.bgView.alpha = 1
            
            }, completion: nil)
        
        
    }

    
    func _bar3RotateMinus315Degrees() {
        
        self.bar3.frame.size.width -= self.bar3.frame.size.width / 3
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bar3.frame.origin.x = 14.7 + (self.bar3.frame.size.width / 3)
            self.bar3.frame.origin.y = 22.0 - 0.3
            self.bar3.transform = CGAffineTransformMakeRotation(-315.01)
            
            }, completion: nil)
        
    }
    
    
    func getBackToOrignalState() {
        


        
        UIView.animateWithDuration(0.1, animations: { () -> Void in // rotate
            
            self.bar1.transform = CGAffineTransformMakeRotation(0)
            self.bar3.transform = CGAffineTransformMakeRotation(0)
            
            
            }) { (_bool) -> Void in
                

                
                UIView.animateWithDuration(0.2, animations: { () -> Void in // set orignal origin's
                    
                    self.bar1.frame.origin = self.bar1FrameOrignal.origin
                    self.bar3.frame.origin = self.bar3FrameOrignal.origin
                    
                    self.bar1.frame.size.width = self.bar1FrameOrignal.width
                    self.bar3.frame.size.width = self.bar3FrameOrignal.width
                    
                    self.bgView.frame = self.bgViewFrameOrignal
                    self.bgView.alpha = 0
                    
                    }) { (_bool) -> Void in

                        
                }
                

                
                
                
                
                
        }
        
        
        
    }
    
    
    
    
    
    
}

extension UIView {
    
    func rotate315Degrees() {
        _log("\(self.frame.origin)")
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.frame.origin.x = 15
            self.frame.origin.y = 10
            
            self.transform = CGAffineTransformMakeRotation(315)
            
            //self.layoutIfNeeded()
            
            }, completion: nil)
        
    }
    
    func rotateMinus315Degrees() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.frame.origin.x = 15
            self.transform = CGAffineTransformMakeRotation(-315)
            //self.layoutIfNeeded()
            
            }, completion: nil)
        
    }
    
    func getBackToOrignalState(orignalFrame: CGRect) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            //self.frame = orignalFrame
            
            self.transform = CGAffineTransformMakeRotation(0)
            //self.layoutIfNeeded()
            
            }) { (_bool) -> Void in
                // self.frame.origin.x = 10
                
        }
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.frame.origin.x = 10
            self.frame.origin.y = 9
            
            }) { (_bool) -> Void in
                
                
        }
        
        
    }
    
    
    
    
}


