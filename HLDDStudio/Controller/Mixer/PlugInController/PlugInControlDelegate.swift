//
//  PlugInControlDelegate.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit

extension PlugInViewController: PlugInControlDelegate {
    
    func plugInReverbFactorySelect(_ factoryRawValue: Int, cell: PlugInReverbTableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let set = AVAudioUnitReverbPreset(rawValue: factoryRawValue) else{ fatalError()}
            
            reverb.loadFactoryPreset(set)
            reverb.factory = reverbFactory[factoryRawValue]
            PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn = PlugIn.reverb(reverb)
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
    }
    
    func dryWetMixValueChange(_ value: Float, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(let reverb):
            reverb.dryWetMix = Double(value)
            PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.reverb(reverb)
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
    }
    
    func guitarProcessorValueChange(_ value: Float, type: GuitarProcessorValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(let guitarProcessor):
            switch type {
            case .dist:
                guitarProcessor.distortion = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            case .outputGain:
                guitarProcessor.postGain = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            case .HLDDPreGain:
                guitarProcessor.preGain = Double(value)
                guitarProcessor.HLDDPreGain = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            }
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        
    }
    
    func delayValueChange(_ value: Float, type: DelayValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(_):
            return
        case .delay(let delay):
            switch type {
            case .time:
                delay.time = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            case .feedback:
                delay.feedback = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            case .mix:
                delay.dryWetMix = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            }
            return
        case .chorus(_):
            return
        }
    }
    
    func chorusValueChange(_ value: Float, type: ChorusValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(let chorus):
            switch type{
            case .depth:
                chorus.depth = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .feedback:
                chorus.feedback = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .frequency:
                chorus.frequency = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .mix:
                chorus.dryWetMix = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            }
            return
        }
    }
    
    func plugInBypassSwitch(_ isBypass: Bool, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        PlugInCreater.shared.plugInBypass(track, seq: row)
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
        
    }
}
