//
//  FaderGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import G3GridView

class FaderGridViewCell: GridViewCell {
    
    static var nib: UINib {
        return UINib(nibName: "FaderGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
    }
    
}
