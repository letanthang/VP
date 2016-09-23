//
//  ArticleNormalCell.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 14/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class ArticleNormalCell: UITableViewCell {

    @IBOutlet weak var bgItem: UIView!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let maskPath = UIBezierPath(roundedRect: banner.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = banner.bounds
        maskLayer.path  = maskPath.cgPath
        banner.layer.mask = maskLayer
        
        
        
        bgItem.layer.cornerRadius = 8
        bgItem.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
