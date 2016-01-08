//
//  helpers.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import Foundation
import UIKit

var isAppLog = true
var statusBarTopView = UIView(frame: UIApplication.sharedApplication().statusBarFrame)

let appGreenColor = UIColor(red: 101.0/255.0, green: 178.0/255.0, blue: 137.0/255.0, alpha: 1.0)

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