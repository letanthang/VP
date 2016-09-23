//
//  CustomTableViewCell.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 23/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBg: UIImageView!
    
    @IBOutlet weak var cellText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
