//
//  DrumPatternGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/25.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit

protocol DrumPatternGridViewCellDelegate: AnyObject {
    
}
class DrumPatternGridViewCell: GridViewCell {
    
    @IBOutlet weak var drumLabel: UILabel!
    weak var delegate: DrumPatternGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumPatternGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        self.backgroundColor = .green
    }
}
