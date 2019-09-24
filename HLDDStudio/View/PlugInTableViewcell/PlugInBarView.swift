//
//  plugInBar.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol PlugInBarViewDatasource: AnyObject {
    //先寫成字串之後要再管理
    func presetParameter() -> [String]?
}

protocol PlugInBarViewDelegate: AnyObject {
    
    func isBypass(_ bool: Bool)
    
    func plugInPresetSelect(_ parameter: String)
}

protocol PlugInControlDelegate: AnyObject {
    
    func plugInBypassSwitch(_ isBypass: Bool, cell: UITableViewCell)
    
    func plugInReverbFactorySelect(_ factoryRawValue: Int, cell: PlugInReverbTableViewCell)
    
    func dryWetMixValueChange(_ value: Float, cell: UITableViewCell)
    
    func guitarProcessorValueChange(_ value: Float, type: GuitarProcessorValueType, cell: UITableViewCell)
    
    func delayValueChange(_ value: Float, type: DelayValueType, cell: UITableViewCell)
    
    func chorusValueChange(_ value: Float, type: ChorusValueType, cell: UITableViewCell)
}

protocol PlugInControlDatasource: AnyObject {
    
    func plugInReverbPresetParameter(cell: PlugInReverbTableViewCell) -> [String]?
    
}
class PlugInBarView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var presetTextField: UITextField! {
        didSet {
            let presetPicker = UIPickerView()
            
            presetPicker.delegate = self
            
            presetPicker.dataSource = self
            
            presetTextField.inputView = presetPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(UIImage.asset(.Icons_24px_DropDown), for: .normal)
            button.isUserInteractionEnabled = false
            
            presetTextField.rightView = button
            
            presetTextField.rightViewMode = .always
            
            presetTextField.delegate = self
        }
    }
    
    @IBOutlet weak var plugInTitleLabel: UILabel!
    
    @IBOutlet weak var bypassButton: UIButton!
    
    weak var delegate: PlugInBarViewDelegate?
    
    weak var datasource: PlugInBarViewDatasource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initPlugInBarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPlugInBarView()
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
    }

    private func initPlugInBarView() {
        Bundle.main.loadNibNamed("PlugInBarView", owner: self, options: nil)
        stickSubView(contentView)
        bypassButton.addTarget(self, action: #selector(PlugInBarView.bypassButtonAction), for: .touchUpInside)
    }
    
    @objc func bypassButtonAction() {
        bypassButton.isSelected = !bypassButton.isSelected
        delegate?.isBypass(bypassButton.isSelected)
        
    }
    
}

extension PlugInBarView: UIPickerViewDelegate {
    
}

extension PlugInBarView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let preset = datasource?.presetParameter()
        return preset?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.backgroundColor = UIColor.B1
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let image = UIImageView.init(image: UIImage.asset(.StatusBarLayerView))
        image.clipsToBounds = true
        pickerLabel.backgroundColor = .clear
        image.stickSubView(pickerLabel)
        
        let preset = datasource?.presetParameter()
        
        pickerLabel.text = preset?[row] ?? nil
        return image
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let preset = datasource?.presetParameter() else { return }
        presetTextField.text = preset[row]
    }
    
}

extension PlugInBarView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let parameter = textField.text else { return }
        delegate?.plugInPresetSelect(parameter)
    }
    
}
