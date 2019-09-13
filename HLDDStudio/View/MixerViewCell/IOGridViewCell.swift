//
//  IOGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import G3GridView

protocol IOGridViewCellDelegate: AnyObject {
    func didSelectInputSource(inputSource: String)
    
    func addPlugIn(with plugIn: PlugIn<IndexPath>)

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
    
    @IBOutlet weak var selectedInputLabel: UILabel!
    //需要寫一個 singleTon 的 manger 管理
    @IBAction func addPlugInButton(_ sender: UIButton) {
        delegate?.addPlugIn(with: .reverb(IndexPath(row: 0, column: 0)))
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
        delegate?.didSelectInputSource(inputSource: inputSource)
       
        inputSourceButton.isSelected = true
    }
    
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
