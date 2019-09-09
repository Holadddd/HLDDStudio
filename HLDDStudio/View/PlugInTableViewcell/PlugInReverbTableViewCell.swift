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

protocol PlugInReverbTableViewCellDelegate: AnyObject {
    
    func plugInReverbBypassSwitch(_ isBypass: Bool, cell: PlugInReverbTableViewCell)
    
    func plugInReverbFactorySelect(_ factory: String)
    
    func dryWetMixValueChange(_ sender: UISlider)
}

protocol PlugInReverbTableViewCellDatasource: AnyObject {
    
    func plugInReverbPresetParameter() -> [String]?
}

class PlugInReverbTableViewCell: UITableViewCell {
    
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
    
    @IBOutlet weak var dryWetMixSlider: UISlider!
    
    weak var delegate: PlugInReverbTableViewCellDelegate?
    
    weak var datasource: PlugInReverbTableViewCellDatasource?
    
    static var nib: UINib {
        return UINib(nibName: "PlugInReverbTableViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        plugInBarView.delegate = self
        plugInBarView.datasource = self
        
        dryWetMixSlider.addTarget(self, action: #selector(PlugInReverbTableViewCell.sliderValueChange), for: UIControl.Event.valueChanged)
    }
    
    @objc func sliderValueChange(_ sender: UISlider) {
        dryWetMixLabel.text = String(format: "%.2f", sender.value)
        delegate?.dryWetMixValueChange(sender)
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reverbFactory[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        factoryTextField.text = reverbFactory[row]
    }
}

extension PlugInReverbTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let factory = textField.text else { return }
        delegate?.plugInReverbFactorySelect(factory)
    }
}

extension PlugInReverbTableViewCell: PlugInBarViewDelegate {
    
    func plugInPresetSelect(_ parameter: String) {
        print("Set parameter as:\(parameter)")
    }
    
    func isBypass(_ bool: Bool) {
        delegate?.plugInReverbBypassSwitch(bool, cell: self)
    }

}

extension PlugInReverbTableViewCell: PlugInBarViewDatasource {
    
    func presetParameter() -> [String]? {
        
        return datasource?.plugInReverbPresetParameter()
        
    }
    
}
