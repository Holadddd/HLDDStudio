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
    
    var bufferTime: Double = 2.0
    
    var mic: AKMicrophone!

    var bar = 0
    
    var beat = 0

    let metronome = AKMetronome()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    var metronomeBooster: AKBooster!
    
    var filePlayer = AKPlayer()
    
    var filePlayerTwo = AKPlayer()
    
    var allInputSource: [AKNode] = []
    
//    var mixer: AKMixer!
//
//    //record
//    var mixerForMaster: AKMixer!
//
    var recorder: AKClipRecorder!
    
    var recordFile: AKAudioFile!
    
    var recordFileName: String = ""
    //var recordPlayer: AKPlayer!

    @IBOutlet var mixerView: MixerView!
    
    var firstTrackStatus = TrackInputStatus.noInput
    
    var secondTrackStatus = TrackInputStatus.noInput
    
    var mixerStatus = MixerStatus.stopRecordingAndPlaying
    
    var metronomeStartTime:AVAudioTime = AVAudioTime.now()
    
    var cellTableView: [UITableView]?

    override func viewDidLoad() {
        super.viewDidLoad()
        //try? AudioKit.start()
        // Do any additional setup after loading the view.
        mixerView.delegate = self
        mixerView.datasource = self
        mixerView.trackGridView.delegate = self
        mixerView.trackGridView.dataSource = self
        
        
//        mixer = AKMixer()
//        mixerForMaster = AKMixer()
        //set clean input
        mic = AKMicrophone()
        
        
        //metronomeSetting
        metronome.callback = metronomeCallBack
        metronomeBooster = AKBooster(metronome)
        metronomeBooster.gain = 0
        
        //SetRecorderAndGiveItDefaultFile
        recorder = AKClipRecorder(node: MixerManger.manger.mixer)
        recordFile = try? AKAudioFile()
        
        //SetAnotherMixerForMetronome PassRecorder
        MixerManger.manger.mixerForMaster.connect(input: MixerManger.manger.mixer, bus: 1)
        
        MixerManger.manger.mixerForMaster.connect(input: metronomeBooster, bus: 0)
        AudioKit.output = MixerManger.manger.mixerForMaster
      
        //MakeTwoTrackNode
        for (index, _) in PlugInCreater.shared.plugInOntruck.enumerated() {
            PlugInCreater.shared.plugInOntruck[index].inputNode = AKPlayer()
            MixerManger.manger.mixer.connect(input: PlugInCreater.shared.plugInOntruck[index].inputNode, bus: index + 1)
        } 
        for (index, _) in PlugInCreater.shared.plugInOntruck.enumerated() {
            setTrackNode(track: index + 1)
        }

        try? AudioKit.start()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationTitleChange), name: .mixerNotificationTitleChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationSubTitleChange), name: .mixerNotificationSubTitleChange, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        MixerManger.manger.title(with: .HLDDStudio)
        MixerManger.manger.subTitle(with: .selectInputDevice)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        mixerView.inputDeviceTextField.text = AudioKit.inputDevice?.deviceID
    }

    func setTrackNode(track: Int) {
        try? AudioKit.stop()
        MixerManger.manger.mixer.disconnectInput(bus: track)
        PlugInCreater.shared.resetTrackNode(Track: track)
        PlugInCreater.shared.resetTrack(track: track)
        MixerManger.manger.mixer.connect(input: PlugInCreater.shared.plugInOntruck[track - 1].node, bus: track)
        try? AudioKit.start()
    }
    
    @objc func notificationTitleChange(_ notification: Notification){
        DispatchQueue.main.async {
            MixerManger.manger.title(with: .HLDDStudio)
            self.mixerView.notificationTitleLabel.text = MixerManger.manger.titleContent
        }
    }

    @objc func notificationSubTitleChange(_ notification: Notification){
        DispatchQueue.main.async {
            MixerManger.manger.title(with: .HLDDStudio)
            self.mixerView.notificationSubTitleLabel.text = MixerManger.manger.subTitleContent
        }
    }
    
}

