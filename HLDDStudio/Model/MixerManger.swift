//
//  MixerManger.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/9.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation

enum TrackInputStatus {
    
    case noInput
    
    case lineIn
    
    case audioFile
}

enum RecorderStatus {
    
    case prepareToRecord
    
    case recording
    
    case stopRecording
}
