//
//  MixerView.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import G3GridView
import AVKit
import AudioKit
import IQKeyboardManager


protocol MixerDelegate: AnyObject {

    func didSelectInputDevice(_ deviceID: DeviceID)
    
    func metronomeSwitch(isOn: Bool)
    
    func metronomeBPM(bpm:Int)
    
    func stopAudioPlayer()
    
    func playingAudioPlayer()
    
    func resumeAudioPlayer()
    
    func pauseAudioPlayer()
    
    func startRecordAudioPlayer(frombar start: Int, tobar stop:Int)
    
    func stopRecord()
}

protocol MixerDatasource: AnyObject {
    
    func currentInputDevice() -> DeviceID
    
    func nameOfInputDevice() -> [DeviceID]
}

class MixerView: UIView {
    
    @IBOutlet weak var iOStatusBar: UIView!
    
    @IBOutlet weak var barLabel: UILabel!
    
    let inputPicker = UIPickerView()
    
    @IBOutlet weak var inputDeviceTextField: UITextField! {
        
        didSet {
            
            inputPicker.delegate = self
            
            inputPicker.dataSource = self
            
            inputDeviceTextField.inputView = inputPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            inputDeviceTextField.rightView = button
            
            inputDeviceTextField.rightViewMode = .always
            
            inputDeviceTextField.delegate = self
            
        }
        
    }
    
    @IBOutlet weak var playingBarsLabel: UILabel!
    
    let routePickerView = AVRoutePickerView()
    
    @IBOutlet weak var metronomeButton: UIButton!
    
    var tempoArr: [Int] = []
    
    let tempoPicker = UIPickerView()
    
    @IBOutlet weak var tempoTextField: UITextField! {
        didSet {
            
            tempoPicker.delegate = self
            
            tempoPicker.dataSource = self
            
            tempoTextField.inputView = tempoPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            tempoTextField.rightView = button
            
            tempoTextField.rightViewMode = .always
            
            tempoTextField.delegate = self
        }
    }
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var playAndResumeButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    var barArr:[Int] = []
    
    let startBarPicker = UIPickerView()
    
    @IBOutlet weak var startRecordTextField: UITextField! {
        didSet {
            
            startBarPicker.delegate = self
            
            startBarPicker.dataSource = self
            
            startRecordTextField.inputView = startBarPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            startRecordTextField.rightView = button
            
            startRecordTextField.rightViewMode = .always
            
            startRecordTextField.delegate = self
        }
    }
    
    let stopBarPicker = UIPickerView()
    
    @IBOutlet weak var stopRecordTextField: UITextField! {
        didSet {
            
            stopBarPicker.delegate = self
            
            stopBarPicker.dataSource = self
            
            stopRecordTextField.inputView = stopBarPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            stopRecordTextField.rightView = button
            
            stopRecordTextField.rightViewMode = .always
            
            stopRecordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var trackGridView: GridView!
    
    weak var delegate: MixerDelegate?
    
    weak var datasource: MixerDatasource?
  
    override func awakeFromNib() {
        super .awakeFromNib()
        trackGridView.register(IOGridViewCell.nib, forCellWithReuseIdentifier: "IOGridViewCell")
        trackGridView.register(PlugInGridViewCell.nib, forCellWithReuseIdentifier: "PlugInGridViewCell")
        trackGridView.register(FaderGridViewCell.nib, forCellWithReuseIdentifier: "FaderGridViewCell")
        trackGridView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        trackGridView.superview?.clipsToBounds = true
        trackGridView.contentSize = self.bounds.size
        
        trackGridView.isInfinitable = false
        trackGridView.maximumScale = Scale(x: 1, y: 1)
        trackGridView.minimumScale = Scale(x: 1, y: 1)
        
        
        setRouterPiskerView()
        
        metronomeButton.addTarget(self, action: #selector(MixerView.metronomeState), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(MixerView.stopButtonAction), for: .touchUpInside)
        playAndResumeButton.addTarget(self, action: #selector(MixerView.playAndResumeButtonAction), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(MixerView.recordButtonAction), for: .touchUpInside)
        
        for tempo in 40...240 {
            tempoArr.append(tempo)
        }
        
        for bar in 1...40 {
            barArr.append(bar)
        }
    }
    
}
//IOStatusBar
extension MixerView {
    
    func setRouterPiskerView() {
        iOStatusBar.addSubview(routePickerView)
        let h = iOStatusBar.bounds.height
        let w = iOStatusBar.bounds.width
        routePickerView.frame = CGRect(origin: CGPoint(x: w - h - 8, y: 0), size: CGSize(width: h, height: h))
    }
}

extension MixerView: UIPickerViewDelegate {
    
}

extension MixerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case inputPicker:
            guard let inputDeviceNameArr = datasource?.nameOfInputDevice() else { fatalError() }
            return inputDeviceNameArr.count
        case tempoPicker:
            return tempoArr.count
        case startBarPicker:
            return barArr.count
        case stopBarPicker:
            return barArr.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView{
        case inputPicker:
            guard let inputDeviceNameArr = datasource?.nameOfInputDevice() else { fatalError() }
            return inputDeviceNameArr[row]
        case tempoPicker:
            return "\(tempoArr[row])"
        case startBarPicker:
            return "\(barArr[row])"
        case stopBarPicker:
            return "\(barArr[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView{
        case inputPicker:
            guard let inputDeviceNameArr = datasource?.nameOfInputDevice() else { fatalError() }
            inputDeviceTextField.text = inputDeviceNameArr[row]
        case tempoPicker:
            tempoTextField.text = "\(tempoArr[row])"
        case startBarPicker:
            startRecordTextField.text = "\(barArr[row])"
        case stopBarPicker:
            stopRecordTextField.text = "\(barArr[row])"
        default:
            return
        }
        
    }
}

extension MixerView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField{
        case inputDeviceTextField:
            guard let devieID = textField.text else { return }
            delegate?.didSelectInputDevice(devieID)
        case tempoTextField:
            guard let bpmString = tempoTextField.text else { return }
            guard let bpm = Int(bpmString) else { return }
            delegate?.metronomeBPM(bpm: bpm)
        case startRecordTextField:
            print(startRecordTextField.text!)
        case stopRecordTextField:
            print(stopRecordTextField.text!)
        default:
            return
        }
        
    }
}

extension MixerView {
    
    @objc func metronomeState() {
        metronomeButton.isSelected = !metronomeButton.isSelected
        delegate?.metronomeSwitch(isOn: metronomeButton.isSelected)
    }
    
    @objc func stopButtonAction() {
        playAndResumeButton.isSelected = false
        delegate?.stopAudioPlayer()
    }
    
    @objc func playAndResumeButtonAction() {
        playAndResumeButton.isSelected = !playAndResumeButton.isSelected
        switch playAndResumeButton.isSelected {
        case true:
            delegate?.playingAudioPlayer()
        case false:
            delegate?.pauseAudioPlayer()
        }
    }
    
    @objc func recordButtonAction() {
        
        switch recordButton.isSelected {
        case false:
            //playAndResumeButtonAction()
            guard let startString = startRecordTextField.text else { return }
            guard let stopString = stopRecordTextField.text else { return }
            guard let start = Int(startString) else { return }
            guard let stop = Int(stopString) else { return }
            delegate?.startRecordAudioPlayer(frombar: start, tobar: stop)
            
        case true:
            //playAndResumeButtonAction()
            delegate?.stopRecord()
        }
        
        recordButton.isSelected = !recordButton.isSelected
        //Switch playing button but not doing playing audio function
        playAndResumeButton.isSelected = !playAndResumeButton.isSelected
    }
}
