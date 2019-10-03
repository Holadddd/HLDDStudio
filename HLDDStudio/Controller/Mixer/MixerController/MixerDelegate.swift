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
        for (inedx, element) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            switch element.trackInputStatus {
                
            case .lineIn:
                
                break
            case .audioFile :
                
                PlugInManager.shared.plugInOntruck[inedx].filePlayer.stop()
                
                PlugInManager.shared.plugInOntruck[inedx].filePlayer.preroll()
            case .noInput:
                
                break
            case .drumMachine:
                
                DrumMachineManger.manger.stopPlayingDrumMachine()
            }
        }
    }
    
    func playingAudioPlayer() {
        
        FirebaseManager.createEventWith(category: .ViewController,
                             action: .PlayAudio,
                             label: .UsersEvent,
                             value: .one)
        
        if PlugInManager.shared.plugInOntruck[0].trackInputStatus == .noInput &&
            PlugInManager.shared.plugInOntruck[1].trackInputStatus == .noInput {
            
            MixerManger.manger.title(with: .HLDDStudio)
            
            MixerManger.manger.subTitle(with: .noFileOrInputSource)
        }
        
        MixerManger.manger.mixerStatus = .prepareToRecordAndPlay
        
        for (index, _) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            PlugInManager.shared.plugInOntruck[index].filePlayer.prepare()
        }
        
        MixerManger.manger.metronome.start()
        
        MixerManger.manger.semaphore.wait()
        
        let oneBarTime = (60 / MixerManger.manger.metronome.tempo) * 4
        
        disabledMixerFunctionalButton()
        
        for (inedx, element) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            switch element.trackInputStatus {
                
            case .lineIn:
                
                print("firstTracklineIN")
            case .audioFile :
                
                if PlugInManager.shared.plugInOntruck[inedx].filePlayer.isPaused {
                    
                    PlugInManager.shared.plugInOntruck[inedx].filePlayer.resume()
                } else {
                    
                    let time = MixerManger.manger.metronomeStartTime + oneBarTime
                    
                    PlugInManager.shared.plugInOntruck[inedx].filePlayer.play(at: time)
                }
            case .noInput:
                
                print("firstTrackNoInput")
            case .drumMachine:
                
                DrumMachineManger.manger.mixerPlayDrumMachine()
                
                print("firstTrack pause drumMachine")
            }
        }
        
        mixerView.recordButton.isEnabled = false
    }
    
    func pauseAudioPlayer() {
        
        MixerManger.manger.metronome.stop()
        
        enabledMixerFunctionalButton()
        
        for (inedx, element) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            switch element.trackInputStatus {
                
            case .lineIn:
                
                print("firstTracklineIN")
            case .audioFile :
                
                PlugInManager.shared.plugInOntruck[inedx].filePlayer.pause()
                
                print("firstTrackPlaySelectFile")
            case .noInput:
                
                print("firstTrackNoInput")
            case .drumMachine:
                
                DrumMachineManger.manger.stopPlayingDrumMachine()
                
                print("firstTrack pause drumMachine")
            }
        }
    }
    
    func resumeAudioPlayer() {
        
        print("resumePlayer")
        
        MixerManger.manger.metronome.start()
        
        enabledMixerFunctionalButton()
        
        for (inedx, element) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            switch element.trackInputStatus {
                
            case .lineIn:
                
                print("firstTracklineIN")
            case .audioFile :
                
                PlugInManager.shared.plugInOntruck[inedx].filePlayer.pause()
                
                print("firstTrackPlaySelectFile")
            case .noInput:
                
                print("firstTrackNoInput")
            case .drumMachine:
                
                DrumMachineManger.manger.mixerPlayDrumMachine()
                
                print("firstTrack resume drumMachine")
            }
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
        
        for (index, _) in PlugInManager.shared.plugInOntruck.enumerated(){
            
            PlugInManager.shared.plugInOntruck[index].filePlayer.prepare()
            
            PlugInManager.shared.plugInOntruck[index].filePlayer.preroll()
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
            for (index, element) in PlugInManager.shared.plugInOntruck.enumerated(){
                switch element.trackInputStatus {
                case .audioFile:
                    
                    let time = MixerManger.manger.metronomeStartTime + oneBarTime
                    
                    PlugInManager.shared.plugInOntruck[index].filePlayer.play(at: time)
                case .drumMachine:
                    
                    DrumMachineManger.manger.mixerPlayDrumMachine()
                case .noInput:
                    
                    break
                case .lineIn:
                    
                    break
                }
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
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let self = self else { return }
            
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
