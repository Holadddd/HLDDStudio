//
//  MixerGridViewCellDelegate.swift
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

extension ViewController: PlugInGridViewCellDelegate {
    
    func bypassPlugin(atRow row: Int, Column column: Int) {
        
        try? AudioKit.stop()
        
        switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].plugIn {
        case .reverb(let reverb):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                reverb.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                reverb.start()
            }
        case .guitarProcessor(let guitarProcessor):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                guitarProcessor.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                guitarProcessor.start()
            }
        case .delay(let delay):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                delay.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                delay.start()
            }
        case .chorus(let chorus):
            switch PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = false
                chorus.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[column].plugInArr[row].bypass = true
                chorus.start()
            }
        }
        try? AudioKit.start()
        
    }
    
    func perforPlugInVC(forTrack column: Int) {
        
        PlugInCreater.shared.showingTrackOnPlugInVC = column
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            self.performSegue(withIdentifier: "PlugInTableViewSegue", sender: nil)
        }
        
    }
    
    func resetTrackOn(Track track: Int) {
        setTrackNode(track: track)
    }
    
}

extension ViewController: FaderGridViewCellDelegate {
    func pannerValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busPanner.pan = value
    }
    
    func lowEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busLowEQ.gain = value
    }
    
    func midEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busMidEQ.gain = value
    }
    
    func highEQValueChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busHighEQ.gain = value
    }
    
    func volumeChange(value: Float, cell: FaderGridViewCell) {
        let value = Double(value)
        PlugInCreater.shared.plugInOntruck[cell.indexPath.column].equlizerAndPanner.busBooster.gain = value
    }
}

extension ViewController: IOGridViewCellDelegate {
    
    func didSelectDrumMachine(cell: IOGridViewCell) {
        switch cell.indexPath.column {
        case 0:
            print("TrackOne select drummachine")
            MixerManger.manger.firstTrackStatus = .drumMachine
            
        case 1:
            print("TrackTwo select drummachine")
            MixerManger.manger.secondTrackStatus = .drumMachine
            
        default:
            print("error")
        }
    }
    
    
    func didSelectInputSource(inputSource: String, cell: IOGridViewCell) {
        
        switch cell.indexPath.column {
            
        case 0:  //Bus1
            
            let currentDevice = currentInputDevice()
            let fileInDeviceArr = getFileFromDevice()
            if inputSource == currentDevice {
                
                try? AudioKit.stop()
                
                print("InputDeviceAsInputMixerBus1Source:\(currentDevice)")
                MixerManger.manger.title(with: .HLDDStudio)
                MixerManger.manger.subTitleContent = "Selected \(currentDevice) As Trackone Input Source."
                
                PlugInCreater.shared.plugInOntruck[0].inputNode = MixerManger.manger.mic
                
                setTrackNode(track: 1)
                
                try? AudioKit.start()
                //switch the track status
                MixerManger.manger.firstTrackStatus = .lineIn
                FirebaseManager.createEventWith(category: .ViewController, action: .SwitchInputDevice, label: .UsersEvent, value: .one)
                return
                
            } else {
                for fileName in fileInDeviceArr {
                    
                    if fileName == inputSource {
                        try? AudioKit.stop()
                        //set the file as mixer input
                        let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                        
                        switch result {
                        case .success(let file):
                            
                            PlugInCreater.shared.plugInOntruck[0].filePlayer = AKPlayer(audioFile: file)
                            PlugInCreater.shared.plugInOntruck[0].inputNode = PlugInCreater.shared.plugInOntruck[0].filePlayer
                            
                            //need adjust for audioFile into plugIn
                            PlugInCreater.shared.resetTrackNode(Track: 1)
                            setTrackNode(track: 1)
                            
                            print("FirstTrackFileSelectIn:\(fileName)")
                            MixerManger.manger.title(with: .HLDDStudio)
                            MixerManger.manger.subTitleContent = "Selected \(fileName) As Trackone Input File."
                            //switch the track status
                            MixerManger.manger.firstTrackStatus = .audioFile
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                        try? AudioKit.start()
                        FirebaseManager.createEventWith(category: .ViewController, action: .SwitchAudioFile, label: .UsersEvent, value: .one)
                        return
                    }
                }
            }
        case 1:
            let currentDevice = currentInputDevice()
            let fileInDeviceArr = getFileFromDevice()
            if inputSource == currentDevice {
                try? AudioKit.stop()
                MixerManger.manger.title(with: .HLDDStudio)
                MixerManger.manger.subTitleContent = "Selected \(currentDevice) As Tracktwo Input Source."
                PlugInCreater.shared.plugInOntruck[1].inputNode = MixerManger.manger.mic
                //need adjust for audioFile into plugIn
                //PlugInCreater.shared.resetTrackNode(Track: 2)
                setTrackNode(track: 2)
                try? AudioKit.start()
                //switch the track status
                MixerManger.manger.secondTrackStatus = .lineIn
                
                return
                
            } else {
                for fileName in fileInDeviceArr {
                    
                    if fileName == inputSource {
                        //set the file as mixer input
                        try? AudioKit.stop()
                        let result = Result{ try AKAudioFile(readFileName: fileName, baseDir: .documents)}
                        
                        switch result {
                        case .success(let file):
                            PlugInCreater.shared.plugInOntruck[1].filePlayer = AKPlayer(audioFile: file)
                            PlugInCreater.shared.plugInOntruck[1].inputNode = PlugInCreater.shared.plugInOntruck[1].filePlayer
                            
                            //need adjust for audioFile into plugIn
                            PlugInCreater.shared.resetTrackNode(Track: 2)
                            setTrackNode(track: 2)
                            MixerManger.manger.title(with: .HLDDStudio)
                            MixerManger.manger.subTitleContent = "Selected \(fileName) As Tracktwo Input File."
                            //switch the track status
                            MixerManger.manger.secondTrackStatus = .audioFile
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                        try? AudioKit.start()
                        return
                    }
                }
            }
            
        default:
            MixerManger.manger.title(with: .HLDDStudio)
            MixerManger.manger.subTitleContent = "ERROR OF SETTING INPUT"
        }
    }
    
    func addPlugIn(with plugIn: PlugIn, row: Int, column: Int, cell: IOGridViewCell) {
        
        switch plugIn {
        case .reverb(let reverb):
            plugInProvide(row: row, column: column, plugIn: .reverb(reverb))
        case .guitarProcessor(let guitarProcessor):
            plugInProvide(row: row, column: column, plugIn: .guitarProcessor(guitarProcessor))
        case .delay(let delay):
            plugInProvide(row: row, column: column, plugIn: .delay(delay))
        case .chorus(let chorus):
            plugInProvide(row: row, column: column, plugIn: .chorus(chorus))
        }
        
    }
    
    func noInputSource(cell: IOGridViewCell) {
        
        try? AudioKit.stop()
        let indexPath = cell.indexPath
        switch indexPath.column {
        case 0:
            MixerManger.manger.firstTrackStatus = .noInput
            MixerManger.manger.mixer.disconnectInput(bus: 1)
            MixerManger.manger.title(with: .HLDDStudio)
            MixerManger.manger.subTitleContent = "Disconnect Trackone."
        case 1:
            MixerManger.manger.secondTrackStatus = .noInput
            MixerManger.manger.mixer.disconnectInput(bus: 2)
            MixerManger.manger.title(with: .HLDDStudio)
            MixerManger.manger.subTitleContent = "Disconnect Tracktwo."
        default:
            print("No Need For Disconnect")
        }
        
        try? AudioKit.start()
    }
    
}
