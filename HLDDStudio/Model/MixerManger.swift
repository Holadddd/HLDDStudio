//
//  MixerManger.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/9.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AVKit

enum TrackInputStatus {
    
    case noInput
    
    case lineIn
    
    case audioFile
}

enum MixerStatus {
    
    case prepareToRecordAndPlay
    
    case recordingAndPlaying
    
    case stopRecordingAndPlaying
}

enum MixerMangerTilte {
    
    case HLDDStudio
    
    case recordWarning
    
    case recording
    
    case finishingRecording
    
}

enum MixerMangerSubTilte {
    
    case selectInputDevice
    
    case metronomeIsOn
    
    case metronomeIsOff
    
    case checkInputSource
}

enum MixerError: Error{
    
    case recordFileError
}

class MixerManger {

    static let manger = MixerManger()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    var bar = 0 {
        didSet {
            
        }
    }
    
    var beat = 0 {
        didSet {
            
        }
    }
    
    let metronome = AKMetronome()
    
    var metronomeBooster: AKBooster!
    
    var metronomeStartTime:AVAudioTime = AVAudioTime.now()
    
    var mic: AKMicrophone!

    var mixer: AKMixer = AKMixer()
    
    var mixerForMaster: AKMixer = AKMixer()
    
    var recorder: AKClipRecorder!
    
    var recordFile: AKAudioFile!
    
    var recordFileName: String = ""
    
    var titleContent: String = "" {
        didSet {
            NotificationCenter.default.post(.init(name: .mixerNotificationTitleChange))
        }
    }

    var subTitleContent: String = ""{
        didSet {
            NotificationCenter.default.post(.init(name: .mixerNotificationSubTitleChange))
        }
    }
    
    var mixerStatus = MixerStatus.stopRecordingAndPlaying
    
    init() {
        metronome.callback = metronomeCallBack
        metronomeBooster = AKBooster(metronome)
        mic = AKMicrophone()
        recorder = AKClipRecorder(node: mixer)
        //
        let recordResult = Result{try AKAudioFile()}
        switch recordResult {
        case .success(let recordFile):
            self.recordFile = recordFile
        case .failure:
            print(MixerError.recordFileError)
        }
    }
    
    func metronomeCallBack() {
        print("\(self.bar) | \((self.beat % 4) + 1 )")
        NotificationCenter.default.post(.init(name: .mixerBarTitleChange))
        if mixerStatus  == .prepareToRecordAndPlay {
            metronomeStartTime = AVAudioTime.now()
            mixerStatus = .recordingAndPlaying
            print("metronomeFirstCallBackTime:\(DispatchTime.now())")
            print("1")
            semaphore.signal()
        }
        DispatchQueue.main.async {
            self.beat += 1
            self.bar = Int(self.beat/4)
        }
        
    }
    
    func title(with title: MixerMangerTilte) {
        switch title {
        case .HLDDStudio:
            MixerManger.manger.titleContent = "HLDDStudio"
        case .recordWarning:
            MixerManger.manger.titleContent = "RecordWarning"
        case .finishingRecording:
            MixerManger.manger.titleContent = "Record Complete."
        case .recording:
            MixerManger.manger.titleContent = "Mixer Is Recording. . ."
        }
    }
    
    func subTitle(with subTitle: MixerMangerSubTilte ) {
        switch subTitle {
        case .selectInputDevice:
            MixerManger.manger.subTitleContent = "Select Input Device."
        case .metronomeIsOn:
            MixerManger.manger.subTitleContent = "Metronome Is On."
        case .metronomeIsOff:
            MixerManger.manger.subTitleContent = "Metronome Is Off."
        case .checkInputSource:
            MixerManger.manger.subTitleContent = "Check Input Source."
        }
    }
}
