//
//  PlugInGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit

class PlugInGridViewCell: GridViewCell {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var plugInArr:[String] = []
    
    let imageViewOne = UIImageView(image: UIImage.asset(.PlugInBackgroundView1))
    let imageViewTwo = UIImageView(image: UIImage.asset(.PlugInBackgroundView6))
    static var nib: UINib {
        return UINib(nibName: "PlugInGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        tableView.register(PlugInTableViewCell.nib, forCellReuseIdentifier: "PlugInTableViewCell")
        tableView.bounces = false
        imageViewTwo.alpha = 0.2
        imageViewOne.addSubview(imageViewTwo)
        imageViewTwo.contentMode = .scaleToFill
        tableView.backgroundView = imageViewOne
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        imageViewTwo.frame = tableView.frame
    }
}

