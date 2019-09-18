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

}

protocol IOGridViewCellDatasource: AnyObject {
    
    func inputSource() -> [String]
    
}

class IOGridViewCell: GridViewCell {
    
    weak var delegate: IOGridViewCellDelegate?
    
    weak var datasource: IOGridViewCellDatasource?
    
    let inputSourceButton = UIButton(type: .custom)
    
    @IBOutlet weak var inputSourceTextField: UITextField! {
        didSet {
            let inputPicker = UIPickerView()
            
            inputPicker.delegate = self
            
            inputPicker.dataSource = self
            
            inputSourceTextField.inputView = inputPicker
            
            inputSourceButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            inputSourceButton.setBackgroundImage(
                UIImage.asset(.NodeInputIconNormal),
                for: .normal
            )
            
            inputSourceButton.setBackgroundImage(
                UIImage.asset(.NodeInputIconSelected),
                for: .selected
            )
            
            inputSourceButton.isUserInteractionEnabled = false
            
            inputSourceTextField.rightView = inputSourceButton
            
            inputSourceTextField.rightViewMode = .always
            
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
    @IBAction func addPlugInButton(_ sender: UIButton) {
        let row = PlugInCreater.shared.plugInOntruck[self.indexPath.column].plugInArr.count
        let column = self.indexPath.column
        //再加上多種 plugin
        switch plugInSelectLabel.text {
        case "Reverb":
            delegate?.addPlugIn(with: .reverb(AKReverb()), row: row, column: column, cell: self)
        case "GuitarProcessor":
            delegate?.addPlugIn(with: .guitarProcessor(AKRhinoGuitarProcessor()), row: row, column: column, cell: self)
        case "Delay":
            delegate?.addPlugIn(with: .delay(AKDelay()), row: row, column: column, cell: self)
        case "Chorus":
            delegate?.addPlugIn(with: .chorus(AKChorus()), row: row, column: column, cell: self)
        default:
            print("error of selected plugIn.")
        }
        
        plugInSelectLabel.text = ""
        indexForSelectedPlugIn = 0
    }
    
    static var nib: UINib {
        return UINib(nibName: "IOGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let arr = datasource?.inputSource() else { return nil}
        return arr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let arr = datasource?.inputSource() else { return }
        inputSourceTextField.text = arr[row]
    }
}

extension IOGridViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let inputSource = inputSourceTextField.text else {return}
        
        if inputSource == "No Input" {
            inputSourceButton.isSelected = false
            delegate?.noInputSource(cell: self)
            return
        }
        
        delegate?.didSelectInputSource(inputSource: inputSource, cell: self)
       
        inputSourceButton.isSelected = true
    }
    
    
}
