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
import MarqueeLabel
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
    
    func changeRecordFileName(fileName: String)
    
    func masterVolumeDidChange(volume: Float)
    
    func showDrumVC()
}

protocol MixerDatasource: AnyObject {
    
    func currentInputDevice() -> DeviceID
    
    func nameOfInputDevice() -> [DeviceID]
    
    func trackInputStatusIsReadyForRecord() -> Bool

}

protocol GridViewStopScrollingWhileUIKitIsTouchingDelegate: AnyObject {
    
    func isInteractWithUser(bool: Bool)
}

class MixerView: UIView {
    
    @IBOutlet weak var iOStatusBar: UIView!
    
    @IBOutlet weak var barLabel: UILabel!
    
    @IBOutlet weak var notificationTitleLabel: MarqueeLabel!
    
    @IBOutlet weak var notificationSubTitleLabel: MarqueeLabel!
    
    let inputPicker = UIPickerView()
    
    let inputDeviceButton = UIButton(type: .custom)
    
    @IBOutlet weak var inputDeviceTextField: UITextField! {
        
        didSet {
            
            inputPicker.delegate = self
            
            inputPicker.dataSource = self
            
            inputDeviceTextField.inputView = inputPicker
            
            inputDeviceButton.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            
            view.isUserInteractionEnabled = false
            
            view.addSubview(inputDeviceButton)
            
            inputDeviceButton.setBackgroundImage(
                UIImage.asset(.DeviceInput4),
                for: .normal
            )
            
            inputDeviceButton.setBackgroundImage(
                UIImage.asset(.DeviceInput3),
                for: .selected
            )
            
            inputDeviceButton.isUserInteractionEnabled = false
            
            inputDeviceButton.tintColor = .blue
            
            inputDeviceTextField.leftView = view
            
            inputDeviceTextField.leftViewMode = .always
            
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
            
            tempoTextField.text = "60"
            
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
    
    let button = UIButton(type: .custom)
    
    @IBOutlet weak var stopRecordTextField: UITextField! {
        didSet {
            
            stopBarPicker.delegate = self
            
            stopBarPicker.dataSource = self
            
            stopRecordTextField.inputView = stopBarPicker
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            button.bounds.size = CGSize(width: 24, height: 24)
            
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
    
    //MasterFader
    @IBOutlet weak var fileNameTextField: UITextField! {
        didSet {
            fileNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var showDrumVCButton: UIButton!
    
    @IBOutlet weak var masterFader: RedFader!
    
    weak var delegate: MixerDelegate?
    
    weak var datasource: MixerDatasource?
  
    override func awakeFromNib() {
        super .awakeFromNib()
        trackGridView.register(IOGridViewCell.nib, forCellWithReuseIdentifier: "IOGridViewCell")
        trackGridView.register(PlugInGridViewCell.nib, forCellWithReuseIdentifier: "PlugInGridViewCell")
        trackGridView.register(FaderGridViewCell.nib, forCellWithReuseIdentifier: "FaderGridViewCell")
        trackGridView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        trackGridView.bounces = false
        trackGridView.isPagingEnabled = true
        trackGridView.isDirectionalLockEnabled = true
        trackGridView.clipsToBounds = true
        //trackGridView.superview?.clipsToBounds = true
        trackGridView.contentSize = self.bounds.size
        
        trackGridView.isInfinitable = false
        trackGridView.maximumScale = Scale(x: 1, y: 1)
        trackGridView.minimumScale = Scale(x: 1, y: 1)
        
        setRouterPiskerView()
        inputDeviceButton.isSelected = true
        
        metronomeButton.addTarget(self, action: #selector(MixerView.metronomeState), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(MixerView.stopButtonAction), for: .touchUpInside)
        playAndResumeButton.addTarget(self, action: #selector(MixerView.playAndResumeButtonAction), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(MixerView.recordButtonAction), for: .touchUpInside)
        showDrumVCButton.addTarget(self, action: #selector(MixerView.showDrumVCButtonAction), for: .touchUpInside)
        
        masterFader.delegate = self
        
        for tempo in 40...240 {
            tempoArr.append(tempo)
        }
        
        for bar in 1...40 {
            barArr.append(bar)
        }
        
    }
    
    override func layoutSubviews() {
//        super.layoutSubviews()
        let h = iOStatusBar.bounds.height
        let w = iOStatusBar.bounds.width
        routePickerView.frame = CGRect(origin: CGPoint(x: w - h * 1.05, y: 0), size: CGSize(width: h, height: h))
        
    }

}
//IOStatusBar
extension MixerView {
    
    func setRouterPiskerView() {
        
        iOStatusBar.addSubview(routePickerView)
        
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.backgroundColor = UIColor.B1
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let image = UIImageView.init(image: UIImage.asset(.StatusBarLayerView))
        
        pickerLabel.backgroundColor = .clear
        image.stickSubView(pickerLabel)
        switch pickerView{
        case inputPicker:
            guard let inputDeviceNameArr = datasource?.nameOfInputDevice() else { fatalError() }
            pickerLabel.text = inputDeviceNameArr[row]
            
        case tempoPicker:
            pickerLabel.text = "\(tempoArr[row])"
        case startBarPicker:
            pickerLabel.text = "\(barArr[row])"
        case stopBarPicker:
            pickerLabel.text = "\(barArr[row])"
        default:
            break
        }
        
        return image
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
        
        switch textField{
        case inputDeviceTextField:
            inputDeviceButton.isSelected = false
        case tempoTextField:
            return
        case startRecordTextField:
            return
        case stopRecordTextField:
            return
        case fileNameTextField:
            
            return
        default:
            return
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField{
        case inputDeviceTextField:
            guard let devieID = textField.text else { return }
            delegate?.didSelectInputDevice(devieID)
            inputDeviceButton.isSelected = true
        case tempoTextField:
            guard let bpmString = tempoTextField.text else { return }
            guard let bpm = Int(bpmString) else { return }
            delegate?.metronomeBPM(bpm: bpm)
        case startRecordTextField:
            break
        case stopRecordTextField:
            break
        case fileNameTextField:
            var fileName = ""
            
            if textField.text != nil {
                guard let recordFileName = fileNameTextField.text else{fatalError()}
                fileName = recordFileName
            }
            
            delegate?.changeRecordFileName(fileName: fileName)
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
        
        guard  datasource?.trackInputStatusIsReadyForRecord() == true else { return }
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            switch self.recordButton.isSelected {
            case false:
                //playAndResumeButtonAction()
                guard let startString = self.startRecordTextField.text else { return }
                guard let stopString = self.stopRecordTextField.text else { return }
                guard let start = Int(startString) else { return }
                guard let stop = Int(stopString) else { return }
                //if not trigger show in notification
                if start > stop {
                    MixerManger.manger.title(with: .recordWarning)
                    MixerManger.manger.subTitle(with: .barWarning)
                    return
                }
                self.delegate?.startRecordAudioPlayer(frombar: start, tobar: stop)
                
            case true:
                //playAndResumeButtonAction()
                self.delegate?.stopRecord()
            }
            
            self.recordButton.isSelected = !self.recordButton.isSelected
            //Switch playing button but not doing playing audio function
            self.playAndResumeButton.isSelected = !self.playAndResumeButton.isSelected
        }
        
    }
}

extension MixerView {
    
    @objc func showDrumVCButtonAction(_ sender:Any) {
        delegate?.showDrumVC()
    }
    
}

extension MixerView: HLDDRedFaderDelegate {
    
    func redFaderValueDidChange(faderValue value: Float, fader: RedFader) {
        delegate?.masterVolumeDidChange(volume: value)
    }
    
    func redFaderIsTouching(bool: Bool, fader: RedFader) {
        
    }
    
}
