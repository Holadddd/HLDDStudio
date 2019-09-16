//
//  ViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import Foundation
import G3GridView
import AVKit
import AudioKit



class ViewController: UIViewController {
    
    var bufferTime = 0.25
    
    var mic: AKMicrophone!
    
    var bus1Panner: AKPanner!
    
    var bus1LowEQ: AKEqualizerFilter!
    
    var bus1MidEQ: AKEqualizerFilter!
    
    var bus1HighEQ: AKEqualizerFilter!
    
    var bus1Booster: AKBooster!
    
    var bus2Panner: AKPanner!
    
    var bus2LowEQ: AKEqualizerFilter!
    
    var bus2MidEQ: AKEqualizerFilter!
    
    var bus2HighEQ: AKEqualizerFilter!
    
    var bus2Booster: AKBooster!
    
    var bar = 0
    
    var beat = 0

    var metronome = AKMetronome()
    
    var metronomeBooster: AKBooster!
    
    var filePlayer = AKPlayer()
    
    var filePlayerTwo = AKPlayer()
    
    var allInputSource: [AKNode] = []
    
    var mixer = AKMixer()
    
    //record
    var mixerForMaster = AKMixer()
    
    var recorderTwo: AKClipRecorder!
    
    var recordFile: AKAudioFile!
    
    var recordFileName: String = "HLDD"
    //var recordPlayer: AKPlayer!

    @IBOutlet var mixerView: MixerView!
    
    var firstTrackStatus = TrackInputStatus.noInput
    
    var secondTrackStatus = TrackInputStatus.noInput
    
    var recorderStatus = RecorderStatus.stopRecording
    
    //var recordMetronomeStartTime:AVAudioTime = AVAudioTime.now()
    
    var cellTableView: [UITableView]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mic = AKMicrophone()
        PlugInCreater.shared.plugInOntruck[0].node = mic
        
        mixer = AKMixer()
        
        //metronome.tempo = Double(40)
        metronome.callback = metronomeCallBack
        metronomeBooster = AKBooster(metronome)
        metronomeBooster.gain = 0
        
        
        mixerView.delegate = self
        mixerView.datasource = self
        
        mixerView.trackGridView.delegate = self
        mixerView.trackGridView.dataSource = self
        //set clean input
        PlugInCreater.shared.plugInOntruck[1].node = filePlayerTwo
        
        
        //set recorder
        
//        recorder = try? AKNodeRecorder(node: mixer)
        
        recorderTwo = AKClipRecorder(node: mixer)
        
        recordFile = try? AKAudioFile()
        
        setTrackNode(track: 1, node: filePlayer)
        setTrackNode(track: 2, node: filePlayerTwo)
        //!!!!!!!
        try? AudioKit.start()
        
