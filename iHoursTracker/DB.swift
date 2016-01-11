//
//  DB.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 11/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class DB {

    static var managedContext: NSManagedObjectContext{
        get{
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.managedObjectContext
        }
    }
    static let kEntityName = "Jobs"
    
    static var jobs = [Jobs]() // database object containing all jobs properties

    
    static func addJob(title: String, rate: Float, rateType: Int, locationCordinate: CLLocationCoordinate2D, radius: Float)->NSError?{
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        
        let jobEntity = NSEntityDescription.entityForName(DB.kEntityName, inManagedObjectContext: managedContext)
        let newJob = NSManagedObject(entity: jobEntity!, insertIntoManagedObjectContext: managedContext)
        
        newJob.setValue(title, forKey: "title")
        newJob.setValue(rate, forKey: "rate")
        newJob.setValue(rateType, forKey: "rateType")
        newJob.setValue("\(locationCordinate.latitude)", forKey: "locationLat")
        newJob.setValue("\(locationCordinate.longitude)", forKey: "locationLong")
        newJob.setValue(radius, forKey: "locationRadius")
        newJob.setValue(NSDate(), forKey: "joinDate")
        
        do {
            
            try managedContext.save()
            DB.loadJobs()
            
            iLog("\(self.dynamicType), \(__FUNCTION__), newJob Saved.")
            
            return nil
            
        }catch let error as NSError {
            iLog("newJob Could not save \(error), \(error.userInfo)")
            
            return error
        }
        
        
    }
    
    static func loadJobs(){
        
        let fetchRequest = NSFetchRequest(entityName: DB.kEntityName)
        
        do{
            
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            // when empty jobs list so auto open add job vc
            if results.count < 1 {
                rootTabBarVC.selectedIndex = 0
            }
            
            jobs = [Jobs]()
            
            if let _jobs = results as? [Jobs] {
                self.jobs = _jobs
                logJobs()
            }
            

        }catch let error as NSError {
            iLog("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    static func logJobs(){
        for job in jobs{
            iLog("job: \(job.title)")
            
            
            
        }
    }
    
    
    
}