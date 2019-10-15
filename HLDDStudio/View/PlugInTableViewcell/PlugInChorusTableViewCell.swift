//
//  PlugInChorusTableViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/18.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class PlugInChorusTableViewCell: UITableViewCell, HLDDKnobDelegate {
    
    @IBOutlet weak var plugInBarView: PlugInBarView!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var feedbackKnob: Knob!
    
    @IBOutlet weak var depthLabel: UILabel!
    
    @IBOutlet weak var depthKnob: Knob!
    
    @IBOutlet weak var mixLabel: UILabel!
    
    @IBOutlet weak var mixKnob: Knob!
    
    @IBOutlet weak var frequencyLabel: UILabel!
    
    @IBOutlet weak var frequencyKnob: Knob!
    
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
        //set feedbackKnob
        feedbackKnob.delegate = self
        
        feedbackKnob.maximumValue = PlugInManager.shared.defaultParameter.chorus.maxFeedback
        
        feedbackKnob.minimumValue = PlugInManager.shared.defaultParameter.chorus.minFeedback
        //set depthKnob
        depthKnob.delegate = self
        
        depthKnob.maximumValue = PlugInManager.shared.defaultParameter.chorus.maxDepth
        
        depthKnob.minimumValue = PlugInManager.shared.defaultParameter.chorus.minDepth
        //set mixKnob
        mixKnob.delegate = self
        
        mixKnob.maximumValue = PlugInManager.shared.defaultParameter.chorus.maxDryWetMix
        
        mixKnob.minimumValue = PlugInManager.shared.defaultParameter.chorus.minDryWetMix
        //set frequencyKnob
        frequencyKnob.delegate = self
        
        frequencyKnob.maximumValue = PlugInManager.shared.defaultParameter.chorus.maxFrequency
        
        frequencyKnob.minimumValue = PlugInManager.shared.defaultParameter.chorus.minFrequency
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected, animated:
            animated)
    }
    
    func knobValueDidChange(knobValue value: Float,
                            knob: Knob) {
        
        switch knob {
            
        case feedbackKnob:
            
            feedbackLabel.text = String(format: "%.2f", value)
            
            delegate?.chorusValueChange(value,
                                        type: .feedback,
                                        cell: self)
        case depthKnob:
            
            depthLabel.text = String(format: "%.2f", value)
            
            delegate?.chorusValueChange(value,
                                        type: .depth,
                                        cell: self)
        case mixKnob:
            
            mixLabel.text = String(format: "%.2f", value)
            
            delegate?.chorusValueChange(value,
                                        type: .mix,
                                        cell: self)
        case frequencyKnob:
            
            frequencyLabel.text = String(format: "%.2f Hz", value)
            
            delegate?.chorusValueChange(value,
                                        type: .frequency,
                                        cell: self)
        default:
            
            break
        }
    }
    
    func knobIsTouching(bool: Bool,
                        knob: Knob) {
        
    }
}

extension PlugInChorusTableViewCell: PlugInBarViewDelegate{
    
    func isBypass(_ bool: Bool) {
        
        delegate?.plugInBypassSwitch(bool,
                                     cell: self)
        
        feedbackKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        depthKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        mixKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        frequencyKnob.isEnabled = !plugInBarView.bypassButton.isSelected
    }
    
    func plugInPresetSelect(_ parameter: String) {
        
    }
}


extension PlugInChorusTableViewCell: PlugInBarViewDatasource{
    
    func presetParameter() -> [String]? {
        
        return nil
    }
}