        mixerForMaster.connect(input: mixer, bus: 1)
        mixerForMaster.connect(input: metronomeBooster, bus: 0)
        AudioKit.output = mixerForMaster
        
//
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationTitleChange), name: .mixerNotificationTitleChange, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationSubTitleChange), name: .mixerNotificationSubTitleChange, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MixerManger.manger.title(with: .HLDDStudio)
        MixerManger.manger.subTitle(with: .selectInputDevice)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    
        mixerView.inputDeviceTextField.text = AudioKit.inputDevice?.deviceID
    
    }
    
    func setTrackNode(track: Int,node: AKNode) {
        switch track {
        case 1:
            try? AudioKit.stop()
            mixer.disconnectInput(bus: track)
            bus1Panner = AKPanner(node, pan: 0)
            bus1LowEQ = AKEqualizerFilter(bus1Panner, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
            bus1MidEQ = AKEqualizerFilter(bus1LowEQ, centerFrequency: 2_000, bandwidth: 2_282, gain: 1.0)
            bus1HighEQ = AKEqualizerFilter(bus1MidEQ, centerFrequency: 12_000, bandwidth: 8_112, gain: 1.0)
            bus1Booster = AKBooster(bus1HighEQ, gain: 1)
            //會覆寫
            mixer.connect(input: bus1Booster, bus: track)
            try? AudioKit.start()
        case 2:
            try? AudioKit.stop()
            mixer.disconnectInput(bus: track)
            bus2Panner = AKPanner(node, pan: 0)
            bus2LowEQ = AKEqualizerFilter(bus2Panner, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
            bus2MidEQ = AKEqualizerFilter(bus2LowEQ, centerFrequency: 2_000, bandwidth: 2_282, gain: 1.0)
            bus2HighEQ = AKEqualizerFilter(bus2MidEQ, centerFrequency: 12_000, bandwidth: 8_112, gain: 1.0)
            bus2Booster = AKBooster(bus2HighEQ, gain: 1)
            mixer.connect(input: bus2Booster, bus: track)
            try? AudioKit.start()
        default:
            print("no such bus")
        }
        
    }
    
    @objc func notificationTitleChange(_ notification: Notification){
        DispatchQueue.main.async {
            self.mixerView.notificationTitleLabel.text = MixerManger.manger.titleContent
        }
    }

    @objc func notificationSubTitleChange(_ notification: Notification){
        DispatchQueue.main.async {
            self.mixerView.notificationSubTitleLabel.text = MixerManger.manger.subTitleContent
        }
    }
    
}

extension ViewController: MixerDelegate {
    
    func didSelectInputDevice(_ deviceID: DeviceID) {
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        for device in inputDeviceArr {
            if device.deviceID == deviceID {
                let result = Result{try AudioKit.setInputDevice(device)}
                switch result {
                case .success():
                    print("Set \(device.deviceID) As InputDevice")
                    MixerManger.manger.subTitleContent = "Selected \(device.deviceID) As Input Device"
                    try? AudioKit.setInputDevice(device)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func metronomeCallBack() {
        print("\(self.bar) | \((self.beat % 4) + 1 )")
        
        if recorderStatus == .prepareToRecord {
            print("recorddddddddd")
            recorderStatus = .recording
        }
        
        DispatchQueue.main.async {
            self.mixerView.barLabel.text = "\(self.bar) | \((self.beat % 4) + 1 )"
            self.beat += 1
            self.bar = Int(self.beat/4)
        }
        
    }
    
    func metronomeSwitch(isOn: Bool) {
        
        switch isOn {
        case true:
            
            try? AudioKit.stop()
            metronomeBooster.gain = 1
            try? AudioKit.start()
//            MixerManger.manger.subTitle(with: .metronomeIsOn)
        case false:
            
            try? AudioKit.stop()
            metronomeBooster.gain = 0
            try? AudioKit.start()
//            MixerManger.manger.subTitle(with: .metronomeIsOff)
        }
        
    }
    
    func metronomeBPM(bpm: Int) {
        metronome.tempo = Double(bpm)
    }
    
    func stopAudioPlayer() {
        print("StopPlayer")
        metronome.restart()
        metronome.stop()
        
        
        DispatchQueue.main.async {
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
        }
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            //Bug If playIsNotPlaying this wont back to begining
            filePlayer.start(at: AVAudioTime(hostTime: 0))
            filePlayer.stop()
            print("firstTrackPlayerSelectFile")
        case .noInput:
            print("firstTrackNoInput")
        }
        
        switch secondTrackStatus {
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            //Bug If playIsNotPlaying this wont back to begining
            filePlayerTwo.start(at: AVAudioTime(hostTime: 0))
            filePlayerTwo.stop()
            print("secondTrackPlaySelectFile")
        case .noInput:
            print("secondTrackNoInput")
        }
    }
    
    func playingAudioPlayer() {
        print("playingPlayer")
        print(metronome.tempo)
        
        metronome.restart()
        
        
        //for each player play
        let start = AVAudioTime.now()
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            if filePlayer.isPaused {
                filePlayer.resume()
            } else {
                filePlayer.play(at:start + bufferTime )
            }
        
            print("firstTrackPlaySelectFile")
        case .noInput:
            print("firstTrackNoInput")
        }
        
        switch secondTrackStatus {
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            if filePlayerTwo.isPaused {
                filePlayerTwo.resume()
            } else {
                filePlayerTwo.play(at:start + bufferTime )
            }
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            print("secondTrackNoInput")
        }
    }
    
    func pauseAudioPlayer() {
        metronome.stop()
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            filePlayer.pause()
            
            print("firstTrackPlaySelectFile")
        case .noInput:
            print("firstTrackNoInput")
        }
        
        switch secondTrackStatus {
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            filePlayerTwo.pause()
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            print("secondTrackNoInput")
        }
    }
    
    func resumeAudioPlayer() {
        print("PausePlayer")
        metronome.start()
        //for each player play
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            filePlayer.pause()
            print("firstTrackPlaySelectFile")
        case .noInput:
            print("firstTrackNoInput")
        }
        
        switch secondTrackStatus {
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            filePlayerTwo.pause()
            print("secondTrackPlaySelectFile")
        case .noInput:
            print("secondTrackNoInput")
        }
    }
    
    func startRecordAudioPlayer(frombar start: Int, tobar stop: Int) {
        
        recorderStatus = .prepareToRecord
        
        print(metronome.tempo)
        let oneBarTime = (60 / metronome.tempo) * 4
        let durationTime = (stop - start + 1) * oneBarTime
        //needStartRecorder
        recorderTwo.start()
        
        DispatchQueue.main.async {
            print("start")
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
            self.metronome.start()
        }
        let recordMetronomeStartTime = AVAudioTime.now()
        let processTime = AVAudioTime.init(hostTime: AVAudioTime.now().hostTime - recordMetronomeStartTime.hostTime)
        
        let recorderStartTimeSec = oneBarTime * start - processTime.toSeconds(hostTime: processTime.hostTime)
        
//        print("oneBarTime:\(oneBarTime)")
//        print("durationTime:\(durationTime)")
//        print("startBarTime:\(startBarTime)")
//        print("audioStartTime:\(recordMetronomeStartTime + oneBarTime)")
//        print("AVAudioTimeNowFirst:\(AVAudioTime.now())")
//        print("AVAudioTimeNowSecond:\(AVAudioTime.now())")
//        print("AVAudioTimeNowThird:\(AVAudioTime.now())")
//        print("processTimeSec\(processTime)")
        print("recorderStartTimeSec:\(recorderStartTimeSec)")
        
        DispatchQueue.main.async {
            try? self.recorderTwo.recordClip(time:  recorderStartTimeSec, duration: Double(durationTime).rounded(), tap: nil) {[weak self] result in
                guard let strongSelf = self  else{ fatalError() }
                switch result {
                case .clip(let clip):
                    strongSelf.metronome.stop()
                    
//                    print("recordFile:\(strongSelf.recordFile)")
//                    print("startTime:\(clip.startTime)")
//                    print("duration:\(clip.duration)")
//                    print("url:\(clip.url)")
                    do {
                        
                        let urlInDocs = FileManager.docs.appendingPathComponent(strongSelf.recordFileName).appendingPathExtension(clip.url.pathExtension)
                        
                        try FileManager.default.moveItem(at: clip.url, to: urlInDocs)
                        strongSelf.recordFile = try AKAudioFile(forReading: urlInDocs)
                        strongSelf.recorderStatus = .stopRecording
                    } catch {
                        print(error)
                    }
                    
                    strongSelf.recorderTwo.stop()
                    strongSelf.mixerView.recordButtonAction()
                    
                case .error(let error):
                    AKLog(error)
                    return
                }
            }
            //        play audio
            if self.firstTrackStatus == .audioFile {
                self.filePlayer.play(at: recordMetronomeStartTime + oneBarTime)
            }
            if self.secondTrackStatus == .audioFile {
                self.filePlayerTwo.play(at: recordMetronomeStartTime + oneBarTime)
            }
        }
//        MixerManger.manger.title(with: .recording)
//        MixerManger.manger.subTitleContent = "Device Is Recording From Bar \(start) to \(stop). Duration: \(String(format: "%.2f", durationTime)) seconds."
        
    }
    
    func stopRecord() {
        
        try? AudioKit.stop()
        MixerManger.manger.title(with: .finishingRecording)
        MixerManger.manger.subTitleContent = "File: \(recordFileName) is saved"
        mixerView.fileNameTextField.placeholder = "FileName"
        
        DispatchQueue.main.async {
            print("metronomReset")
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
            self.metronome.restart()
            self.metronome.stop()
        }
        try? AudioKit.start()
        
    }
    
    func changeRecordFileName(fileName: String) {
        recordFileName = fileName
    }
    
    func masterVolumeDidChange(volume: Float) {
        mixerForMaster.volume = Double(volume)
        print(mixerForMaster.volume)
    }
}

extension ViewController: MixerDatasource {
    
    func currentInputDevice() -> DeviceID {
        
        guard let inputDeviceID = AudioKit.inputDevice?.deviceID else {return "NO INPUT"}
        
        return inputDeviceID
    }
    
    
    func nameOfInputDevice() -> [String] {
        var inputDevieNameArr: [DeviceID] = []
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        for inputDevice in inputDeviceArr {
            inputDevieNameArr.append(inputDevice.deviceID)
        }
        
        return inputDevieNameArr
    }
    
    func trackInputStatusIsReadyForRecord() -> Bool {
        
        if firstTrackStatus != .noInput || secondTrackStatus != .noInput {
            return true
        } else {
            return false
        }
        
    }
    
}
extension ViewController: GridViewStopScrollingWhileUIKitIsTouchingDelegate {
    
    func isInteractWithUser(bool: Bool) {
        //mixerView.trackGridView.isPagingEnabled = bool
    }
    
}

extension ViewController: GridViewDelegate {
    
}

extension ViewController: GridViewDataSource {
    
    func numberOfColumns(in gridView: GridView) -> Int {
        return 2
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 3
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        
        switch indexPath.row {
        case 0:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "IOGridViewCell", for: indexPath) as? IOGridViewCell else { fatalError() }
            cell.busLabel.text = PlugInCreater.shared.plugInOntruck[indexPath.column].name
            cell.delegate = self
            cell.datasource = self
            return cell
        case 1:
            //need set tableView
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "PlugInGridViewCell", for: indexPath) as? PlugInGridViewCell else { fatalError() }
            
            cell.delegate = self
            
            return cell
        case 2:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "FaderGridViewCell", for: indexPath) as? FaderGridViewCell else { fatalError() }
            cell.touchingDelegate = self
            cell.delegate = self
            return cell
        default:
            return GridViewCell()
        }
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 50
        case 1:
            return gridView.bounds.height - 50  - (mixerView.bounds.height-50)/2
        case 2:
            return (mixerView.bounds.height-50)/2
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        return mixerView.bounds.width * 2 / 3
    }
    
}

