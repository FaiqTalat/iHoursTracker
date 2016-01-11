//
//  JobsListVC.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 08/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit

class JobsListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DB.jobs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1") as! JobsListTableViewCell
        
        let job = DB.jobs[indexPath.row]
        
        cell.name.text = job.title!
        cell.rateAmount.text = "\(job.rate!)"
        cell.currencyType.text = "\( getJobTypeTitleByIndex(job.rateType!) )"
        cell.joinDate.text = "\(job.joinDate)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func getJobTypeTitleByIndex(index: NSNumber)->String{
        //iLog("index: \(index)")
        return AddJobVC.rateTypeData[Int(index)]
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
