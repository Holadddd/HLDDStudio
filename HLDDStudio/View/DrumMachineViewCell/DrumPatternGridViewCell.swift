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
    
    func patternSelecte(cell: DrumPatternGridViewCell, isSelected: Bool)
    
}
class DrumPatternGridViewCell: GridViewCell {
    
    @IBOutlet weak var drumLabel: UILabel!
    
    
    @IBOutlet weak var selectButton: UIButton!
    
    weak var delegate: DrumPatternGridViewCellDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "DrumPatternGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        selectButton.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
    }
    
    @objc func selectButtonAction() {
        selectButton.isSelected = !selectButton.isSelected
        delegate?.patternSelecte(cell: self, isSelected: selectButton.isSelected)
    }
    
}
