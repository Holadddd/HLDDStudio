//
//  DrumEditingGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/25.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit
import AudioKit

protocol DrumEditingGridViewCellDelegate: AnyObject {
    
    func playSample(cell: GridViewCell)
    
    func changeDrumSample(cell: GridViewCell, drumType: DrumType, sampleIndex: Int)
    
    func panValueChange(cell: GridViewCell, value: Float)
    
    func volumeValueChange(cell: GridViewCell, value: Float)
    
    func deletDrumPattern(cell: GridViewCell)
    
    func changDrumType(cell: GridViewCell, drumType: DrumType)
}

class DrumEditingGridViewCell: GridViewCell {
    
    @IBOutlet weak var samplePlayButton: UIButton!
    
    let drumTypePicker = UIPickerView()
    
    @IBOutlet weak var typeTextField: UITextField! {
        
        didSet {
            
            drumTypePicker.delegate = self
            
            drumTypePicker.dataSource = self
            
            typeTextField.inputView = drumTypePicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 20,
                                  height: 20)
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            
            view.isUserInteractionEnabled = false
            
            view.addSubview(button)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            button.tintColor = .blue
            
            typeTextField.rightView = view
            
            typeTextField.rightViewMode = .unlessEditing
            
            typeTextField.delegate = self
        }
    }
    
    var drumType = DrumType.classic
    
    let samplePicker = UIPickerView()
    
    @IBOutlet weak var samplePickTextField: UITextField! {
        
        didSet {
            
            samplePicker.delegate = self
            
            samplePicker.dataSource = self
            
            samplePickTextField.inputView = samplePicker
            
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
    
    @IBOutlet weak var panKnob: Knob!
    
    @IBOutlet weak var volKnob: Knob!
    
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
        
        panKnob.minimumValue = -1.0
        
        panKnob.maximumValue = 1.0
        
        panKnob.delegate = self
        
        volKnob.minimumValue = 0.0
        
        volKnob.maximumValue = 2.0
        
        volKnob.delegate = self
    }
    
    deinit {
        
        print("DrumEditingGridViewCellDeinit\(self.indexPath)")
    }
    
    @objc func samplePlay(_ sender: Any) {
        
        delegate?.playSample(cell: self)
    }
}

extension DrumEditingGridViewCell: HLDDKnobDelegate {
    
    func knobValueDidChange(knobValue value: Float,
                            knob: Knob) {
        
        switch knob {
            
        case panKnob:
            
            delegate?.panValueChange(cell: self,
                                     value: value)
        case volKnob:
            
            delegate?.volumeValueChange(cell: self,
                                        value: value)
        default:
            
            break
        }
    }
    
    func knobIsTouching(bool: Bool,
                        knob: Knob) {
        
    }
    
}

extension DrumEditingGridViewCell: UIPickerViewDelegate {
    
}

extension DrumEditingGridViewCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        var numberOfRow = 0
        
        switch pickerView {
            
        case drumTypePicker:
            
            numberOfRow = DrumMachineManger.manger.drumTypeStringArr.count
        case samplePicker:
            
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
            
            numberOfRow = fileArr.count
        default:
            
            break
        }
        
        return numberOfRow
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var stringNeedStick = ""
        
        switch pickerView {
            
        case drumTypePicker:
            
            stringNeedStick = DrumMachineManger.manger.drumTypeStringArr[row]
        case samplePicker:
            
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
            
            stringNeedStick = fileArr[row].fileNamePlusExtension
        default:
            
            break
        }
        
        pickerView.backgroundColor = UIColor.B1
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.white
        
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let image = UIImageView.init(image: UIImage.asset(.StatusBarLayerView))
        
        image.clipsToBounds = true
        
        pickerLabel.backgroundColor = .clear
        
        image.stickSubView(pickerLabel)
        
        pickerLabel.text = stringNeedStick
        
        return image
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        switch pickerView {
            
        case drumTypePicker:
            
            if row > DrumMachineManger.manger.drumTypeStringArr.count {
                
                delegate?.deletDrumPattern(cell: self)
                
                return
            }
            
            guard let drumType = DrumType(rawValue: row)
                else { fatalError() }
            
            typeTextField.text = DrumMachineManger.manger.drumTypeStringArr[row]
            
            self.drumType = drumType
            
            switch drumType {
                
            case .classic:
                
                samplePickTextField.text = DrumMachineManger
                    .manger
                    .classicFileArr[DrumMachineManger.manger.defaultClassicFileIndex]
                    .fileNamePlusExtension
                
                samplePlayButton.setImage(UIImage.asset(.drumClassic),
                                          for: .normal)
            case .hihats:
                
                samplePickTextField.text = DrumMachineManger
                    .manger
                    .hihatsFileArr[DrumMachineManger.manger.defaultHihatsFileIndex]
                    .fileNamePlusExtension
                
                samplePlayButton.setImage(UIImage.asset(.drumHihats),
                                          for: .normal)
            case .kicks:
                samplePickTextField.text = DrumMachineManger
                    .manger
                    .kicksFileArr[DrumMachineManger.manger.defaultKickFileIndex]
                    .fileNamePlusExtension
                
                samplePlayButton.setImage(UIImage.asset(.drumKicks),
                                          for: .normal)
            case .percussion:
                
                samplePickTextField.text = DrumMachineManger
                    .manger
                    .percussionFileArr[DrumMachineManger.manger.defaultPercussionFileIndex]
                    .fileNamePlusExtension
                
                samplePlayButton.setImage(UIImage.asset(.drumPercussion),
                                          for: .normal)
            case .snares:
                samplePickTextField.text = DrumMachineManger
                    .manger
                    .snaresFileArr[DrumMachineManger.manger.defaultSnareFileIndex]
                    .fileNamePlusExtension
                
                samplePlayButton.setImage(UIImage.asset(.drumSnares),
                                          for: .normal)
            }
            
            delegate?.changDrumType(cell: self,
                                    drumType: drumType)
        case samplePicker:
            
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
        default:
            
            break
        }
    }
}

extension DrumEditingGridViewCell: UITextFieldDelegate{
    
}
