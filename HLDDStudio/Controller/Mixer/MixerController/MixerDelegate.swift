//
//  MixerDelegate.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//
import UIKit
import Foundation
import G3GridView
import AVKit
import AudioKit
import Firebase
import Crashlytics

extension ViewController: MixerDelegate {
    
    func showDrumVC() {
        
        var vc: UIViewController = UIViewController()
        
        if #available(iOS 13.0, *) {
            
            vc = UIStoryboard
                .drumMachine
                .instantiateViewController(identifier: String(describing: DrumMachineViewController.self))
        } else {
            // Fallback on earlier versions
            vc = UIStoryboard
                .drumMachine
                .instantiateViewController(withIdentifier: String(describing: DrumMachineViewController.self) )
        }
        
        guard let drumVC = vc as? DrumMachineViewController else { fatalError() }
        
        drumVC.modalPresentationStyle = .fullScreen
        
        present(drumVC,
                animated: true){
            
            self.mixerView.stopButtonAction()
        }
    }
    
    func didSelectInputDevice(_ deviceID: DeviceID) {
        
        guard let inputDeviceArr = AudioKit.inputDevices else { fatalError() }
        
        for device in inputDeviceArr {
            
            if device.deviceID == deviceID {
                
                let result = Result{ try AudioKit.setInputDevice(device) }
                
                switch result {
                    
                case .success():
                    
                    MixerManger.manger.title(with: .HLDDStudio)
                    
                    MixerManger.manger.subTitleContent = "Selected \(device.deviceID) As Input Device"
                    
                    try? AudioKit.setInputDevice(device)
                case .failure(let error):
                    
                    print(error)
                }
            }
        }
    }
    
    func metronomeSwitch(isOn: Bool) {
        
        switch isOn {
            
        case true:
            
            MixerManger.manger.metronomeBooster.gain = 1
        case false:
            
            MixerManger.manger.metronomeBooster.gain = 0
        }
    }
    
    func metronomeBPM(bpm: Int) {
        
        MixerManger.manger.metronome.tempo = Double(bpm)
    }
    
    func stopAudioPlayer() {
        
        enabledMixerFunctionalButton()
        
        mixerView.playAndResumeButton.isEnabled = true
        
        mixerView.recordButton.isEnabled = true
        
        MixerManger.manger.metronome.restart()
        
        MixerManger.manger.metronome.stop()
        
        MixerManger.manger.mixerStatus = .stopRecordingAndPlaying
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self else{ return }
            
            MixerManger.manger.bar = 0
            
            MixerManger.manger.beat = 0
            
            strongSelf.mixerView.barLabel.text = "0 | 1"
        }
        
        switch MixerManger.manger.firstTrackStatus {
            
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[0].filePlayer.stop()
            
            PlugInCreater.shared.plugInOntruck[0].filePlayer.preroll()
        case .noInput:
            
            print("firstTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.stopPlayingDrumMachine()
            print("Firsttrack stop drummachine")
        }
        
        switch MixerManger.manger.secondTrackStatus {
            
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[1].filePlayer.stop()
            
            PlugInCreater.shared.plugInOntruck[1].filePlayer.preroll()
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            
            print("secondTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.stopPlayingDrumMachine()
            
            print("Secondtrack stop drummachine")
        }
    }
    
    func playingAudioPlayer() {
        
        FirebaseManager.createEventWith(category: .ViewController,
                             action: .PlayAudio,
                             label: .UsersEvent,
                             value: .one)
        
        if MixerManger.manger.firstTrackStatus == .noInput &&
            MixerManger.manger.secondTrackStatus == .noInput {
            
            MixerManger.manger.title(with: .HLDDStudio)
            
            MixerManger.manger.subTitle(with: .noFileOrInputSource)
        }
        
        MixerManger.manger.mixerStatus = .prepareToRecordAndPlay
        
        PlugInCreater.shared.plugInOntruck[0].filePlayer.prepare()
        
        PlugInCreater.shared.plugInOntruck[1].filePlayer.prepare()
        
        MixerManger.manger.metronome.start()
        
        MixerManger.manger.semaphore.wait()
        
        let oneBarTime = (60 / MixerManger.manger.metronome.tempo) * 4
        
        disabledMixerFunctionalButton()
        
        switch MixerManger.manger.firstTrackStatus {
            
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            if PlugInCreater.shared.plugInOntruck[0].filePlayer.isPaused {
                
                PlugInCreater.shared.plugInOntruck[0].filePlayer.resume()
            } else {
                let time = MixerManger.manger.metronomeStartTime + oneBarTime
                
                PlugInCreater.shared.plugInOntruck[0].filePlayer.play(at: time)
            }
        case .noInput:
            
            print("firstTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.mixerPlayDrumMachine()
            
            print("firstTrack pause drumMachine")
        }
        
        switch MixerManger.manger.secondTrackStatus {
            
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            if PlugInCreater.shared.plugInOntruck[1].filePlayer.isPaused {
                
                PlugInCreater.shared.plugInOntruck[1].filePlayer.resume()
            } else {
                
                let time = MixerManger.manger.metronomeStartTime + oneBarTime
                
                PlugInCreater.shared.plugInOntruck[1].filePlayer.play(at: time)
            }
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            
            print("secondTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.mixerPlayDrumMachine()
            
            print("secondTrack pause drumMachine")
        }
        
        mixerView.recordButton.isEnabled = false
    }
    
    func pauseAudioPlayer() {
        
        MixerManger.manger.metronome.stop()
        
        enabledMixerFunctionalButton()
        
        switch MixerManger.manger.firstTrackStatus {
            
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[0].filePlayer.pause()
            
            print("firstTrackPlaySelectFile")
        case .noInput:
            
            print("firstTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.stopPlayingDrumMachine()
            
            print("firstTrack pause drumMachine")
        }
        
        switch MixerManger.manger.secondTrackStatus {
            
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[1].filePlayer.pause()
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            
            print("secondTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.stopPlayingDrumMachine()
            
            print("second pause drumMachine")
        }
    }
    
    func resumeAudioPlayer() {
        
        print("resumePlayer")
        
        MixerManger.manger.metronome.start()
        
        enabledMixerFunctionalButton()
        //for each player play]
        switch MixerManger.manger.firstTrackStatus {
            
        case .lineIn:
            
            print("firstTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[0].filePlayer.pause()
            
            print("firstTrackPlaySelectFile")
        case .noInput:
            
            print("firstTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.mixerPlayDrumMachine()
            
            print("firstTrack resume drumMachine")
        }
        
        switch MixerManger.manger.secondTrackStatus {
            
        case .lineIn:
            
            print("secondTracklineIN")
        case .audioFile :
            
            PlugInCreater.shared.plugInOntruck[1].filePlayer.pause()
            
            print("secondTrackPlaySelectFile")
        case .noInput:
            
            print("secondTrackNoInput")
        case .drumMachine:
            
            DrumMachineManger.manger.mixerPlayDrumMachine()
            
            print("second resume drumMachine")
        }
    }
    
    func startRecordAudioPlayer(frombar start: Int,
                                tobar stop: Int){
        
        disabledMixerFunctionalButton()
        
        FirebaseManager.createEventWith(category: .ViewController,
                                        action: .Record,
                                        label: .UsersEvent,
                                        value: .one)
        
        MixerManger.manger.mixerStatus = .prepareToRecordAndPlay
        
        for (index, _) in PlugInCreater.shared.plugInOntruck.enumerated(){
            
            PlugInCreater.shared.plugInOntruck[index].filePlayer.prepare()
            
            PlugInCreater.shared.plugInOntruck[index].filePlayer.preroll()
        }
        
        print(MixerManger.manger.metronome.tempo)
        
        let oneBarTime = (60 / MixerManger.manger.metronome.tempo) * 4
        
        let durationTime = (stop - start + 1) * oneBarTime
        //needStartRecorder
        MixerManger.manger.recorder.start()
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self else { return }
            
            MixerManger.manger.bar = 0
            
            MixerManger.manger.beat = 0
            
            strongSelf.mixerView.barLabel.text = "0 | 1"
        }
        
        MixerManger.manger.metronome.start()
        
        MixerManger.manger.semaphore.wait()
        
        let recordMetronomeStartTime = AVAudioTime.now()
        
        let adjustTime = AVAudioTime.now().hostTime - recordMetronomeStartTime.hostTime
        
        let processTime = AVAudioTime.init(hostTime: adjustTime)
        
        let  processTimeToSec = processTime.toSeconds(hostTime: processTime.hostTime)
        
        let recorderStartTimeSec = oneBarTime * start - processTimeToSec
        
        DispatchQueue.main.async {  [weak self ] in
            
            try? MixerManger.manger.recorder.recordClip(time:  recorderStartTimeSec,
                                                        duration: Double(durationTime).rounded(),
                                                        tap: nil){ [ weak self ] result in
                                                            
                guard let strongSelf = self  else { fatalError() }
                                                            
                switch result {
                    
                case .clip(let clip):
                    
                    let date = Date()
                    
                    let dateFormatter = DateFormatter()
                    
                    MixerManger.manger.metronome.stop()
                    
                    dateFormatter.dateFormat = MixerManger.manger.recordFileDefaultDateNameFormatt
                    //判斷有無輸入
                    if MixerManger.manger.recordFileName == "" {
                        
                        let dateString = dateFormatter.string(from: date)
                        
                        MixerManger.manger.recordFileName = dateString
                    }
                    
                    do {
                        
                        let urlInDocs = FileManager.docs.appendingPathComponent("\(MixerManger.manger.recordFileName)(\(Int(MixerManger.manger.metronome.tempo)))").appendingPathExtension(clip.url.pathExtension)
                        
                        try FileManager.default.moveItem(at: clip.url, to: urlInDocs)
                        MixerManger.manger.recordFile = try AKAudioFile(forReading: urlInDocs)
                        MixerManger.manger.mixerStatus = .stopRecordingAndPlaying
                    } catch {
                        print(error)
                    }
                    
                    MixerManger.manger.recorder.stop()
                    strongSelf.mixerView.recordButtonAction()
                    DispatchQueue.main.async {
                        strongSelf.mixerView.playAndResumeButton.isEnabled = true
                    }
                case .error(let error):
                    AKLog(error)
                    return
                }
            }
            //        play audio
            if MixerManger.manger.firstTrackStatus == .audioFile {
                
                PlugInCreater.shared.plugInOntruck[0].filePlayer.play(at: MixerManger.manger.metronomeStartTime + oneBarTime)
            }
            if MixerManger.manger.secondTrackStatus == .audioFile {
                
                PlugInCreater.shared.plugInOntruck[1].filePlayer.play(at: MixerManger.manger.metronomeStartTime + oneBarTime)
            }
            // play drumMachine
            if MixerManger.manger.firstTrackStatus == .drumMachine {
                
                DrumMachineManger.manger.mixerPlayDrumMachine()
            }
            if MixerManger.manger.secondTrackStatus == .drumMachine {
                
                DrumMachineManger.manger.mixerPlayDrumMachine()
            }
        }
        MixerManger.manger.title(with: .recording)
        MixerManger.manger.subTitleContent = "Device Is Recording From Bar \(start) to \(stop). Duration: \(String(format: "%.2f", durationTime)) seconds."
        
        mixerView.playAndResumeButton.isEnabled = false
    }
    
    func stopRecord() {
        enabledMixerFunctionalButton()
        try? AudioKit.stop()
        MixerManger.manger.title(with: .finishingRecording)
        MixerManger.manger.subTitleContent = "File: \(MixerManger.manger.recordFileName) is saved."
        mixerView.fileNameTextField.text = nil
        mixerView.fileNameTextField.placeholder = "FileName"
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            DrumMachineManger.manger.stopPlayingDrumMachine()
            MixerManger.manger.bar = 0
            MixerManger.manger.beat = 0
            self.mixerView.barLabel.text = "0 | 1"
            MixerManger.manger.metronome.restart()
            MixerManger.manger.metronome.stop()
        }
        try? AudioKit.start()
        
    }
    
    func changeRecordFileName(fileName: String) {
        MixerManger.manger.recordFileName = fileName
    }
    
    func masterVolumeDidChange(volume: Float) {
        MixerManger.manger.mixerForMaster.volume = Double(volume)
        print(MixerManger.manger.mixerForMaster.volume)
    }
}
