//
//  JobsListTableViewCell.swift
//  iHoursTracker
//
//  Created by Faiq Talat on 11/01/2016.
//  Copyright © 2016 Faiq Talat. All rights reserved.
//

import UIKit

class JobsListTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var joinDate: UILabel!
    @IBOutlet weak var rateAmount: UILabel!
    @IBOutlet weak var currencyType: UILabel!
    @IBOutlet weak var currencySign: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
