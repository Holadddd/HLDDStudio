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
    //inputAndFile
    var plugInArr:[HLDDStudioPlugIn] = []
    
    var mic: AKMicrophone!
    
    var bus1Node: AKNode?
    
    var bar = 0
    var beat = 0

    let metronome = AKMetronome()
    
    var metronomeBooster: AKBooster!
    
    var filePlayer = AKPlayer()
    
    var allInputSource: [AKNode] = []
    
    var mixer: AKMixer!
    
    //record
    var recorder: AKNodeRecorder!
    
    var tape: AKAudioFile!
    
    var recordPlayer: AKPlayer!

    @IBOutlet var mixerView: MixerView!
    
    var firstTrackStatus = TrackInputStatus.lineIn
    
    weak var cellTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mic = AKMicrophone()
        mixer = AKMixer()
        metronome.callback = metronomeCallBack
        metronomeBooster = AKBooster(metronome)
        metronomeBooster.gain = 0
        mixer.connect(input: metronomeBooster, bus: 0)
        
        mixerView.delegate = self
        mixerView.datasource = self
        
        mixerView.trackGridView.delegate = self
        mixerView.trackGridView.dataSource = self
        //set clean input
        bus1Node = mic
        
        //set recorder
        recorder = try? AKNodeRecorder(node: bus1Node)
        if let file = recorder.audioFile {
            recordPlayer = AKPlayer(audioFile: file)
        }
        recordPlayer.isLooping = true
        mixer.connect(input: recordPlayer, bus: 2)
        
        AudioKit.output = mixer
        try? AudioKit.start()
        //plugInProvide()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        mixerView.inputDeviceTextField.text = AudioKit.inputDevice?.deviceID
    
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
                    //??????why
                    try? AudioKit.setInputDevice(device)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    func metronomeCallBack() {
        print("\(self.bar) | \((self.beat % 4) + 1 )")
        
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
            
        case false:
            
            try? AudioKit.stop()
            metronomeBooster.gain = 0
            try? AudioKit.start()
            
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
            
            print("lineIN")
        case .audioFile :
            //Bug If playIsNotPlaying this wont back to begining
            filePlayer.start(at: AVAudioTime(hostTime: 0))
            filePlayer.stop()
            print("PlaySelectFile")
        }
    }
    
    func playingAudioPlayer() {
        print("playingPlayer")
        metronome.start()
        //for each player play
        let start = AVAudioTime.now()
        switch firstTrackStatus {
        case .lineIn:
            
            print("lineIN")
        case .audioFile :
            
            if filePlayer.isPaused {
                filePlayer.resume()
            } else {
                filePlayer.play(at:start + bufferTime )
            }
        
            print("PlaySelectFile")
        }
    }
    
    func pauseAudioPlayer() {
        metronome.stop()
        switch firstTrackStatus {
        case .lineIn:
            
            print("lineIN")
        case .audioFile :
            
            filePlayer.pause()
            
            print("PlaySelectFile")
        }
    }
    
    func resumeAudioPlayer() {
        print("PausePlayer")
        metronome.start()
        //for each player play
        
        switch firstTrackStatus {
        case .lineIn:
            
            print("lineIN")
        case .audioFile :
            
            filePlayer.pause()
            print("PlaySelectFile")
        }
    }
    
    func startRecordAudioPlayer(frombar start: Int, tobar stop: Int) {
        
        let audioStartTime = AVAudioTime.now() + bufferTime
        let disPatchStartTime = DispatchTime.now() + bufferTime
        let oneBarTime = ((60 / metronome.tempo) * 4)
        print(metronome.tempo)
        //need adjust
        let stardRecordTime = DispatchTime.now() + 0.15 + (oneBarTime * start)
        
        DispatchQueue.main.asyncAfter(deadline: disPatchStartTime ) {
            
            DispatchQueue.main.async {
                self.bar = 0
                self.beat = 0
                self.mixerView.barLabel.text = "0 | 1"
            }
            self.metronome.restart()
            
            
            self.recordPlayer.play(at: audioStartTime)
            
            try? self.recorder.reset()
            self.recorder.durationToRecord = ((stop - start + 1) * oneBarTime)
            
            DispatchQueue.main.asyncAfter(deadline: stardRecordTime) {
                
                let result = Result{try self.recorder.record()}
                
                switch result {
                case .success():
                    print("StartRecord")
                case .failure(let error):
                    print("FailToRecord:\(error)")
                }
                
            }
        
        }
    
    }
    
    func stopRecord() {
        recorder.stop()
        recordPlayer.stop()
        metronome.stop()
        print("stoprecord")
        
        tape = recorder.audioFile
        
        //export file name HLDD.m4a
        tape.exportAsynchronously(name: "HLDD",
                                  baseDir: .documents,
                                  exportFormat: .m4a) { _, error in
                                    if let error = error {
                                        AKLog("Export Failed \(error)")
                                    } else {
                                        AKLog("Export succeeded")
                                        print("Export succeeded")
                                    }
        }
        
        try? AudioKit.stop()
        mixer.disconnectInput(bus: 2)
        recordPlayer = AKPlayer(audioFile: tape)
        mixer.connect(input: recordPlayer, bus: 2)
        try? AudioKit.start()
        
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
    
}
extension ViewController: GridViewStopScrollingWhileUIKitIsTouchingDelegate {
    
    func isInteractWithUser(bool: Bool) {
        mixerView.trackGridView.isPagingEnabled = bool
    }
    
    
}

extension ViewController: GridViewDelegate {
    
}

extension ViewController: GridViewDataSource {
    
