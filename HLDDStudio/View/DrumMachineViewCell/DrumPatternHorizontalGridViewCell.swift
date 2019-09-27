//
//  DrumPatternHorizontalGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/26.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit


class DrumPatternHorizontalGridViewCell: GridViewCell {
    
    @IBOutlet weak var selectButton: UIButton!
    
    weak var delegate: DrumPatternGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumPatternHorizontalGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        selectButton.addTarget(self, action: #selector(DrumPatternHorizontalGridViewCell.selectButtonAction(_:)), for: .touchUpInside)
    }
    @objc func selectButtonAction(_ sender: Any?) {
        selectButton.isSelected = !selectButton.isSelected
        delegate?.patternSelecte(cell: self, isSelected: selectButton.isSelected)
    }
}
