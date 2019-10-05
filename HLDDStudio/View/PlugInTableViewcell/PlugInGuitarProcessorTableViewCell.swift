//
//  PlugInGuitarProcessorTableViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/18.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class PlugInGuitarProcessorTableViewCell: UITableViewCell, HLDDKnobDelegate {

    @IBOutlet weak var plugInBarView: PlugInBarView!
    
    @IBOutlet weak var preGainLabel: UILabel!
    
    @IBOutlet weak var distLabel: UILabel!
    
    @IBOutlet weak var outputGainLabel: UILabel!
    
    @IBOutlet weak var preGainKnob: Knob!
    
    @IBOutlet weak var disKnob: Knob!
    
    @IBOutlet weak var outputKnob: Knob!
    
    weak var delegate: PlugInControlDelegate?
    
    weak var datasource: PlugInControlDatasource?
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        plugInBarView.delegate = self
        
        plugInBarView.datasource = self
        //set preGainKnob
        preGainKnob.delegate = self
        
        preGainKnob.maximumValue = PlugInManager.shared.defaultParameter.guitarProcessor.maxPreGain
        
        preGainKnob.minimumValue = PlugInManager.shared.defaultParameter.guitarProcessor.minPreGain
        //set disKnob
        disKnob.delegate = self
        
        disKnob.maximumValue = PlugInManager.shared.defaultParameter.guitarProcessor.maxDis
        
        disKnob.minimumValue = PlugInManager.shared.defaultParameter.guitarProcessor.minDis
        //set outputKnob
        outputKnob.delegate = self
        
        outputKnob.maximumValue = PlugInManager.shared.defaultParameter.guitarProcessor.maxOutput
        
        outputKnob.minimumValue = PlugInManager.shared.defaultParameter.guitarProcessor.minOutput
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        
        super.setSelected(selected, animated:
            animated)
    }
    
    func knobValueDidChange(knobValue value: Float,
                            knob: Knob) {
        
        switch knob {
            
        case preGainKnob:
            
            preGainLabel.text = String(format: "%.2f", value)
            
            delegate?.guitarProcessorValueChange(value,
                                                 type: .HLDDPreGain,
                                                 cell: self)
        case disKnob:
            
            distLabel.text = String(format: "%.2f", value)
            
            delegate?.guitarProcessorValueChange(value,
                                                 type: .dist,
                                                 cell: self)
        case outputKnob:
            
            outputGainLabel.text = String(format: "%.2f", value)
            
            delegate?.guitarProcessorValueChange(value,
                                                 type: .outputGain,
                                                 cell: self)
        default:
            
            return
        }
    }
    
    func knobIsTouching(bool: Bool,
                        knob: Knob) {
       
    }
}

extension PlugInGuitarProcessorTableViewCell: PlugInBarViewDelegate {
    
    func plugInPresetSelect(_ parameter: String) {
        
    }
    
    func isBypass(_ bool: Bool) {
        delegate?.plugInBypassSwitch(bool,
                                     cell: self)
        
        preGainKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        disKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
        outputKnob.isEnabled = !plugInBarView.bypassButton.isSelected
    }
}

extension PlugInGuitarProcessorTableViewCell: PlugInBarViewDatasource {
    
    func presetParameter() -> [String]? {
        
        return nil
    }
}
