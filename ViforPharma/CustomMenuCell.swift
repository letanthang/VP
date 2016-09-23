//
//  CustomMenuCell.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 29/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class CustomMenuCell: UITableViewCell {

    @IBOutlet weak var iconMenu: UIImageView!
    @IBOutlet weak var textMenu: UILabel!
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
