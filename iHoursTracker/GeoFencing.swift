////
////  GeoFencing.swift
////  Attendence
////
////  Created by Faiq Talat on 24/11/2015.
////  Copyright © 2015 Panacloud. All rights reserved.
////
//import UIKit
//import CoreLocation
//import Foundation
//
//let kNsUserDefaultsRegionKey = "GeoFencingRegions"
//
//struct GeoLocation {
//    var identifier: String
//    var latitude: CLLocationDegrees
//    var longitude: CLLocationDegrees
//    var radius: CLLocationDistance
//}
//
////// interface
////protocol GeoFencingInterface {
////
////
////    // Properties
////    var regions:[String: RegionStruct]{get set} // [groupID_subGroupID: region]
////
////
////    // Methods
////
////    // Region: add or remove
////    static func addRegion(groupID: String, subGroupID: String, region: RegionStruct)
////    static func removeRegion(groupID: String, subGroupID: String)
////    // Monitoring: start or stop
////    static func startMonitoring()
////    static func stopMonitoring()
////
////}
//
//
//// class
//class GeoFencing: NSObject, CLLocationManagerDelegate {
//
//    private static var _regionsLoaded:Bool = false
//    
//    static var monitoringStarted: Bool = false
//    
//    static var authorizationStatus = false
//    
//    static var sharedObj = GeoFencing()
//    let locationManager: CLLocationManager = CLLocationManager()
//    
//    let isLog = true
//    var backgroundTaskHandlerID: UIBackgroundTaskIdentifier?
//    
//    var _isUnknownLocation = false
//    var isAppAsActiveState = true
//    
//    var newLocation: CLLocation?
//    var accurateLocationReceived = false
//    var lastBackgroundTask: BackgroundTask?
//    
//    var lastBackgroundLimitHandler: BackgroundTask?
//    static var lastInOROutGroupID: String?
//    static var lastInOROutSubGroupID: String?
//    var lastBgHandlerLimitExtendTimer: NSTimer?
//    var userIsInRegion = true
//    var isCheckInProcessIsRunning = false
//    
//    //let beacon1UUID = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
//    
//    
//    // static func's
//    
//    // first check is monitoring not available so alert
//    class func canMonitoring(isAppRunning: Bool){
//        
//        let isMonitoringAvailable = CLLocationManager.isMonitoringAvailableForClass(CLRegion)
//        let isAuthorizedForMonitoring = CLLocationManager.authorizationStatus()
//        
//        if isAppRunning { // app is running in normal state
//            
//            // monitoring not available for this hardware.
//            if isMonitoringAvailable == false {
//                let msg = "UnSupportedHardware:Your device is not supported For Automatic Attendace."
//                iLog(msg)
//                GeoFence.displayNotification("UnSupportedHardware:", msg: msg)
//            }
//            
//            // user not authorize for monitoring.
//            if isAuthorizedForMonitoring != CLAuthorizationStatus.AuthorizedAlways && isAuthorizedForMonitoring != CLAuthorizationStatus.NotDetermined {
//                let msg = "GotoSetting:Please Allow location services For Automatic Attendace."
//                iLog(msg)
//                GeoFence.displayNotification("GotoSetting:", msg: msg)
//            }
//            
//            // background app refresh is not on
//            if UIApplication.sharedApplication().backgroundRefreshStatus != UIBackgroundRefreshStatus.Available {
//                let msg = "GotoSetting:Please BackgroundAppRefresh to monitor your Attendance."
//                iLog(msg)
//                GeoFence.displayNotification("GotoSetting:", msg: msg)
//            }
//            
//        }else{ // app is in suspended state
//            
//            // monitoring not available for this hardware.
//            if isMonitoringAvailable == false {
//                let msg = "UnSupportedHardware:Your device is not supported For Automatic Attendace."
//                notification(msg)
//            }
//            
//            // user not authorize for monitoring.
//            if isAuthorizedForMonitoring != CLAuthorizationStatus.AuthorizedAlways {
//                let msg = "GotoSetting:Please Allow location services For Automatic Attendace."
//                notification(msg)
//            }
//            
//            // background app refresh is not on
//            if UIApplication.sharedApplication().backgroundRefreshStatus != UIBackgroundRefreshStatus.Available {
//                let msg = "GotoSetting:Please BackgroundAppRefresh to monitor your Attendance."
//                notification(msg)
//            }
//            
//        }
//        
//    }
//    
//    
//    class func startMonitoringForAllRegions(){
//        _log(__FUNCTION__)
//        
//        GeoFencing.sharedObj.isAppAsActiveState = true
//        monitoringStarted = true
//        
//        // alert if any thing not supported
//        canMonitoring(true)
//        
//        // create class obj and save obj in sharedObj
//        sharedObj = GeoFencing.sharedObj
//        
//    }
//    
//    class func startMonitoringForAllRegionsWhenAppSuspended(){
//        _log(__FUNCTION__)
//        
//        GeoFencing.sharedObj.isAppAsActiveState = false
//        monitoringStarted = true
//        
//        // alert if any thing not supported
//        canMonitoring(false)
//        
//        // create class obj and save obj in sharedObj
//        sharedObj = GeoFencing.sharedObj
//        
//    }
//    
//    class func stopMonitoringForAllRegions(){
//        _log(__FUNCTION__)
//        
//        monitoringStarted = false
//        
//        // load all region one by one and stop monitoring for each region
//        for region in sharedObj.locationManager.monitoredRegions {
//            _log("Region: \(region)")
//            sharedObj.locationManager.stopMonitoringForRegion(region)
//        }
//        
//        // reset array also
//        regions = [String: RegionStruct]()
//        
//    }
//    
//    class func refreshRegions(){
//        for region in sharedObj.locationManager.monitoredRegions {
//
//            sharedObj.locationManager.requestStateForRegion(region)
//            
//        }
//    }
//    
//    class func addRegion(region: RegionStruct) {
//        _log(__FUNCTION__)
//        if sharedObj.isAppAsActiveState == false {
//        //notification("\(__FUNCTION__) | \(region.groupID)_\(region.subGroupID) radius:\(region.location.radius), lat:\(region.location.latitude), long:\(region.location.longitude)")
//            
//            // for debuging...
//            Firebase(url: "https://wrk1.firebaseio.com/work1002/\(UIDevice.currentDevice().name)/addRegion").childByAutoId().setValue(["time": "\(currentTime())"], withCompletionBlock: { (err, firebase) -> Void in
//            })
//            
//        }
//        
//        let isAuthorizedForMonitoring = CLLocationManager.authorizationStatus()
//        // first time region adding so ask permition
//        if isAuthorizedForMonitoring == CLAuthorizationStatus.NotDetermined {
//            sharedObj.locationManager.requestAlwaysAuthorization()
//            sharedObj.locationManager.requestWhenInUseAuthorization()
//        }
//        
//        
//        let newRegionID = "\(region.groupID)_\(region.subGroupID)"
//        
//        // for geofencing monitoring
//        let clRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.location.latitude, longitude: region.location.longitude), radius: region.location.radius, identifier: newRegionID)
//        // start monitoring
//        sharedObj.locationManager.startMonitoringForRegion(clRegion)
//        
//        
////        // for beacon monitoring
////        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: sharedObj.beacon1UUID)!, major: 1, minor: 1, identifier: newRegionID)
////        sharedObj.locationManager.startMonitoringForRegion(beaconRegion)
//        
//        // also check if user already in region (current state in region)
//        // wait for some period because of first time app loading members loading...
//        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 5 * Int64(NSEC_PER_SEC))
//        dispatch_after(time, dispatch_get_main_queue()) {
//            //put your code which should be executed with a delay here
//            //sharedObj.locationManager.requestStateForRegion(clRegion)
//            // start custom checkin monitoring system
//            //sharedObj.locationManager.startUpdatingLocation()
//        }
//        
//        
//        // add in array
//        regions[newRegionID] = region
//        
//        iLog("")
//        _log("<<<<<<<<<<<<--Monitored Regions------------")
//        _log("\(sharedObj.locationManager.monitoredRegions)")
//        _log("--------------Monitored Regions---->>>>>>>>")
//        iLog("")
//    }
//    
//    class func removeRegion(groupID: String, subGroupID: String) {
//        _log(__FUNCTION__)
//        
//        let newRegionID = "\(groupID)_\(subGroupID)"
//        
//        if regions[newRegionID] != nil { // if exist
//            
//            let region = regions[newRegionID]!
//            let clRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.location.latitude, longitude: region.location.longitude), radius: region.location.radius, identifier: newRegionID)
//            
//            // stop monitoring
//            sharedObj.locationManager.stopMonitoringForRegion(clRegion)
//            
//            // remove from array
//            regions.removeValueForKey(newRegionID)
//        }
//        
//        iLog("")
//        _log("<<<<<<<<<<<<--Monitored Regions------------")
//        _log("\(sharedObj.locationManager.monitoredRegions)")
//        _log("--------------Monitored Regions---->>>>>>>>")
//        iLog("")
//    }
//    
//    
//    // object func's (monitoring corelocation delegate methods)
//    
//    override init() {
//        super.init()
//        
//        locationManager.delegate = self
//        
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        
//        locationManager.allowsBackgroundLocationUpdates = true
//        
//        
////        // when app is opened and first time start so if user in auto in
////        locationManager.startUpdatingLocation()
//        
////        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: beacon1UUID)!, identifier: "beacon_office")
////        locationManager.startRangingBeaconsInRegion(region)
////        locationManager.startMonitoringForRegion(region)
//        
//    }
//    
//    // alert if not possible to monitor
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status != CLAuthorizationStatus.NotDetermined {
//            GeoFencing.canMonitoring(true)
//        }
//        if status == CLAuthorizationStatus.AuthorizedAlways {
//            GeoFencing.authorizationStatus = true
////            GeoFencing.refreshRegions()
//        }else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
//            GeoFencing.authorizationStatus = true
//        }else{
////            GeoFencing.authorizationStatus = false
//        }
//        
//        
//    }
//    
////    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
////        
////        iLog("didDetermineState: region: \(region.identifier) state: \(state.hashValue)")
////        
////        if isAppAsActiveState || self.lastBackgroundTask != nil {
////
////            if state == CLRegionState.Inside && self.newLocation != nil && self.accurateLocationReceived { // when in and user in is region radius
////                
////                
////                // if user not in region so don't checkin (Security)
////                let currentCLCircularRegion = region as! CLCircularRegion
////                let currentRegionLocation = CLLocation(latitude: currentCLCircularRegion.center.latitude, longitude: currentCLCircularRegion.center.longitude)
////                let distanceFromRegion = self.newLocation!.distanceFromLocation(currentRegionLocation)
////                let distanceFromCurrentToSubGroupLocation: Int = Int( (manager.location!.distanceFromLocation(currentRegionLocation)) )
////                if distanceFromRegion > (currentCLCircularRegion.radius + 10) { // out from region radius
////                    userIsInRegion = false
////                    
////                    BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
////                        // for debuging...
////                        Firebase(url: "https://wrk1.firebaseio.com/work1003/\(UIDevice.currentDevice().name)/userNotInRegion").childByAutoId().setValue(["time": "\(currentTime())", "distanceFromRegion": "\(distanceFromRegion)", "currentCLCircularRegionRadius": "\(currentCLCircularRegion.radius)", "newLocation": "\(self.newLocation)", "regionID": "\(currentCLCircularRegion.identifier)", "regionLocation": "\(currentCLCircularRegion.center)", "distanceFromCurrentToSubGroupLocation": "\(distanceFromCurrentToSubGroupLocation)"], withCompletionBlock: { (err, firebase) -> Void in
////                        })
////                        backgroundTask.end()
////                    }
////                    
////                }
////                
////                if userIsInRegion {
////                    
////                    BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
////                        // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
////                        
////                        if self.isLog && self.isAppAsActiveState { notification("didDetermineState: didEnterRegion: \(region.identifier)") }
////                        //                    if self.isLog && !self.isAppAsActiveState { notification("didEnterRegion: \(region.identifier)") }
////                        
////                        let groupSubGroupIDsArr = region.identifier.characters.split{$0 == "_"}.map(String.init)
////                        let groupID = groupSubGroupIDsArr[0]
////                        let subGroupID = groupSubGroupIDsArr[1]
////                        
////                        // checking in...
////                        LocationReport.checkIn(groupID, subGroupID: subGroupID) { (err) -> Void in
////                            
////                            
////                            if err == nil {
////                                
////                                if LocationReport.loginUID != nil { notification("\(LocationReport.loginUID!) Check-in at \(subGroupID), \(groupID)") }
////                                
////                                nestedVC?.checkInBtn.setTitle("Check Out", forState: .Normal)
////                                nestedVC?.checkedIn = true
////                                nestedVC?.checkinViewRefresh()
////                                
////                                
////                                
////                                // refresh region if updated
////                                if LocationReport.loginUID != nil {
////                                    GeoFence.getSubGroupLocation(groupID, subGroupID: subGroupID, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
////                                    })
////                                }
////                                
////                                // wait for some period because of region updating...
////                                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
////                                dispatch_after(time, dispatch_get_main_queue()) {
////                                    //put your code which should be executed with a delay here
////                                    
////                                    self.lastBgHandlerLimitExtendTimer?.invalidate()
////                                    self.bgHandlerLimitExtend()
////                                    
////                                    self.lastBackgroundTask?.end()
////                                    self.lastBackgroundTask = nil
////                                    self.accurateLocationReceived = false
////                                    backgroundTask.end() // end with success
////                                }
////                                
////                            }else{
////                                if self.isLog { notification("Error: In \(err)") }
////                                
////                                notification("CheckIn Error: Internet is not available.")
////                                
////                                // update previously checkin to checkin false because of error in nsuserdefault locally
////                                LocationReport.isAlreadyCheckIn["\(groupID)_\(subGroupID)"] = false
////                                LocationReport.syncIsAlreadyCheckIn()
////                                
////                                self.lastBackgroundTask?.end()
////                                self.lastBackgroundTask = nil
////                                self.accurateLocationReceived = false
////                                backgroundTask.end() // end with error
////                                
////                                
////                            }
////                            
////                            
////                        }
////                        
////                        
////                        
////                    }
////                    
////                }
////                
////                
////            }
////            
////            
////            if state == CLRegionState.Outside {
////                
////                BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
////                    // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
////                    
////                    let groupSubGroupIDsArr = region.identifier.characters.split{$0 == "_"}.map(String.init)
////                    let groupID = groupSubGroupIDsArr[0]
////                    let subGroupID = groupSubGroupIDsArr[1]
////                    
////                    // checking out if not...
////                    LocationReport.checkOut(groupID, subGroupID: subGroupID) { (err) -> Void in
////                        
////                        if err == nil {
////                            
////                            if LocationReport.loginUID != nil { notification("\(LocationReport.loginUID!) Checkout from \(subGroupID), \(groupID)") }
////                            
////                            nestedVC?.checkInBtn.setTitle("Check In", forState: .Normal)
////                            nestedVC?.checkedIn = true
////                            nestedVC?.checkinViewRefresh()
////                            
////                            
////                            // refresh region if updated
////                            if LocationReport.loginUID != nil {
////                                GeoFence.getSubGroupLocation(groupID, subGroupID: subGroupID, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
////                                })
////                            }
////                            
////                            // wait for some period because of region updating...
////                            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
////                            dispatch_after(time, dispatch_get_main_queue()) {
////                                //put your code which should be executed with a delay here
////                                
////                                self.lastBgHandlerLimitExtendTimer?.invalidate()
////                                self.bgHandlerLimitExtend()
////                                
////                                self.lastBackgroundTask?.end()
////                                self.lastBackgroundTask = nil
////                                self.accurateLocationReceived = false
////                                backgroundTask.end() // end with success
////                            }
////                            
////                            
////                        }else{
////                            if self.isLog { notification("Error: Out \(err)") }
////                            
////                            notification("CheckOut Error: Internet is not available.")
////                            
////                            self.lastBackgroundTask?.end()
////                            self.lastBackgroundTask = nil
////                            self.accurateLocationReceived = false
////                            backgroundTask.end() // end with error log
////
////                        }
////                        
////                        
////                    }
////                    
////                    
////                }
////                
////            }
////            
////            
////        }
////    }
////    
//    
//    
//    // helper func for bg handler limit extend
//    func bgHandlerLimitExtend(){
//        
//        // start new handler
//        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
//            
//            if self.lastBgHandlerLimitExtendTimer?.valid == false { // when timer stoped so stop all bg handler's
//                self.lastBackgroundLimitHandler?.end()
//                backgroundTask.end()
//                return
//            }
//            
//            // end last handler if any
//            self.lastBackgroundLimitHandler?.end()
//            // set new handler
//            self.lastBackgroundLimitHandler = backgroundTask
//            
//            // do any work with more limit
//            
//            // for debuging...
//            Firebase(url: "https://wrk1.firebaseio.com/work1001/\(UIDevice.currentDevice().name)/bgHandlerLimitExtend").childByAutoId().setValue(["time": "\(currentTime())", "lastInOROutGroupID": "\(GeoFencing.lastInOROutGroupID)", "lastInOROutSubGroupID": "\(GeoFencing.lastInOROutSubGroupID)"], withCompletionBlock: { (err, firebase) -> Void in
//            })
//            
//            // refresh region if updated
//            if LocationReport.loginUID != nil && GeoFencing.lastInOROutGroupID != nil && GeoFencing.lastInOROutSubGroupID != nil {
//                GeoFence.getSubGroupLocation(GeoFencing.lastInOROutGroupID!, subGroupID: GeoFencing.lastInOROutSubGroupID!, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
//                })
//            }
//            
//        }
//        
//    }
//    
//    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        
//        // start updating location for accuracy in or out
//        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
//            // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
//            
//            if self.isLog { notification("didEnterRegion: \(region.identifier)") }
//            
//            // set last bg task
//            self.lastBackgroundTask = backgroundTask
//            
//            manager.startUpdatingLocation()
//            
//            self.lastBgHandlerLimitExtendTimer?.invalidate()
//            self.bgHandlerLimitExtend()
//            
//            // extend its background handler limit
//            self.lastBgHandlerLimitExtendTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "bgHandlerLimitExtend", userInfo: nil, repeats: true)
//        }
//        
//        
////        return
////        
////        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
////            // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
////            
////            //manager.startUpdatingLocation()
////            
////            if self.isLog { notification("didEnterRegion: \(region.identifier)") }
////            
////            let groupSubGroupIDsArr = region.identifier.characters.split{$0 == "_"}.map(String.init)
////            let groupID = groupSubGroupIDsArr[0]
////            let subGroupID = groupSubGroupIDsArr[1]
////            
////            //notification("didEnterRegion at \(subGroupID), \(groupID)")
////            
////            // checking in...
////            LocationReport.checkIn(groupID, subGroupID: subGroupID) { (err) -> Void in
////
////                if err == nil {
////                    
////                     if LocationReport.loginUID != nil { notification("\(LocationReport.loginUID!) Check-in at \(subGroupID), \(groupID)") }
////                    
////                    nestedVC?.checkInBtn.setTitle("Check Out", forState: .Normal)
////                    nestedVC?.checkedIn = true
////                    nestedVC?.checkinViewRefresh()
////                    
////
////                    
////                    // refresh region if updated
////                    if LocationReport.loginUID != nil {
////                        GeoFence.getSubGroupLocation(groupID, subGroupID: subGroupID, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
////                        })
////                    }
////                    
////                    // wait for some period because of region updating...
////                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
////                    dispatch_after(time, dispatch_get_main_queue()) {
////                        //put your code which should be executed with a delay here
////                        //backgroundTask.end() // end with success
////                    }
////                    
////                }else{
////                    if self.isLog { notification("Error: In \(err)") }
////                    
////                    notification("CheckIn Error: Internet is not available.")
////                    
////                    // update previously checkin to checkin false because of error in nsuserdefault locally
////                    LocationReport.isAlreadyCheckIn["\(groupID)_\(subGroupID)"] = false
////                    LocationReport.syncIsAlreadyCheckIn()
////                    
////                    
////                    backgroundTask.end() // end with error
////                    
////                }
////                
////
////            }
////            
////            
////            
////        }
//        
//        
//    }
//    
//    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
//   
//        if self.lastBackgroundTask == nil {
//            
//            // start updating location for accuracy in or out
//            BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
//                // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
//                
//                if self.isLog { notification("didExitRegion: \(region.identifier)") }
//                
//                // set last bg task
//                self.lastBackgroundTask = backgroundTask
//                self.lastBgHandlerLimitExtendTimer?.invalidate()
//                self.bgHandlerLimitExtend()
//                // extend its background handler limit
//                self.lastBgHandlerLimitExtendTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "bgHandlerLimitExtend", userInfo: nil, repeats: true)
//            
//
//                    
//                let groupSubGroupIDsArr = region.identifier.characters.split{$0 == "_"}.map(String.init)
//                let groupID = groupSubGroupIDsArr[0]
//                let subGroupID = groupSubGroupIDsArr[1]
//                
//                // checking out if not...
//                LocationReport.checkOut(groupID, subGroupID: subGroupID) { (err) -> Void in
//                    
//                    if err == nil {
//                        
//                        if LocationReport.loginUID != nil { notification("\(LocationReport.loginUID!) Checkout from \(subGroupID), \(groupID)") }
//                        
//                        nestedVC?.checkInBtn.setTitle("Check In", forState: .Normal)
//                        nestedVC?.checkedIn = true
//                        nestedVC?.checkinViewRefresh(nil)
//                        
//                        
//                        // refresh region if updated
//                        if LocationReport.loginUID != nil {
//                            GeoFence.getSubGroupLocation(groupID, subGroupID: subGroupID, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
//                            })
//                        }
//                        
//                        // wait for some period because of region updating...
//                        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
//                        dispatch_after(time, dispatch_get_main_queue()) {
//                            //put your code which should be executed with a delay here
//                            
//                            self.lastBgHandlerLimitExtendTimer?.invalidate()
//                            self.bgHandlerLimitExtend()
//                            
//                            self.lastBackgroundTask?.end()
//                            self.lastBackgroundTask = nil
//                            self.accurateLocationReceived = false
//                            backgroundTask.end() // end with success
//                        }
//                        
//                        
//                    }else{
//                        if self.isLog { notification("Error: Out \(err)") }
//                        
//                        notification("CheckOut Error: Internet is not available.")
//                        
//                        self.lastBackgroundTask?.end()
//                        self.lastBackgroundTask = nil
//                        self.accurateLocationReceived = false
//                        backgroundTask.end() // end with error log
//                        
//                    }
//                    
//                    
//                }
//            
//            
//            }
//        
//        }
//    
//    }
//
//
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
//            // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second. it can take approx 3 to 4 mins
//            
//            let minimumAccuracy: CLLocationAccuracy = 30.0
//
//                iLog("accurateLocationReceived: \(self.accurateLocationReceived)")
//                if locations[0].horizontalAccuracy <= minimumAccuracy && !self.accurateLocationReceived { // within minimum accuracy so check in or out
//                    self.accurateLocationReceived = true
//                    
//                    self.newLocation = locations[0] // set current accurate location
//                    manager.stopUpdatingLocation()
//                    
//                    // start custom checkin process
//                    self.isCheckInFromAnyRegion()
//                }
//            
//                // for debuging...
//                Firebase(url: "https://wrk1.firebaseio.com/work1000/\(UIDevice.currentDevice().name)/didUpdateLocations").childByAutoId().setValue(["location": "\(self.newLocation)", "desc": "\(self.newLocation?.description)", "horizontalAccuracy": "\(self.newLocation?.horizontalAccuracy)", "verticalAccuracy": "\(self.newLocation?.verticalAccuracy)"], withCompletionBlock: { (err, firebase) -> Void in
//                })
//                
//                iLog("didUpdateLocations:")
//                iLog("locations:")
//                iLog("\(locations)")
//                iLog("currentLocation: altitude:\(self.newLocation?.altitude), coordinate:\(self.newLocation?.coordinate), timestamp:\(self.newLocation?.timestamp), description:\(self.newLocation?.description), horizontalAccuracy:\(self.newLocation?.horizontalAccuracy), verticalAccuracy:\(self.newLocation?.verticalAccuracy)")
//            
//        }
//        
//    }
//    
//    func isCheckInFromAnyRegion(){
//        iLog("\(__FUNCTION__)")
//        
//        if self.isCheckInProcessIsRunning == false {
//            BackgroundTask.run(UIApplication.sharedApplication()) { backgroundTask in
//                // MARK: custom checkin system
//                for region in self.locationManager.monitoredRegions{ // each region
//                    
//                    let currentCLCircularRegion = region as! CLCircularRegion
//                    let currentRegionLocation = CLLocation(latitude: currentCLCircularRegion.center.latitude, longitude: currentCLCircularRegion.center.longitude)
//                    let distanceFromRegion = Double( self.newLocation!.distanceFromLocation(currentRegionLocation) )
//                    iLog("distanceFromRegion: \(distanceFromRegion) , regionID: \(region.identifier)")
//                    
//                    // for debuging...
//                    Firebase(url: "https://wrk1.firebaseio.com/work10010/\(UIDevice.currentDevice().name)/distanceFromRegion").childByAutoId().setValue(["currentLocation": "\(self.newLocation!)", "desc": "\(self.newLocation!.description)", "horizontalAccuracy": "\(self.newLocation!.horizontalAccuracy)", "verticalAccuracy": "\(self.newLocation!.verticalAccuracy)", "distanceFromRegion": "\(distanceFromRegion)"], withCompletionBlock: { (err, firebase) -> Void in
//                    })
//                    
//                    if distanceFromRegion <= Double(currentCLCircularRegion.radius + 160) { // in at region // added 160 meter for flexibility
//                        iLog("in at regionID: \(region.identifier)")
//                        
//                        
//                        // do work when app is suspended and need work more than 10 second because apple auto suspend app when it exceed its 10 second.
//                        self.isCheckInProcessIsRunning = true
//                        
//                        let groupSubGroupIDsArr = region.identifier.characters.split{$0 == "_"}.map(String.init)
//                        let groupID = groupSubGroupIDsArr[0]
//                        let subGroupID = groupSubGroupIDsArr[1]
//                        
//                        // checking in...
//                        LocationReport.checkIn(groupID, subGroupID: subGroupID) { (err) -> Void in
//                            
//                            
//                            if err == nil {
//                                
//                                if LocationReport.loginUID != nil { notification("\(LocationReport.loginUID!) Check-in at \(subGroupID), \(groupID)") }
//                                
//                                nestedVC?.checkInBtn.setTitle("Check Out", forState: .Normal)
//                                nestedVC?.checkedIn = true
//                                nestedVC?.checkinViewRefresh(nil)
//                                
//                                
//                                
//                                //                                        // refresh region if updated
//                                //                                        if LocationReport.loginUID != nil {
//                                //                                            GeoFence.getSubGroupLocation(groupID, subGroupID: subGroupID, userID: LocationReport.loginUID!, completion: { (location, error) -> Void in
//                                //                                            })
//                                //                                        }
//                                
//                                // wait for some period because of region updating...
//                                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
//                                dispatch_after(time, dispatch_get_main_queue()) {
//                                    //put your code which should be executed with a delay here
//                                    
//                                    self.lastBgHandlerLimitExtendTimer?.invalidate()
//                                    self.bgHandlerLimitExtend()
//                                    
//                                    self.lastBackgroundTask?.end()
//                                    self.lastBackgroundTask = nil
//                                    self.accurateLocationReceived = false
//                                    backgroundTask.end() // end with success
//                                }
//                                
//                            }else{
//                                if self.isLog { notification("Error: In \(err)") }
//                                
//                                notification("CheckIn Error: Internet is not available.")
//                                
//                                // update previously checkin to checkin false because of error in nsuserdefault locally
//                                LocationReport.isAlreadyCheckIn["\(groupID)_\(subGroupID)"] = false
//                                LocationReport.syncIsAlreadyCheckIn()
//                                
//                                self.lastBackgroundTask?.end()
//                                self.lastBackgroundTask = nil
//                                self.accurateLocationReceived = false
//                                backgroundTask.end() // end with error
//                                
//                                
//                            }
//                            
//                            
//                        }
//                        
//                        
//                        
//                    }
//                    
//                    
//                }
//                
//                
//                // wait for some period because of region updating...
//                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 10 * Int64(NSEC_PER_SEC))
//                dispatch_after(time, dispatch_get_main_queue()) {
//                    //put your code which should be executed with a delay here
//                    // when no checkin found so reset state
//                    if self.isCheckInProcessIsRunning == false {
//                        self.accurateLocationReceived = false
//                    }
//                }
//                
//                
//                
//            }
//            
//        }
//        
//    }
//    
//    // private helpers methods
//    
//    private class func _log(data: String){
//        iLog("Log: ")
//        iLog(data)
//    }
//    
//    
//}
//
//
//
//
