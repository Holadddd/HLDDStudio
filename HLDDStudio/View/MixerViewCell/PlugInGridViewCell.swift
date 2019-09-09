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
    
    static var nib: UINib {
        return UINib(nibName: "PlugInGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        tableView.register(PlugInTableViewCell.nib, forCellReuseIdentifier: "PlugInTableViewCell")

    }
    
}