extension ViewController: MixerDelegate {
    
    func showDrumVC() {
        
        var vc: UIViewController = UIViewController()
        if #available(iOS 13.0, *) {
            vc = UIStoryboard.drumMachine.instantiateViewController(identifier: String(describing: DrumMachineViewController.self))
        } else {
            // Fallback on earlier versions
            vc = UIStoryboard.drumMachine.instantiateViewController(withIdentifier: String(describing: DrumMachineViewController.self) )
        }
        
        guard let drumVC = vc as? DrumMachineViewController else { fatalError() }
        drumVC.modalPresentationStyle = .fullScreen
        present(drumVC, animated: true) {
            print("save parameter")
        }
        
    }
    
    func didSelectInputDevice(_ deviceID: DeviceID) {
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        for device in inputDeviceArr {
            if device.deviceID == deviceID {
                let result = Result{try AudioKit.setInputDevice(device)}
                switch result {
                case .success():
                    print("Set \(device.deviceID) As InputDevice")
                    MixerManger.manger.title(with: .HLDDStudio)
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
        
        if mixerStatus  == .prepareToRecordAndPlay {
            metronomeStartTime = AVAudioTime.now()
            mixerStatus = .recordingAndPlaying
            print("metronomeFirstCallBackTime:\(DispatchTime.now())")
            print("1")
            semaphore.signal()
        }
        print("metronomeTime:\(DispatchTime.now())")
        DispatchQueue.main.async {
            self.mixerView.barLabel.text = "\(self.bar) | \((self.beat % 4) + 1 )"
            self.beat += 1
            self.bar = Int(self.beat/4)
        }
        
    }
    
    func metronomeSwitch(isOn: Bool) {
        
        switch isOn {
        case true:
        
            metronomeBooster.gain = 1
            
        case false:
            
            metronomeBooster.gain = 0
            
        }
        
    }
    
    func metronomeBPM(bpm: Int) {
        metronome.tempo = Double(bpm)
    }
    
    func stopAudioPlayer() {
        print("StopPlayer")
        metronome.restart()
        metronome.stop()
        mixerStatus = .stopRecordingAndPlaying
        DispatchQueue.main.async {
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
        }
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            
            filePlayer.stop()
            filePlayer.preroll()
            print("firstTrackPlayerSelectFile")
        case .noInput:
            print("firstTrackNoInput")
        }
        
        switch secondTrackStatus {
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
           
            
            filePlayerTwo.stop()
            filePlayerTwo.preroll()
            print("secondTrackPlaySelectFile")
        case .noInput:
            print("secondTrackNoInput")
        }
    }
    
    func playingAudioPlayer() {
        
        mixerStatus = .prepareToRecordAndPlay
        print("playingPlayer")
        print(metronome.tempo)
        filePlayer.prepare()
        filePlayerTwo.prepare()
        
        DispatchQueue.main.async {
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "1 | 1"
        }
        
        self.metronome.start()
        semaphore.wait()
       
        let oneBarTime = (60 / metronome.tempo) * 4
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            if filePlayer.isPaused {
                filePlayer.resume()
            } else {
                
                filePlayer.play(at:metronomeStartTime + oneBarTime )
                
            }
        
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
                filePlayerTwo.play(at:metronomeStartTime + oneBarTime )
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
        
        mixerStatus = .prepareToRecordAndPlay
        filePlayer.prepare()
        filePlayer.preroll()
        filePlayerTwo.prepare()
        filePlayerTwo.preroll()
        
        print(metronome.tempo)
        let oneBarTime = (60 / metronome.tempo) * 4
        let durationTime = (stop - start + 1) * oneBarTime
        //needStartRecorder
        recorder.start()
        
        DispatchQueue.main.async {
            print("start")
            self.bar = 0
            self.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
            
        }
        
        self.metronome.start()
        semaphore.wait()
        
        let recordMetronomeStartTime = AVAudioTime.now()
        let processTime = AVAudioTime.init(hostTime: AVAudioTime.now().hostTime - recordMetronomeStartTime.hostTime)
        
        let recorderStartTimeSec = oneBarTime * start - processTime.toSeconds(hostTime: processTime.hostTime)
        
        DispatchQueue.main.async {
            try? self.recorder.recordClip(time:  recorderStartTimeSec, duration: Double(durationTime).rounded(), tap: nil) {[weak self] result in
                guard let strongSelf = self  else{ fatalError() }
                switch result {
                case .clip(let clip):
                    strongSelf.metronome.stop()
                    
                    do {
                        
                        let urlInDocs = FileManager.docs.appendingPathComponent("\(strongSelf.recordFileName)(\(Int(strongSelf.metronome.tempo)))").appendingPathExtension(clip.url.pathExtension)
                        
                        try FileManager.default.moveItem(at: clip.url, to: urlInDocs)
                        strongSelf.recordFile = try AKAudioFile(forReading: urlInDocs)
                        strongSelf.mixerStatus = .stopRecordingAndPlaying
                    } catch {
                        print(error)
                    }
                    
                    strongSelf.recorder.stop()
                    strongSelf.mixerView.recordButtonAction()
                    
                case .error(let error):
                    AKLog(error)
                    return
                }
            }
            //        play audio
            if self.firstTrackStatus == .audioFile {
                self.filePlayer.play(at: self.metronomeStartTime + oneBarTime)
            }
            if self.secondTrackStatus == .audioFile {
                self.filePlayerTwo.play(at: self.metronomeStartTime + oneBarTime)
            }
        }
        MixerManger.manger.title(with: .recording)
        MixerManger.manger.subTitleContent = "Device Is Recording From Bar \(start) to \(stop). Duration: \(String(format: "%.2f", durationTime)) seconds."
        
    }
    
    func stopRecord() {
        
        try? AudioKit.stop()
        MixerManger.manger.title(with: .finishingRecording)
        MixerManger.manger.subTitleContent = "File: \(recordFileName) is saved."
        mixerView.fileNameTextField.text = nil
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
        MixerManger.manger.mixerForMaster.volume = Double(volume)
        print(MixerManger.manger.mixerForMaster.volume)
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
        
    }
    
}

extension ViewController: GridViewDelegate {
    
}

extension ViewController: GridViewDataSource {
    
    func numberOfColumns(in gridView: GridView) -> Int {
        return PlugInCreater.shared.plugInOntruck.count
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
        print("reloadGridViewHiegh")
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
        case .guitarProcessor(let guitarProcessor):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                guitarProcessor.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                guitarProcessor.start()
            }
        case .delay(let delay):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                delay.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                delay.start()
            }
        case .chorus(let chorus):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                chorus.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                chorus.start()
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
    
    func resetTrackOn(Track track: Int) {
        setTrackNode(track: track)
    }
    
}

