//
//  DrumEditingHorizontalGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/26.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit


class DrumEditingHorizontalGridViewCell: GridViewCell {
    

    weak var delegate: DrumEditingGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumEditingHorizontalGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
    }
    
    deinit {
        print("DrumEditingHorizontalGridViewCellDeinit\(self.indexPath)")
    }
}
