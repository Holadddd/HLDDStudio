//
//  PlugInReverbTableViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

class PlugInReverbTableViewCell: UITableViewCell, HLDDKnobDelegate {
    
    @IBOutlet weak var plugInBarView: PlugInBarView!
    
    @IBOutlet weak var factoryTextField: UITextField! {
        didSet {
            let factoryPicker = UIPickerView()
            
            factoryPicker.delegate = self
            
            factoryPicker.dataSource = self
            
            factoryTextField.inputView = factoryPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(UIImage.asset(.Icons_24px_DropDown), for: .normal)
            button.isUserInteractionEnabled = false
            
            factoryTextField.rightView = button
            
            factoryTextField.rightViewMode = .always
            
            factoryTextField.delegate = self
        }
    }
    
    @IBOutlet weak var dryWetMixLabel: UILabel!
    
    @IBOutlet weak var dryWetMixKnob: Knob!
    
    weak var delegate: PlugInControlDelegate?
    
    weak var datasource: PlugInControlDatasource?
    
    static var nib: UINib {
        return UINib(nibName: "PlugInReverbTableViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        plugInBarView.delegate = self
        plugInBarView.datasource = self
        dryWetMixKnob.delegate = self
        dryWetMixKnob.minimumValue = 0.0
        dryWetMixKnob.maximumValue = 1.0
    
    }
    
    func knobValueDidChange(knobValue value: Float, knob: Knob) {
        dryWetMixLabel.text = String(format: "%.2f", value)
        delegate?.dryWetMixValueChange(value, cell: self)
        
    }
    
    func knobIsTouching(bool: Bool, knob: Knob) {
        
    }
}

extension PlugInReverbTableViewCell: UIPickerViewDelegate {
    
}

extension PlugInReverbTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reverbFactory.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return reverbFactory[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.backgroundColor = .darkGray
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.backgroundColor = .gray
        pickerLabel.text = reverbFactory[row]
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        factoryTextField.text = reverbFactory[row]
    }
}

extension PlugInReverbTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let factory = textField.text else { return }
        guard let numberInFactory = reverbFactory.firstIndex(of: factory) else { fatalError()}
        delegate?.plugInReverbFactorySelect(numberInFactory, cell: self)
        
    }
}

extension PlugInReverbTableViewCell: PlugInBarViewDelegate {
    
    func plugInPresetSelect(_ parameter: String) {
        print("Set parameter as:\(parameter)")
    }
    
    func isBypass(_ bool: Bool) {
        delegate?.plugInBypassSwitch(bool, cell: self)
        
        factoryTextField.isEnabled = !plugInBarView.bypassButton.isSelected
        dryWetMixKnob.isEnabled = !plugInBarView.bypassButton.isSelected
        
    }

}

extension PlugInReverbTableViewCell: PlugInBarViewDatasource {
    
    func presetParameter() -> [String]? {
        
        return datasource?.plugInReverbPresetParameter(cell: self)
        
    }
    
}
