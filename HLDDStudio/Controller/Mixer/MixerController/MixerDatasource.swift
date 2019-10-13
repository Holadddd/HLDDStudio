//
//  MixerDatasource.swift
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
        
        if PlugInManager.shared.plugInOntruck[0].trackInputStatus != .noInput ||
            PlugInManager.shared.plugInOntruck[1].trackInputStatus != .noInput {
            
            return true
        } else {
            
            MixerManger.manger.title(with: .recordWarning)
            
            MixerManger.manger.subTitle(with: .checkInputSource)
            
            return false
        }
    }
}
