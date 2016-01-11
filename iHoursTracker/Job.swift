//
//  Job.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 11/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation

class Job {
    
    var jobTitle: String!
    var jobRate: Float!
    var jobRateType: JobRateType!
    
    
    init(title: String, rate: Float, rateType: JobRateType){
        self.jobTitle = title
        self.jobRate = rate
        self.jobRateType = rateType
    }
     
}


enum JobRateType {
    case Daily
    case Weekly
}