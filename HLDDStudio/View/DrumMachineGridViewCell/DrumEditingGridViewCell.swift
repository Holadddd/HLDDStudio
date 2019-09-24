//
//  DrumEditingGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/22.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit

protocol DrumEditingGridViewCellDelegate: AnyObject {
    
}

class DrumEditingGridViewCell: GridViewCell {
    
    weak var delegate: DrumEditingGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumEditingGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