    func numberOfColumns(in gridView: GridView) -> Int {
        return 4
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 3
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "IOGridViewCell", for: indexPath) as? IOGridViewCell else { fatalError() }
            cell.delegate = self
            cell.datasource = self
            return cell
        case 1:
            //need set tableView
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "PlugInGridViewCell", for: indexPath) as? PlugInGridViewCell else { fatalError() }
            cellTableView = cell.tableView
            cell.tableView.delegate = self
            cell.tableView.dataSource = self
            return cell
        case 2:
            guard let cell = mixerView.trackGridView.dequeueReusableCell(withReuseIdentifier: "FaderGridViewCell", for: indexPath) as? FaderGridViewCell else { fatalError() }
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
            return (mixerView.bounds.height-50)/2
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

extension ViewController: UITableViewDelegate {
    //將資料傳到 plugIn 的 VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? PlugInViewController else { return }
        controller.plugInArr = plugInArr
        controller.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "PlugInTableViewSegue", sender: nil)
        }
        
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
        
        switch plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            cell.plugInLabel.text = "REVERB"
            guard let reverb = reverb as? AKReverb else { fatalError() }
            switch plugInArr[indexPath.row].bypass {
            case true:
                
                cell.bypassButton.isSelected = true
                reverb.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                reverb.start()
            }
        }
        cell.delegate = self
        
        return cell
    }
    
}

extension ViewController: PlugInViewControllerDelegate {
    
    //this change is come from pluginVC
    func plugInReverbBypass(indexPathAtPlugInArr indexPath: IndexPath) {
        //342
        //plugInArr[indexPath.row].byPass = !plugInArr[indexPath.row].byPass
        try? AudioKit.stop()
        
        switch plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else { fatalError() }
            switch plugInArr[indexPath.row].bypass {
            case true:
                plugInArr[indexPath.row].bypass = false
                reverb.bypass()
            case false:
                plugInArr[indexPath.row].bypass = true
                reverb.start()
            }
        }
        try? AudioKit.start()
        cellTableView?.reloadData()
    }
    
    func plugInReverbDryWetMixValueChange(value: Float) {
        switch plugInArr[0].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else{ fatalError() }
            reverb.dryWetMix = Double(value)
        }
    }
    
    func plugInReverbSelectFactory(_ factoryRawValue: Int) {
        
        switch plugInArr[0].plugIn {
        case .reverb(let reverb):
            
            guard let reverb = reverb as? AKReverb else{ fatalError() }
            
            
//            guard let numberInFactory = reverbFactory.firstIndex(of: factory) else { fatalError()}
            let rawValue = factoryRawValue
            guard let set = AVAudioUnitReverbPreset(rawValue: rawValue) else { fatalError() }
            reverb.loadFactoryPreset(set)
            reverb.factory = reverbFactory[rawValue]
        }
        
    }
    
}

extension ViewController: PlugInTableViewCellDelegate{
    
    func bypassPlugin(_ cell: PlugInTableViewCell) {
        
        guard let indexPath = cellTableView?.indexPath(for: cell) else{ return }

        try? AudioKit.stop()
        
        switch plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else { fatalError() }
            switch plugInArr[indexPath.row].bypass {
            case true:
                plugInArr[indexPath.row].bypass = false
                reverb.bypass()
            case false:
                plugInArr[indexPath.row].bypass = true
                reverb.start()
            }
        }
        try? AudioKit.start()
    }
    
}

extension ViewController: IOGridViewCellDelegate {
    
    func didSelectInputSource(inputSource: String) {
        let currentDevice = currentInputDevice()
        let fileInDevice = getFileFromDevice()
        
        if inputSource == currentDevice {
            try? AudioKit.stop()
            print("InputDeviceAsInputMixerSource:\(currentDevice)")
            //take the mic node after plugin
            guard let micNode = bus1Node else { fatalError() }
            //connect with mixer to do callBack before playing
            //使用 mixer bus 1 as input
            
            mixer.disconnectInput(bus: 3)
            mixer.connect(input: micNode, bus: 1)
            try? AudioKit.start()
            //switch the track status
            firstTrackStatus = .lineIn
            return
            
        } else {
            //disconnect on bus 1 (mic bus)
            try? AudioKit.stop()
            mixer.disconnectInput(bus: 1)
            try? AudioKit.start()
            
            for fileName in fileInDevice{
                if fileName == inputSource {
                    //set the file as mixer input
                    let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                    
                    switch result {
                    case .success(let file):
                        filePlayer = AKPlayer(audioFile: file)
                        try? AudioKit.stop()
                        mixer.connect(input: filePlayer, bus: 3)
                        try? AudioKit.start()
                        print("FileSelectIn:\(fileName)")
                        //switch the track status
                        firstTrackStatus = .audioFile
                        return
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            // do error handle
            print(inputSource)
            print("dont use")
        }
    }
    
}

extension ViewController: IOGridViewCellDatasource {
    
    func inputSource() -> [String] {
        var fileInDeviceNameArr = getFileFromDevice()
        guard let currentInputDevice = AudioKit.inputDevice?.deviceID else { fatalError() }
        fileInDeviceNameArr.insert(currentInputDevice, at: 0)
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
    
    func plugInProvide() {
        try? AudioKit.stop()
        plugInArr.append(HLDDStudioPlugIn(plugIn: .reverb(AKReverb(mic)), bypass: false, sequence: 0))
        switch plugInArr[0].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else { fatalError() }
            reverb.start()
        }
        bus1Node = PlugInCreater.shared.providePlugInNode(with: plugInArr[0])
        try? AudioKit.start()
    }
    
}

