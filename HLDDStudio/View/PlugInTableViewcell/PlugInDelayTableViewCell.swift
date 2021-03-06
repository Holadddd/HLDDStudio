//
//  PlugInDelayTableViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/18.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class PlugInDelayTableViewCell: UITableViewCell, HLDDKnobDelegate {

    @IBOutlet weak var plugInBarView: PlugInBarView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var mixLabel: UILabel!
    
    @IBOutlet weak var timeKnob: Knob!
    
    @IBOutlet weak var feedbackKnob: Knob!
    
    @IBOutlet weak var mixKnob: Knob!
    
    weak var delegate: PlugInControlDelegate?
    
    weak var datasource: PlugInControlDatasource?
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        plugInBarView.delegate = self
        
        plugInBarView.datasource = self
        //set timeKnob
        timeKnob.delegate = self
        
        timeKnob.maximumValue = PlugInManager.shared.defaultParameter.delay.maxTime
        
        timeKnob.minimumValue = PlugInManager.shared.defaultParameter.delay.minTime
        //set feedbackKnob
        feedbackKnob.delegate = self
        
        feedbackKnob.maximumValue = PlugInManager.shared.defaultParameter.delay.maxFeedback
        
        feedbackKnob.minimumValue = PlugInManager.shared.defaultParameter.delay.minFeedback
        //set mixKnob
        mixKnob.delegate = self
        
        mixKnob.maximumValue = PlugInManager.shared.defaultParameter.delay.maxDryWetMix
        
        mixKnob.minimumValue = PlugInManager.shared.defaultParameter.delay.minDryWetMix
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected,
                          animated: animated)
    }
    
    func knobValueDidChange(knobValue value: Float,
                            knob: Knob) {
        
        switch knob {
            
        case timeKnob:
            
            timeLabel.text = String(format: "%.2f", value)
            
            delegate?.delayValueChange(value, type: .time,
                                       cell: self)
        case feedbackKnob:
            
            feedbackLabel.text = String(format: "%.2f", value)
            
            delegate?.delayValueChange(value, type: .feedback,
                                       cell: self)
        case mixKnob:
            
            mixLabel.text = String(format: "%.2f", value)
            
            delegate?.delayValueChange(value, type: .mix,
                                       cell: self)
        default:
            
            break
        }
    }
    
    func knobIsTouching(bool: Bool,
                        knob: Knob) {
        
    }
}

extension PlugInDelayTableViewCell: PlugInBarViewDelegate {
    
    func isBypass(_ bool: Bool) {
        
        delegate?.plugInBypassSwitch(bool,
                                     cell: self)
        
        timeKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        feedbackKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        mixKnob.isEnabled = !plugInBarView.bypassButton.isSelected
    }
    
    func plugInPresetSelect(_ parameter: String) {
        
    }
}

extension PlugInDelayTableViewCell: PlugInBarViewDatasource {
    
    func presetParameter() -> [String]? {
        
        return nil
    }
}
