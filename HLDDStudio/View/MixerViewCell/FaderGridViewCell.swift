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

class FaderGridViewCell: GridViewCell, HLDDKnobDelegate {
    
    @IBOutlet weak var knob: Knob!
    
    
    static var nib: UINib {
        return UINib(nibName: "FaderGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        knob.delegate = self
        knob.minimumValue = -10
        knob.maximumValue = 40
        knob.value = 3
        knob.reloadKnob()
        
    }
    
    
    func valueDidChange(knobValue value: Float) {
        print(value)
    }
}
