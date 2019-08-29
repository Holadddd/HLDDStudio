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

class FaderGridViewCell: GridViewCell, HLDDFaderDelegate, HLDDKnobDelegate {
    
    @IBOutlet weak var volumeFader: Fader!
    
    @IBOutlet weak var panKnob: Knob!
    
    @IBOutlet weak var lowKnob: Knob!
    
    @IBOutlet weak var midKnob: Knob!
    
    @IBOutlet weak var highKnob: Knob!
    
    @IBOutlet weak var FaderLabel: UILabel!
    
    weak var delegate: GridViewStopScrollingWhileUIKitIsTouchingDelegate?
    
    static var nib: UINib {
        return UINib(nibName: "FaderGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        volumeFader.delegate = self
        panKnob.delegate = self
        lowKnob.delegate = self
        midKnob.delegate = self
        highKnob.delegate = self
        
    }
    
    
    func knobValueDidChange(knobValue value: Float, knob: Knob) {
        switch knob {
        case panKnob:
            print("panKnob")
        case lowKnob:
            print("lowKnob")
        case midKnob:
            print("midKnob")
        case highKnob:
            print("highKnob")
        default:
            return
        }
    }
    
    func knobIsTouching(bool: Bool, knob: Knob) {
        delegate?.isInteractWithUser(bool: !bool)
        print(bool)
    }
    
    func faderValueDidChange(faderValue value: Float, fader: Fader) {
        switch fader {
        case volumeFader:
            print("volumeFader")
        default:
            return
        }
    }
    
    func faderIsTouching(bool: Bool, fader: Fader) {
        delegate?.isInteractWithUser(bool: !bool)
        print(bool)
    }
}
