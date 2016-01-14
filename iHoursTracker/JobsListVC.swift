//
//  JobsListVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit
import CoreData

class JobsListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var topBarView: UIView!
    // menu
    @IBOutlet weak var menuIconBgView: UIView!
    @IBOutlet weak var menuIconBar1: UIView!
    @IBOutlet weak var menuIconBar2: UIView!
    @IBOutlet weak var menuIconBar3: UIView!
    var MenuIconObject: MenuIcon!
    
    var bgView: UIView!
    var bgBlurView: UIVisualEffectView!
    
    var menuIconState = 0 // 0 as Menu Icon & 1 as Back Btn
    
    @IBOutlet weak var jobsListTVC: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if DB.jobs.count < 1 {

        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        jobsListTVC.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        bgView = UIView(frame: CGRect(x: self.view.frame.size.width, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 20))
        bgView.backgroundColor = UIColor.lightGrayColor()
        bgView.alpha = 0
        self.view.addSubview(bgView)
        
        // for plus button
        self.jobsListTVC.contentInset.bottom = 70
        
        createMenuObject()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return DB.jobs.count
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1") as! JobsListTableViewCell
        
//        let job = DB.jobs[indexPath.row]
//        
//        cell.name.text = job.title!
//        cell.rateAmount.text = "\(job.rate!)"
//        cell.currencyType.text = "\( getJobTypeTitleByIndex(job.rateType!) )"
//        
//        if job.joinDate != nil {
//            cell.joinDate.text = "\(job.joinDate!.getDateAsString())"
//        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let job = DB.jobs[indexPath.row]
        
        switch editingStyle {
        case .Delete:
            

            let isDeleted = DB.delJob(job)
            
            if isDeleted {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            }
            
            
            
        default:
            return
        }
        
    }
    
    func getJobTypeTitleByIndex(index: NSNumber)->String{
        //iLog("index: \(index)")
        return AddJobVC.rateTypeData[Int(index)]
    }
    
    
    
    
    // Menu Btns methods
    
    @IBAction func menuBtnPressed(sender: AnyObject) {
        _log("\(__FUNCTION__)")
        
        if MenuIconObject.state == 0 { // orignal btn
            
            setMenuIconAsBack()
        }else if MenuIconObject.state == 1{ // back btn
            
            setMenuIconAsOrignal()
        }
        
    }
    
    func createMenuObject(){
        iLog("")
        
        self.MenuIconObject = MenuIcon(bar1: menuIconBar1, bar2: menuIconBar2, bar3: menuIconBar3, bgView: self.bgView)
    }
    
    func setMenuIconAsBack(){
        
        MenuIconObject._bar1Rotate315Degrees()
        MenuIconObject._bar3RotateMinus315Degrees()
        MenuIconObject.state = 1
        
    }
    
    func setMenuIconAsOrignal(){
        
        MenuIconObject.getBackToOrignalState()
        MenuIconObject.state = 0
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
