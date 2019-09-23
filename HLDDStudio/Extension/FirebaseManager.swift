//
//  FirebaseManager.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import Firebase
enum FBAScreen: String {
    
    case Mixer = "MixerScreen"
    
    case DrumMachine = "DrumMachineScreen"
}

enum FBACategory: String {
    
    case ViewController = "MixerViewController"
    
    case DrumMachineController = "DrumMachineController"
}

enum FBAAction: String {
    
    case ViewDidAppear = "ViewDidAppear"
    
    case PlayAudio = "PlayAudio"
    
    case Record = "Record"
}

enum FBALabel: String {
    case UsersEvent = "UsersEvent"
}

enum FBAValue: NSNumber {
    case one = 1
}

class FirebaseManager {
    
    static func createEventWith(category: FBACategory, action: FBAAction, label: FBALabel, value: FBAValue) {
        Analytics.logEvent(action.rawValue, parameters:
            ["Category": category.rawValue,
             "Action": action.rawValue,
             "Label": label.rawValue,
             "Value": value.rawValue])
    }
}
