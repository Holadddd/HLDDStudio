//
//  PlugInView.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import AudioKit


class PlugInView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(PlugInReverbTableViewCell.nib, forCellReuseIdentifier: "PlugInReverbTableViewCell")
        
    }
    

}
