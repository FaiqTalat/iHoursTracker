//
//  notification.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation
import UIKit

class notification: NSObject {
    
    private static var isSeenNotification = [String: Bool]() // title: a bool indicating that notification is seen or close after display
    
    // display simple alert
    class func notify(title: String, msg: String, showTime: Double){
        
        var currentWindow: UIWindow?
        var notificationView: UIView?
        var notificationTextView: UITextView?
        
        if isSeenNotification[title] != nil && isSeenNotification[title] == true {return} // already showing...

        isSeenNotification[title] = true
        
        currentWindow = UIApplication.sharedApplication().keyWindow
        
        notificationView = UIView(frame: CGRect(x: 0, y: 20, width: currentWindow!.frame.size.width, height: 44))
        notificationView?.userInteractionEnabled = false
        notificationView?.backgroundColor = UIColor.grayColor()
        notificationView?.layer.cornerRadius = 3
        notificationTextView = UITextView(frame: CGRect(x: 0, y: 0, width: currentWindow!.frame.size.width, height: 44))
        notificationTextView?.font = UIFont.systemFontOfSize(13.0)
        notificationTextView?.textColor = UIColor.whiteColor()
        notificationTextView?.backgroundColor = UIColor(red: 48.0/255, green: 181.0/255,
            blue: 201.0/255, alpha: 1.0)

        notificationTextView!.text = "\(msg)"
        
        notificationView!.addSubview(notificationTextView!)
        currentWindow!.addSubview(notificationView!)

        let delay = showTime * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            notificationView!.removeFromSuperview()
        }
        
        
    }
    
    
}