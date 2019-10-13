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

//dont use protocol use notificationCenter and edit the plugInmanager data and instance value
protocol FaderGridViewCellDelegate: AnyObject {
    
    func pannerValueChange(value: Float, cell: FaderGridViewCell)
    
    func volumeChange(value: Float, cell: FaderGridViewCell)
    
    func lowEQValueChange(value: Float, cell: FaderGridViewCell)
    
    func midEQValueChange(value: Float, cell: FaderGridViewCell)
    
    func highEQValueChange(value: Float, cell: FaderGridViewCell)
}

class FaderGridViewCell: GridViewCell {
    
    @IBOutlet weak var volumeFader: Fader!
    
    @IBOutlet weak var panKnob: Knob!
    
    @IBOutlet weak var lowKnob: Knob!
    
    @IBOutlet weak var midKnob: Knob!
    
    @IBOutlet weak var highKnob: Knob!
    
    @IBOutlet weak var FaderLabel: UILabel!
    
    weak var delegate: FaderGridViewCellDelegate?
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super .awakeFromNib()
        
        setUpCustomUIKit()
    }
}

extension FaderGridViewCell: HLDDFaderDelegate, HLDDKnobDelegate {
    
    func setUpCustomUIKit() {
        
        volumeFader.delegate = self
        
        volumeFader.maximumValue = 2
        
        volumeFader.minimumValue = 0
        
        volumeFader.value = 1
        
        panKnob.delegate = self
        
        panKnob.maximumValue = 1
        
        panKnob.minimumValue = -1
        
        panKnob.value = 0
        
        lowKnob.delegate = self
        
        lowKnob.maximumValue = 2
        
        lowKnob.minimumValue = 0
        
        lowKnob.value = 1
        
        midKnob.delegate = self
        
        midKnob.maximumValue = 2
        
        midKnob.minimumValue = 0
        
        midKnob.value = 1
        
        highKnob.delegate = self
        
        highKnob.maximumValue = 2
        
        highKnob.minimumValue = 0
        
        highKnob.value = 1
    }
    
    func knobValueDidChange(knobValue value: Float,
                            knob: Knob) {
        
        switch knob {
            
        case panKnob:
            
            FaderLabel.text = String(format: "Pan: %.2f",
                                     knob.value)
            
            delegate?.pannerValueChange(value: knob.value,
                                        cell: self)
        case lowKnob:
            FaderLabel.text = String(format: "low: %.2f",
                                     knob.value)
            
            delegate?.lowEQValueChange(value: knob.value,
                                       cell: self)
        case midKnob:
            
            FaderLabel.text = String(format: "mid: %.2f",
                                     knob.value)
            
            delegate?.midEQValueChange(value: knob.value,
                                       cell: self)
        case highKnob:
            
            FaderLabel.text = String(format: "high: %.2f",
                                     knob.value)
            delegate?.highEQValueChange(value: knob.value,
                                        cell: self)
        default:
            
            return
        }
    }
    
    func knobIsTouching(bool: Bool,
                        knob: Knob) {
        
    }
    
    func faderValueDidChange(faderValue value: Float,
                             fader: Fader) {
        
        switch fader {
            
        case volumeFader:
            
            FaderLabel.text = String(format: "Volume: %.2f",
                                     fader.value)
            
            delegate?.volumeChange(value: fader.value,
                                   cell: self)
        default:
            
            return
        }
    }
    
    func faderIsTouching(bool: Bool,
                         fader: Fader) {
        
    }
}
