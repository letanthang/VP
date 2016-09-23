//
//  CustomArticleCell.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 4/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class CustomArticleCell: UITableViewCell {

    @IBOutlet weak var banner: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var view: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
