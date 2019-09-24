//
//  DrumPatternGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/22.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import G3GridView

protocol DrumPatternGridViewCellDelegate: AnyObject {
    
}

class DrumPatternGridViewCell: GridViewCell {
    
    weak var delegate: DrumPatternGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumPatternGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
