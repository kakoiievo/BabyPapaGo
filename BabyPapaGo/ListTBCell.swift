//
//  ListTBCell.swift
//  BabyMaMago
//
//  Created by Yung on 2018/11/30.
//  Copyright © 2018 Yung. All rights reserved.
//

import UIKit

class ListTBCell: UITableViewCell {

    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var listPhone: UILabel!
    @IBOutlet weak var listAddRess: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        listImage.contentMode = .scaleAspectFill
        listImage.clipsToBounds = true
        
        listImage.layer.cornerRadius = listImage.layer.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
