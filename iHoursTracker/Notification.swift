//
//  notification.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation
import UIKit

class Notification: NSObject {
    
    private static var isSeenNotification = [String: Bool]() // title: a bool indicating that notification is seen or close after display
    
    // display simple alert
    class func notify(title: String, msg: String, showTime: Double){
        
        var currentWindow: UIWindow?
        var notificationView: UIView?
        var notificationTextView: UITextView?
        
        iLog("isSeenNotification[title]: \(isSeenNotification[title])")
        
        if isSeenNotification[title] != nil && isSeenNotification[title] == true {return} // already showing...

        isSeenNotification[title] = true
        
        currentWindow = UIApplication.sharedApplication().keyWindow
        if currentWindow == nil {
            isSeenNotification[title] = false
            return
        }
        
        notificationView = UIView(frame: CGRect(x: 0, y: 20, width: currentWindow!.frame.size.width, height: 44))
        notificationView?.userInteractionEnabled = false
        notificationView?.backgroundColor = UIColor.grayColor()
        notificationView?.layer.cornerRadius = 3
        notificationTextView = UITextView(frame: CGRect(x: 0, y: 0, width: currentWindow!.frame.size.width, height: 44))
        notificationTextView?.font = UIFont.systemFontOfSize(13.0)
        notificationTextView?.textColor = UIColor.whiteColor()
        notificationTextView?.backgroundColor = appGreenColor

        notificationTextView!.text = "\(msg)"
        
        notificationView!.addSubview(notificationTextView!)
        currentWindow!.addSubview(notificationView!)

        notificationView?.frame = CGRect(x: 0, y: 0, width: currentWindow!.frame.size.width, height: 44)
        
        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            notificationView?.frame = CGRect(x: 0, y: 20, width: currentWindow!.frame.size.width, height: 44)
            
            }, completion: nil)
        
        let delay = showTime * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {

            isSeenNotification[title] = false
            
            
            UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                notificationView?.frame = CGRect(x: 0, y: 0, width: currentWindow!.frame.size.width, height: 44)
                
                }, completion: { (bool) -> Void in
                    
                    notificationView!.removeFromSuperview()
            })
            
            
        }
        
        
    }
    
    class func localNotify(Msg: String){
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
        localNotification.alertBody = Msg
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
    }
    
    
}