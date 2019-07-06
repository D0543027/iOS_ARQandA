//
//  ProfileTableViewCell.swift
//  ARQandA
//
//  Created by 李其准 on 2019/7/6.
//  Copyright © 2019年 蔣聖訢. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var beginDateLb: UILabel!
    @IBOutlet weak var dayCountLb: UILabel!
    @IBOutlet weak var totalLb: UILabel!
    @IBOutlet weak var rightLb: UILabel!
    @IBOutlet weak var wrongLb: UILabel!
    @IBOutlet weak var accuracyLb: UILabel!
    @IBOutlet weak var onceHScoreLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