extension ViewController: PlugInGridViewCellDelegate {

    func bypassPlugin(atRow row: Int, Column column: Int) {
        
        try? AudioKit.stop()
        
        switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].plugIn {
        case .reverb(let reverb):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                reverb.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                reverb.start()
            }
        }
        try? AudioKit.start()
        
    }
    
    
    func perforPlugInVC(forTrack column: Int) {
  
        PlugInCreater.shared.showingTrackOnPlugInVC = column
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "PlugInTableViewSegue", sender: nil)
        }

    }
    
}

extension ViewController: FaderGridViewCellDelegate {
    func pannerValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        switch cell.indexPath.column {
        case 0:
            bus1Panner.pan = value
            PlugInCreater.shared.plugInOntruck[0].pan = value
        case 1:
            bus2Panner.pan = value
            PlugInCreater.shared.plugInOntruck[1].pan = value
        default:
            print("No Such Column")
        }
    }
    
    func lowEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        switch cell.indexPath.column {
        case 0:
            bus1LowEQ.gain = value
            PlugInCreater.shared.plugInOntruck[0].low = value
        case 1:
            bus2LowEQ.gain = value
            PlugInCreater.shared.plugInOntruck[1].low = value
        default:
            print("No Such Column")
        }
    }
    
    func midEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        switch cell.indexPath.column {
        case 0:
            bus1MidEQ.gain = value
            PlugInCreater.shared.plugInOntruck[0].mid = value
        case 1:
            bus2MidEQ.gain = value
            PlugInCreater.shared.plugInOntruck[1].mid = value
        default:
            print("No Such Column")
        }
    }
    
    func highEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        switch cell.indexPath.column {
        case 0:
            bus1HighEQ.gain = value
            PlugInCreater.shared.plugInOntruck[0].high = value
        case 1:
            bus2HighEQ.gain = value
            PlugInCreater.shared.plugInOntruck[1].high = value
        default:
            print("No Such Column")
        }
    }
    
    func volumeChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        switch cell.indexPath.column {
        case 0:
            bus1Booster.gain = value
            PlugInCreater.shared.plugInOntruck[0].volume = value
        case 1:
            bus2Booster.gain = value
            PlugInCreater.shared.plugInOntruck[1].volume = value
        default:
            print("No Such Column")
        }
    }
    
    
    
}

