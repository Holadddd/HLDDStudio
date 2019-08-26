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

class MixerManger {

    static let manger = MixerManger()

    var mixer = AKMixer()
    
    var mixerForMaster = AKMixer()
    
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
