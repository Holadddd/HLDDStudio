//
//  GAManager.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
enum GAScreen: String {
    
    case Mixer = "MixerScreen"
    
    case DrumMachine = "DrumMachineScreen"
}

enum GACategory: String {
    
    case ViewController = "MixerViewController"
    
    case DrumMachineController = "DrumMachineController"
}

enum GAAction: String {
    
    case PlayAudio = "PlayAudio"
    
    case Record = "Record"
}

enum GALabel: String {
    case UsersEvent = "UsersEvent"
}

enum GAValue: NSNumber {
    case one = 1
}
class GAManager {
    
    static func createNormalScreenEventWith(_ screenName: GAScreen) {
    let tracker = GAI.sharedInstance().tracker(withTrackingId: AppDelegate.trackId)
        tracker?.set(kGAIScreenName, value: screenName.rawValue)
    guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
    tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    static func createNormalEventWith(category: GACategory, action: GAAction, label: GALabel, value: GAValue) {
        guard let event = GAIDictionaryBuilder.createEvent(withCategory: category.rawValue, action: action.rawValue, label: label.rawValue, value: value.rawValue) else { return }
    let tracker = GAI.sharedInstance().tracker(withTrackingId: AppDelegate.trackId)
    tracker?.send(event.build() as [NSObject: AnyObject])
    }
}