extension ViewController: IOGridViewCellDelegate {
    
    func didSelectInputSource(inputSource: String, cell: IOGridViewCell) {
        
        switch cell.indexPath.column {
            
        case 0:  //Bus1
            print("BUS1")
            let currentDevice = currentInputDevice()
            let fileInDeviceArr = getFileFromDevice()
            if inputSource == currentDevice {
                
                try? AudioKit.stop()
                //can be remove
//                mixer.disconnectInput(bus: 1)
                print("InputDeviceAsInputMixerBus1Source:\(currentDevice)")
                MixerManger.manger.subTitleContent = "Selected \(currentDevice) As Trackone Input Source."
                setTrackNode(track: 1, node: PlugInCreater.shared.plugInOntruck[0].node)
                try? AudioKit.start()
                //switch the track status
                firstTrackStatus = .lineIn
                
                
                return
                
            } else {
                for fileName in fileInDeviceArr {
                    
                    if fileName == inputSource {
                        try? AudioKit.stop()
                        //set the file as mixer input
                        let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                        
                        switch result {
                        case .success(let file):
//                            mixer.disconnectInput(bus: 1)
                            filePlayer = AKPlayer(audioFile: file)
//                            PlugInCreater.shared.plugInOntruck[0].node = filePlayer
//                            PlugInCreater.shared.resetTrackNode(column: 0)
                            setTrackNode(track: 1, node: filePlayer)
                            
                            
                            print("FirstTrackFileSelectIn:\(fileName)")
                            MixerManger.manger.subTitleContent = "Selected \(fileName) As Trackone Input File."
                            //switch the track status
                            firstTrackStatus = .audioFile
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                        try? AudioKit.start()
                        return
                    }
                }
            }
        case 1:  //Bus2
            print("BUS2")
            let currentDevice = currentInputDevice()
            let fileInDeviceArr = getFileFromDevice()
            if inputSource == currentDevice {
                print("TrackTwo need fix")
//                try? AudioKit.stop()
//                //can be remove
//                mixer.disconnectInput(bus: 1)
//                print("InputDeviceAsInputMixerBus1Source:\(currentDevice)")
//                //take the mic node after plugin
//
//                guard let bus1Node = bus1Node else { fatalError() }
//                //connect with mixer to do callBack before playing
//                //使用 mixer bus 1 as input
//
//                mixer.connect(input: bus1Node, bus: 1)
//                try? AudioKit.start()
//                //switch the track status
//                secondTrackStatus = .lineIn
//                return
                
            } else {
                for fileName in fileInDeviceArr {
                    
                    if fileName == inputSource {
                        //set the file as mixer input
                        try? AudioKit.stop()
                        let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                        
                        switch result {
                        case .success(let file):
                            filePlayerTwo = AKPlayer(audioFile: file)
                            
                            mixer.disconnectInput(bus: 2)
                            mixer.connect(input: filePlayerTwo, bus: 2)
                            
                            print("SecondTrackFileSelectIn:\(fileName)")
                            MixerManger.manger.subTitleContent = "Selected \(fileName) As Tracktwo Input File."
                            //switch the track status
                            secondTrackStatus = .audioFile
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                        
                        try? AudioKit.start()
                        return
                    }
                }
            }
            
        default:
            print("ERROR OF SETTING INPUT")
            MixerManger.manger.subTitleContent = "ERROR OF SETTING INPUT"
        }
        // do error handle
        print(inputSource)
        print("dont use")
    }
    
    func addPlugIn(with plugIn: PlugIn, row: Int, column: Int, cell: IOGridViewCell) {
        
        switch plugIn {
        case .reverb(let reverb):
            plugInProvide(row: row, column: column, plugIn: .reverb(reverb))
        }
        
    }
    
    func noInputSource(cell: IOGridViewCell) {
        
        try? AudioKit.stop()
        let indexPath = cell.indexPath
        switch indexPath.column {
        case 0:
            
            firstTrackStatus = .noInput
            mixer.disconnectInput(bus: 1)
            MixerManger.manger.subTitleContent = "Disconnect Trackone."
        case 1:
            secondTrackStatus = .noInput
            MixerManger.manger.subTitleContent = "Disconnect Tracktwo."
            print("Need Disconnect bus2 track")
        default:
            print("No Need For Disconnect")
        }
        print("HandelNoInputSource")
        try? AudioKit.start()
    }

}

extension ViewController: IOGridViewCellDatasource {
    
    func inputSource() -> [String] {
        var fileInDeviceNameArr = getFileFromDevice()
        guard let currentInputDevice = AudioKit.inputDevice?.deviceID else { fatalError() }
        fileInDeviceNameArr.insert(currentInputDevice, at: 0)
        fileInDeviceNameArr.insert("No Input", at: 0)
        return fileInDeviceNameArr
    }
    
    func getFileFromDevice() -> [String] {
        let path = NSHomeDirectory() + "/Documents"
        
        var fileNameArr: [String] = []
        let result = Result{try FileManager.default.contentsOfDirectory(atPath: path)}
        switch result {
        case .success(let fileArr):
            print("FILEARRAYINDEVICE: \(fileArr)")
            fileNameArr = fileArr
        case .failure(let error):
            print(error)
        }
        return fileNameArr
    }
}

extension ViewController {
    
    //Here
    func plugInProvide(row: Int, column: Int, plugIn: PlugIn) {
        try? AudioKit.stop()
        
        switch plugIn {
        case .reverb:
            mixer.disconnectInput(bus: column + 1)
            PlugInCreater.shared.plugInOntruck[column].plugInArr.append(HLDDStudioPlugIn(plugIn: .reverb(AKReverb( PlugInCreater.shared.plugInOntruck[column].node)), bypass: false, sequence: row))
        
        }
        
        PlugInCreater.shared.resetTrackNode(column: column)
        setTrackNode(track: column + 1, node: PlugInCreater.shared.plugInOntruck[column].node)
        try? AudioKit.start()
    }
    
}

