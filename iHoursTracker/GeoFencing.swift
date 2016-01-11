//
//  GeoFencing.swift
//  Attendence
//
//  Created by Faiq Talat on 24/11/2015.
//  Copyright © 2015 Panacloud. All rights reserved.
//
import UIKit
import CoreLocation
import Foundation

let kNsUserDefaultsRegionKey = "GeoFencingRegions"

// region structure
struct RegionStruct {
    var jobID: String
    var location: GeoLocation
}
struct GeoLocation {
    var identifier: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var radius: CLLocationDistance
}

// class
class GeoFencing: NSObject, CLLocationManagerDelegate {

    static var regions = [String: RegionStruct]() // [jobID: region]
    private static var _regionsLoaded:Bool = false
    
    static var monitoringStarted: Bool = false
    
    static var authorizationStatus = false
    
    static var sharedObj = GeoFencing()
    let locationManager: CLLocationManager = CLLocationManager()
    
    let isLog = true
    var backgroundTaskHandlerID: UIBackgroundTaskIdentifier?
    
    var _isUnknownLocation = false
    var isAppAsActiveState = true
    
    var newLocation: CLLocation?
    var accurateLocationReceived = false
    var lastBackgroundTask: BackgroundTask?
    
    var lastBackgroundLimitHandler: BackgroundTask?
    static var lastInOROutGroupID: String?
    static var lastInOROutSubGroupID: String?
    var lastBgHandlerLimitExtendTimer: NSTimer?
    var userIsInRegion = true
    var isCheckInProcessIsRunning = false

    var callBackForLocationUpdatesHandler: ((CLLocation)->Void)?
    
    // static func's
    
    // first check is monitoring not available so alert
    class func canMonitoring(isAppRunning: Bool){
        
        let isMonitoringAvailable = CLLocationManager.isMonitoringAvailableForClass(CLRegion)
        let isAuthorizedForMonitoring = CLLocationManager.authorizationStatus()
        
        if isAppRunning { // app is running in normal state
            
            // monitoring not available for this hardware.
            if isMonitoringAvailable == false {
                let msg = "UnSupportedHardware: Your device is not supported. please do manual clockin or clockout"
                iLog(msg)
                Notification.notify("Warning!", msg: msg, showTime: 1.0)
            }
            
            // user not authorize for monitoring.
            if isAuthorizedForMonitoring != CLAuthorizationStatus.AuthorizedAlways && isAuthorizedForMonitoring != CLAuthorizationStatus.NotDetermined {
                let msg = "GotoSetting: Please Allow location services or do manual clockin or clockout"
                iLog(msg)
                Notification.notify("Warning!", msg: msg, showTime: 1.0)
            }
            
            // background app refresh is not on
            if UIApplication.sharedApplication().backgroundRefreshStatus != UIBackgroundRefreshStatus.Available {
                let msg = "GotoSetting: Please allow BackgroundAppRefresh or do manual clockin or clockout"
                iLog(msg)
                Notification.notify("Warning!", msg: msg, showTime: 1.0)
            }
            
        }else{ // app is in suspended state
            
            // monitoring not available for this hardware.
            if isMonitoringAvailable == false {
                let msg = "UnSupportedHardware: Your device is not supported. please do manual clockin or clockout"
                Notification.localNotify(msg)
            }
            
            // user not authorize for monitoring.
            if isAuthorizedForMonitoring != CLAuthorizationStatus.AuthorizedAlways {
                let msg = "GotoSetting: Please Allow location services or do manual clockin or clockout"
                Notification.localNotify(msg)
            }
            
            // background app refresh is not on
            if UIApplication.sharedApplication().backgroundRefreshStatus != UIBackgroundRefreshStatus.Available {
                let msg = "GotoSetting: Please allow BackgroundAppRefresh or do manual clockin or clockout"
                Notification.localNotify(msg)
            }
            
        }
        
    }
    
    
    class func startMonitoringForAllRegions(){
        _log(__FUNCTION__)
        