extension ViewController: FaderGridViewCellDelegate {
    func pannerValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busPanner.pan = value
    }
    
    func lowEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busLowEQ.gain = value
    }
    
    func midEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busMidEQ.gain = value
    }
    
    func highEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busHighEQ.gain = value
    }
    
    func volumeChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busBooster.gain = value
    }
}

extension ViewController: IOGridViewCellDelegate {
    
    func didSelectInputSource(inputSource: String, cell: IOGridViewCell) {
        
        switch cell.indexPath.column {
            
        case 0:  //Bus1
            
            let currentDevice = currentInputDevice()
            let fileInDeviceArr = getFileFromDevice()
            if inputSource == currentDevice {
                
                try? AudioKit.stop()
                
                print("InputDeviceAsInputMixerBus1Source:\(currentDevice)")
                MixerManger.manger.title(with: .HLDDStudio)
                MixerManger.manger.subTitleContent = "Selected \(currentDevice) As Trackone Input Source."
                
                PlugInCreater.shared.plugInOntruck[0].inputNode = mic

                setTrackNode(track: 1)
                
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

                            filePlayer = AKPlayer(audioFile: file)
                            PlugInCreater.shared.plugInOntruck[0].inputNode = filePlayer
                            
                            //need adjust for audioFile into plugIn
                            PlugInCreater.shared.resetTrackNode(Track: 1)
                            setTrackNode(track: 1)
                            
                            print("FirstTrackFileSelectIn:\(fileName)")
                            MixerManger.manger.title(with: .HLDDStudio)
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
                try? AudioKit.stop()
                
                print("InputDeviceAsInputMixerBus2Source:\(currentDevice)")
                MixerManger.manger.title(with: .HLDDStudio)
                MixerManger.manger.subTitleContent = "Selected \(currentDevice) As Tracktwo Input Source."
                PlugInCreater.shared.plugInOntruck[1].inputNode = mic
                //need adjust for audioFile into plugIn
                PlugInCreater.shared.resetTrackNode(Track: 2)
                setTrackNode(track: 2)
                try? AudioKit.start()
                //switch the track status
                secondTrackStatus = .lineIn
                
                return
                
            } else {
                for fileName in fileInDeviceArr {
                    
                    if fileName == inputSource {
                        //set the file as mixer input
                        try? AudioKit.stop()
                        let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                        
                        switch result {
                        case .success(let file):
                            filePlayerTwo = AKPlayer(audioFile: file)
                            PlugInCreater.shared.plugInOntruck[1].inputNode = filePlayerTwo
                            
                            //need adjust for audioFile into plugIn
                            PlugInCreater.shared.resetTrackNode(Track: 2)
                            setTrackNode(track: 2)
                            
                            print("FirstTrackFileSelectIn:\(fileName)")
                            MixerManger.manger.title(with: .HLDDStudio)
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
        case .guitarProcessor(let guitarProcessor):
            plugInProvide(row: row, column: column, plugIn: .guitarProcessor(guitarProcessor))
        case .delay(let delay):
            plugInProvide(row: row, column: column, plugIn: .delay(delay))
        case .chorus(let chorus):
            plugInProvide(row: row, column: column, plugIn: .chorus(chorus))
        }
        
    }
    
    func noInputSource(cell: IOGridViewCell) {
        
        try? AudioKit.stop()
        let indexPath = cell.indexPath
        switch indexPath.column {
        case 0:
            
            firstTrackStatus = .noInput
            MixerManger.manger.mixer.disconnectInput(bus: 1)
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
            MixerManger.manger.mixer.disconnectInput(bus: column + 1)
            PlugInCreater.shared.plugInOntruck[column].plugInArr.append(HLDDStudioPlugIn(plugIn: .reverb(AKReverb( PlugInCreater.shared.plugInOntruck[column].node)), bypass: false, sequence: row))
        
        case .guitarProcessor:
            MixerManger.manger.mixer.disconnectInput(bus: column + 1)
            PlugInCreater.shared.plugInOntruck[column].plugInArr.append(HLDDStudioPlugIn(plugIn: .guitarProcessor(AKRhinoGuitarProcessor(PlugInCreater.shared.plugInOntruck[column].node)), bypass: false, sequence: row))
        case .delay:
            MixerManger.manger.mixer.disconnectInput(bus: column + 1)
            PlugInCreater.shared.plugInOntruck[column].plugInArr.append(HLDDStudioPlugIn(plugIn: .delay(AKDelay(PlugInCreater.shared.plugInOntruck[column].node)), bypass: false, sequence: row))
        case .chorus:
            MixerManger.manger.mixer.disconnectInput(bus: column + 1)
            PlugInCreater.shared.plugInOntruck[column].plugInArr.append(HLDDStudioPlugIn(plugIn: .chorus(AKChorus(PlugInCreater.shared.plugInOntruck[column].node)), bypass: false, sequence: row))
        }
        
        PlugInCreater.shared.resetTrackNode(Track: column + 1)
        setTrackNode(track: column + 1)
    }
    
}

