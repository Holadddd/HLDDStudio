//
//  DrumEditingHorizontalGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/26.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit
import AudioKit

class DrumEditingHorizontalGridViewCell: GridViewCell {
    
    @IBOutlet weak var statusBarContentView: UIView!
    
    
    @IBOutlet weak var samplePlayButton: UIButton!
    
    var drumType = DrumType.classic
    
    let inputPicker = UIPickerView()
    
    @IBOutlet weak var samplePickTextField: UITextField! {
        
        didSet {
            
            inputPicker.delegate = self
            
            inputPicker.dataSource = self
            
            samplePickTextField.inputView = inputPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 16,
                                  height: 16)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                            size: CGSize(width: 16, height: 16)))
            
            view.addSubview(button)
            
            view.isUserInteractionEnabled = false
            
            button.isUserInteractionEnabled = false
            
            samplePickTextField.rightView = view
            
            samplePickTextField.rightViewMode = .always
            
            samplePickTextField.delegate = self
        }
    }
    
    weak var delegate: DrumEditingGridViewCellDelegate?
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super .awakeFromNib()
        
        samplePlayButton.addTarget(self,
                                   action: #selector(samplePlay),
                                   for: .touchUpInside)
        
        samplePickTextField.isEnabled = true
    }
    
    override func layoutSubviews() {
        
    }
    
    @objc func samplePlay(_ sender: Any) {
        
        delegate?.playSample(cell: self)
    }
}

extension DrumEditingHorizontalGridViewCell: UIPickerViewDelegate {
    
}

extension DrumEditingHorizontalGridViewCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        var fileArr: [AKAudioFile] = []
        
        switch drumType {
            
        case .classic:
            
            fileArr = DrumMachineManger.manger.classicFileArr
        case .hihats:
            
            fileArr = DrumMachineManger.manger.hihatsFileArr
        case .kicks:
            
            fileArr = DrumMachineManger.manger.kicksFileArr
        case .percussion:
            
            fileArr = DrumMachineManger.manger.percussionFileArr
        case .snares:
            
            fileArr = DrumMachineManger.manger.snaresFileArr
        }
        
        return fileArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var fileArr: [AKAudioFile] = []
        
        switch drumType {
            
        case .classic:
            
            fileArr = DrumMachineManger.manger.classicFileArr
        case .hihats:
            
            fileArr = DrumMachineManger.manger.hihatsFileArr
        case .kicks:
            
            fileArr = DrumMachineManger.manger.kicksFileArr
        case .percussion:
            
            fileArr = DrumMachineManger.manger.percussionFileArr
        case .snares:
            
            fileArr = DrumMachineManger.manger.snaresFileArr
        }
        
        let fileName = fileArr[row]
        
        pickerView.backgroundColor = UIColor.B1
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.white
        
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let image = UIImageView.init(image: UIImage.asset(.StatusBarLayerView))
        
        image.clipsToBounds = true
        
        pickerLabel.backgroundColor = .clear
        
        image.stickSubView(pickerLabel)
        
        pickerLabel.text = fileName.fileNamePlusExtension
        
        return image
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        var fileArr: [AKAudioFile] = []
        
        switch drumType {
            
        case .classic:
            
            fileArr = DrumMachineManger.manger.classicFileArr
        case .hihats:
            
            fileArr = DrumMachineManger.manger.hihatsFileArr
        case .kicks:
            
            fileArr = DrumMachineManger.manger.kicksFileArr
        case .percussion:
            
            fileArr = DrumMachineManger.manger.percussionFileArr
        case .snares:
            
            fileArr = DrumMachineManger.manger.snaresFileArr
        }
        
        if fileArr.count != 0 {
            
            samplePickTextField.text = fileArr[row].fileNamePlusExtension
            
            delegate?.changeDrumSample(cell: self,
                                       drumType: drumType,
                                       sampleIndex: row)
        }
    }
}

extension DrumEditingHorizontalGridViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
