//
//  MixerGridViewCellDatasource.swift
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

extension ViewController: IOGridViewCellDatasource {
    
    func inputSource() -> [String] {
        var fileInDeviceNameArr = getFileFromDevice()
        fileInDeviceNameArr.insert("\(InputSourceCase.drumMachine.rawValue)(\(DrumMachineManger.manger.bpm))", at: 0)
        guard let currentInputDevice = AudioKit.inputDevice?.deviceID else { fatalError() }
        fileInDeviceNameArr.insert(currentInputDevice, at: 0)
        fileInDeviceNameArr.insert(InputSourceCase.noInput.rawValue, at: 0)
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
