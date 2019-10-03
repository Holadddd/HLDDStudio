//
//  IOGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView
import MarqueeLabel

protocol IOGridViewCellDelegate: AnyObject {
    
    func noInputSource(cell: IOGridViewCell)
    
    func didSelectInputSource(inputSource: String, cell: IOGridViewCell)
    
    func addPlugIn(with plugIn: PlugIn, row: Int, column: Int, cell: IOGridViewCell)
    
    func didSelectDrumMachine(cell: IOGridViewCell)

}

protocol IOGridViewCellDatasource: AnyObject {
    
    func inputSource() -> [String]
    
}

class IOGridViewCell: GridViewCell {
    
    weak var delegate: IOGridViewCellDelegate?
    
    weak var datasource: IOGridViewCellDatasource?
    
    let inputSourceButton = UIButton(type: .custom)
    
    let inputPicker = UIPickerView()
    
    @IBOutlet weak var inputSourceTextField: UITextField! {
        didSet {
            
            inputPicker.delegate = self
            
            inputPicker.dataSource = self
            
            inputSourceTextField.inputView = inputPicker
            
            inputSourceButton.frame = CGRect(x: 0, y: 0, width: inputSourceTextField.frame.width, height: inputSourceTextField.frame.height)
            
            inputSourceButton.setBackgroundImage(
                UIImage.asset(.NodeInputIconNormal),
                for: .normal
            )
            
            inputSourceButton.setBackgroundImage(
                UIImage.asset(.NodeInputIconSelected),
                for: .selected
            )
            
            inputSourceButton.isUserInteractionEnabled = false
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: inputSourceTextField.frame.width, height: inputSourceTextField.frame.height))
            
            view.addSubview(inputSourceButton)
            
            view.isUserInteractionEnabled = false
            
            inputSourceTextField.leftView = view
            
            inputSourceTextField.leftViewMode = .always
            
            inputSourceTextField.delegate = self
            
        }
    }
   
    @IBOutlet weak var busLabel: UILabel!
    
    @IBOutlet weak var plugInSelectLabel: UILabel!
    
    var indexForSelectedPlugIn = 0
    
    @IBAction func plugInSwitchSelectedButton(_ sender: UIButton) {
        let existPlugInNumber = existPlugInArr.count
        let plugIn = existPlugInArr[indexForSelectedPlugIn % existPlugInNumber]
        plugInSelectLabel.text = plugIn
        indexForSelectedPlugIn += 1
    }
    
    @IBOutlet weak var selectedInputLabel:MarqueeLabel!
    //需要寫一個 singleTon 的 manger 管理
    
    @IBOutlet weak var addPlugInButton: UIButton!
    
    static var nib: UINib {
        return UINib(nibName: "IOGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        inputSourceTextField.isEnabled = MixerManger.manger.isenabledMixerFunctionalButton
        addPlugInButton.isEnabled = MixerManger.manger.isenabledMixerFunctionalButton
        
        addPlugInButton.addTarget(self, action: #selector(addPlugInButtonAction(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(enabledIOButton(_:)), name: .enabledIOButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disabledIOButton(_:)), name: .disabledIOButton, object: nil)
    }
    
    @objc func addPlugInButtonAction(_ sender: UIButton) {
        
        let row = PlugInManager.shared.plugInOntruck[self.indexPath.column].plugInArr.count
        let column = self.indexPath.column
        //再加上多種 plugin
        switch plugInSelectLabel.text {
        case PlugInDescription.reverb.rawValue:
            delegate?.addPlugIn(with: .reverb(AKReverb()), row: row, column: column, cell: self)
        case PlugInDescription.guitarProcessor.rawValue:
            delegate?.addPlugIn(with: .guitarProcessor(AKRhinoGuitarProcessor()), row: row, column: column, cell: self)
        case PlugInDescription.delay.rawValue:
            delegate?.addPlugIn(with: .delay(AKDelay()), row: row, column: column, cell: self)
        case PlugInDescription.chorus.rawValue:
            delegate?.addPlugIn(with: .chorus(AKChorus()), row: row, column: column, cell: self)
        default:
            break
        }
        
        plugInSelectLabel.text = ""
        indexForSelectedPlugIn = 0
    }

    @objc func enabledIOButton(_ notification: Notification){
        inputSourceTextField.isEnabled = true
        addPlugInButton.isEnabled = true
    }
    @objc func disabledIOButton(_ notification: Notification){
        inputSourceTextField.isEnabled = false
        addPlugInButton.isEnabled = false
    }
}

extension IOGridViewCell: UIPickerViewDelegate {
    
}

extension IOGridViewCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let arr = datasource?.inputSource() else { return 0}
        return arr.count
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
        
        guard let arr = datasource?.inputSource() else { fatalError() }
        pickerLabel.text = arr[row]
        return image
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let arr = datasource?.inputSource() else { return }
        inputSourceTextField.text = arr[row]
    }
}

extension IOGridViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let inputSource = inputSourceTextField.text else {return}
        
        if inputSource == InputSourceCase.noInput.rawValue {
            inputSourceButton.isSelected = false
            delegate?.noInputSource(cell: self)
            return
        }
        
        if inputSource == "\(InputSourceCase.drumMachine.rawValue)(\(DrumMachineManger.manger.bpm))" {
            if self.indexPath.column == 0 {
                if PlugInManager.shared.plugInOntruck[0].trackInputStatus == .drumMachine {
                    inputSourceButton.isSelected = false
                    delegate?.noInputSource(cell: self)
                    return
                }
            } else {
                if PlugInManager.shared.plugInOntruck[1].trackInputStatus == .drumMachine {
                    inputSourceButton.isSelected = false
                    delegate?.noInputSource(cell: self)
                    return
                }
            }
            inputSourceButton.isSelected = true
            delegate?.didSelectDrumMachine(cell: self)
            return
        }
        
        delegate?.didSelectInputSource(inputSource: inputSource, cell: self)
       
        inputSourceButton.isSelected = true
    }
    
    
}