        GeoFencing.sharedObj.isAppAsActiveState = true
        monitoringStarted = true
        
        // alert if any thing not supported
        canMonitoring(true)
        
        // create class obj and save obj in sharedObj
        sharedObj = GeoFencing.sharedObj
        
    }
    
    class func startMonitoringForAllRegionsWhenAppSuspended(){
        _log(__FUNCTION__)
        
        GeoFencing.sharedObj.isAppAsActiveState = false
        monitoringStarted = true
        
        // alert if any thing not supported
        canMonitoring(false)
        
        // create class obj and save obj in sharedObj
        sharedObj = GeoFencing.sharedObj
        
    }
    
    class func stopMonitoringForAllRegions(){
        _log(__FUNCTION__)
        
        monitoringStarted = false
        
        // load all region one by one and stop monitoring for each region
        for region in sharedObj.locationManager.monitoredRegions {
            _log("Region: \(region)")
            sharedObj.locationManager.stopMonitoringForRegion(region)
        }
        
        // reset array also
        regions = [String: RegionStruct]()
        
    }
    
    class func refreshRegions(){
        for region in sharedObj.locationManager.monitoredRegions {

            sharedObj.locationManager.requestStateForRegion(region)
            
        }
    }
    
    class func addRegion(region: RegionStruct) {
        _log(__FUNCTION__)
        
        let isAuthorizedForMonitoring = CLLocationManager.authorizationStatus()
        
        // first time region adding so ask permition
        if isAuthorizedForMonitoring == CLAuthorizationStatus.NotDetermined {
            sharedObj.locationManager.requestAlwaysAuthorization()
            sharedObj.locationManager.requestWhenInUseAuthorization()
        }
        
        let newRegionID = region.jobID
        
