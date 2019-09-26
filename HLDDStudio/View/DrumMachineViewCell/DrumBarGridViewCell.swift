//
//  DrumBarGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/25.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit

protocol DrumBarGridViewCellDelegate: AnyObject {
    
}
class DrumBarGridViewCell: GridViewCell {
    
    @IBOutlet weak var barLabel: UILabel!
    
    weak var delegate: DrumBarGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumBarGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        self.backgroundColor = .yellow
    }
}
