//
//  Jobs+CoreDataProperties.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 11/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

let rateTypeData = ["Daily", "Weekly", "Monthly", "Hourly", "Quarterly", "Yearly"]

extension Jobs {

    @NSManaged var title: String?
    @NSManaged var rate: NSNumber?
    @NSManaged var rateType: NSNumber?
    @NSManaged var locationLat: String?
    @NSManaged var locationLong: String?
    @NSManaged var locationRadius: NSNumber?
    @NSManaged var joinDate: NSDate?

}