        // for geofencing monitoring
        let clRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.location.latitude, longitude: region.location.longitude), radius: region.location.radius, identifier: newRegionID)
        // start monitoring
        sharedObj.locationManager.startMonitoringForRegion(clRegion)
        
        // add in array
        regions[newRegionID] = region
        
        iLog("")
        _log("<<<<<<<<<<<<--Monitored Regions------------")
        _log("\(sharedObj.locationManager.monitoredRegions)")
        _log("--------------Monitored Regions---->>>>>>>>")
        iLog("")
    }
    
    class func removeRegion(jobID: String) {
        _log(__FUNCTION__)
        
        let newRegionID = jobID
        
        if regions[newRegionID] != nil { // if exist
            
            let region = regions[newRegionID]!
            let clRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.location.latitude, longitude: region.location.longitude), radius: region.location.radius, identifier: newRegionID)
            
            // stop monitoring
            sharedObj.locationManager.stopMonitoringForRegion(clRegion)
            
            // remove from array
            regions.removeValueForKey(newRegionID)
        }
        
        iLog("")
        _log("<<<<<<<<<<<<--Monitored Regions------------")
        _log("\(sharedObj.locationManager.monitoredRegions)")
        _log("--------------Monitored Regions---->>>>>>>>")
        iLog("")
    }
    
    
    class func getNewLocationUpdates( newLocationReceived: (location: CLLocation)->Void ){
        self.sharedObj.callBackForLocationUpdatesHandler = newLocationReceived
    }
    
    // object func's (monitoring corelocation delegate methods)
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        
        // when app is opened and first time start so if user in auto in
        let isAuthorizedForMonitoring = CLLocationManager.authorizationStatus()
        
        // first time region adding so ask permition
        if isAuthorizedForMonitoring == CLAuthorizationStatus.NotDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()

    }
    
    // alert if not possible to monitor
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.NotDetermined {
            GeoFencing.canMonitoring(true)
        }
        if status == CLAuthorizationStatus.AuthorizedAlways {
            GeoFencing.authorizationStatus = true
        }else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            GeoFencing.authorizationStatus = true
        }else{
//            GeoFencing.authorizationStatus = false
        }
        
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        // start updating location for accuracy in or out
        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
            // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
            
            if self.isLog { Notification.localNotify("didEnterRegion: \(region.identifier)") }
            
            // set last bg task
            self.lastBackgroundTask = backgroundTask
            
            manager.startUpdatingLocation()
            
            self.lastBgHandlerLimitExtendTimer?.invalidate()
            //self.bgHandlerLimitExtend()
            
            // extend its background handler limit
            self.lastBgHandlerLimitExtendTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "bgHandlerLimitExtend", userInfo: nil, repeats: true)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
   
        if self.lastBackgroundTask == nil {
            
            // start updating location for accuracy in or out
            BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
                // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
                
                if self.isLog { Notification.localNotify("didExitRegion: \(region.identifier)") }
                
                // set last bg task
                self.lastBackgroundTask = backgroundTask
                self.lastBgHandlerLimitExtendTimer?.invalidate()
                //self.bgHandlerLimitExtend()
                // extend its background handler limit
                self.lastBgHandlerLimitExtendTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "bgHandlerLimitExtend", userInfo: nil, repeats: true)

                // do anything when its clockout
            
            }
        
        }
    
    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.callBackForLocationUpdatesHandler?(locations[0])
        
        if self.isAppAsActiveState { return }
        
        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
            // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second. it can take approx 3 to 4 mins
            
            
            
            
            let minimumAccuracy: CLLocationAccuracy = 30.0

                iLog("accurateLocationReceived: \(self.accurateLocationReceived)")
                if locations[0].horizontalAccuracy <= minimumAccuracy && !self.accurateLocationReceived { // within minimum accuracy so check in or out
                    self.accurateLocationReceived = true
                    
                    self.newLocation = locations[0] // set current accurate location
                    manager.stopUpdatingLocation()
                    
                    // start custom checkin process
                    self.isCheckInFromAnyRegion()
                }
                
                iLog("didUpdateLocations:")
                iLog("locations:")
                iLog("\(locations)")
                iLog("currentLocation: altitude:\(self.newLocation?.altitude), coordinate:\(self.newLocation?.coordinate), timestamp:\(self.newLocation?.timestamp), description:\(self.newLocation?.description), horizontalAccuracy:\(self.newLocation?.horizontalAccuracy), verticalAccuracy:\(self.newLocation?.verticalAccuracy)")
            
        }
        
    }
    
    func isCheckInFromAnyRegion(){
        iLog("\(__FUNCTION__)")
        
        if self.isCheckInProcessIsRunning == false {
            BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
                // MARK: custom checkin system
                for region in self.locationManager.monitoredRegions{ // each region
                    
                    let currentCLCircularRegion = region as! CLCircularRegion
                    let currentRegionLocation = CLLocation(latitude: currentCLCircularRegion.center.latitude, longitude: currentCLCircularRegion.center.longitude)
                    let distanceFromRegion = Double( self.newLocation!.distanceFromLocation(currentRegionLocation) )
                    iLog("distanceFromRegion: \(distanceFromRegion) , regionID: \(region.identifier)")

                    if distanceFromRegion <= Double(currentCLCircularRegion.radius + 160) { // in at region // added 160 meter for flexibility
                        iLog("in at regionID: \(region.identifier)")
                        
                        
                        // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
                        self.isCheckInProcessIsRunning = true
                        
                        //let jobID = region.identifier
                        
                        // clocked in
                        
                        
                        
                    }
                    
                    
                }
                
                
                // wait for some period because of region updating...
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    //put your code which should be executed with a delay here
                    // when no checkin found so reset state
                    if self.isCheckInProcessIsRunning == false {
                        self.accurateLocationReceived = false
                    }
                }
                
                
                
            }
            
        }
        
    }
    
    // private helpers methods
    
    private class func _log(data: String){
        iLog("Log: ")
        iLog(data)
    }
    
    
}




