//
//  JobsManager.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 11/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation

class JobsManager {
    
    static var sharedObj = JobsManager()
    private var jobs = [String: Job]() // jobID : JobObject
    
    
    // add new job
    class func addJob(title: String, jobRate: Int, rateType: JobRateType){
        iLog("\(self.dynamicType), \(__FUNCTION__), title: \(title), jobRate: \(jobRate), rateType: \(rateType.hashValue)")
        
        var jobID = self.sharedObj.jobs.count
        if jobID == 0 { jobID = 1 }
        
        let jobRateAsFloat = Float(jobRate)
        
        self.sharedObj.jobs["\(jobID)"] = Job(title: title, rate: jobRateAsFloat, rateType: rateType)
    }
    
    // get all jobs
    class func getJobs()->[String: Job]{
        return self.sharedObj.jobs
    }
    
    
    
    
    
    
}