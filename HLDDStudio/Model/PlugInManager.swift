//
//  PlugInManager.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/9.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit

struct HLDDMixerTrack {
    let name: String
    var plugInArr: [HLDDStudioPlugIn] = []
    var inputNode: AKNode = AKPlayer()
    var node: AKNode = AKPlayer()
    var filePlayer = AKPlayer()
    var equlizerAndPanner: FaderEqualizerAndPanner = FaderEqualizerAndPanner(node: AKPlayer())

    init(name: String) {
        self.name = name
    }
}

struct HLDDStudioPlugIn {
    var plugIn: PlugIn
    var bypass: Bool
    var sequence: Int
}

//exist plugIn
let existPlugInArr = ["Reverb", "GuitarProcessor" , "Delay", "Chorus"]
enum PlugInDescription: String {
    case reverb = "Reverb"
    
    case guitarProcessor = "GuitarProcessor"
    
    case delay = "Delay"
    
    case chorus = "Chorus"
}

enum PlugIn {
    
    case reverb(AKReverb)
    
    case guitarProcessor(AKRhinoGuitarProcessor)
    
    case delay(AKDelay)
    
    case chorus(AKChorus)
    
    mutating func replaceInputNodeInPlugIn(node: AKNode)  {
        switch self {
        case let .reverb(reverb):
            
            let newReverb = AKReverb(node, dryWetMix: reverb.dryWetMix)
            guard let rawValue = reverbFactory.firstIndex(of: reverb.factory) else { fatalError() }
            guard let set = AVAudioUnitReverbPreset(rawValue: rawValue) else { fatalError() }
            newReverb.loadFactoryPreset(set)
            newReverb.factory = reverb.factory
            self = .reverb(newReverb)
        case let .guitarProcessor(guitarProcessor):
            
            let newRhinoGuitarProcessor = AKRhinoGuitarProcessor(node, preGain: guitarProcessor.HLDDPreGain, postGain: guitarProcessor.postGain, lowGain: -0.5, midGain: -0.5, highGain: -0.5, distortion: guitarProcessor.distortion)
            self = .guitarProcessor(newRhinoGuitarProcessor)
        case .delay(let delay):
            
            let newDelay = AKDelay(node, time: delay.time, feedback: delay.feedback, lowPassCutoff: 22_050, dryWetMix: delay.dryWetMix)
            self = .delay(newDelay)
        case .chorus(let chorus):
            
            let newChorus = AKChorus(node, frequency: chorus.frequency, depth: chorus.depth, feedback: chorus.feedback, dryWetMix: chorus.dryWetMix)
            self = .chorus(newChorus)
        }
    }
}

enum GuitarProcessorValueType {
    case HLDDPreGain
    
    case dist
    
    case outputGain
}

enum DelayValueType {
    case time
    
    case feedback
    
    case mix
}

enum ChorusValueType {
    case feedback
    
    case depth
    
    case mix
    
    case frequency
}

class PlugInCreater {
    
    static let shared = PlugInCreater()
    
    var eventRow = 0
    
    var eventColumn = 0
    
    var showingTrackOnPlugInVC = 0
    
    var plugInOntruck: [HLDDMixerTrack] = [HLDDMixerTrack(name: "Track1"), HLDDMixerTrack(name: "Track2")] {
        didSet {

            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: IndexPath(row: eventRow, column: eventColumn), userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: self, userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didRemovePlugIn, object: self, userInfo: nil))
        }
    }

    func resetTrack(track: Int) {
        
        let oldEqulizerAndPanner = PlugInCreater.shared.plugInOntruck[track - 1].equlizerAndPanner
        let panValue = oldEqulizerAndPanner.busPanner.pan
        let lowGain = oldEqulizerAndPanner.busLowEQ.gain
        let midGain = oldEqulizerAndPanner.busMidEQ.gain
        let highGain = oldEqulizerAndPanner.busHighEQ.gain
        let volume = oldEqulizerAndPanner.busBooster.gain
        try? AudioKit.stop()
        PlugInCreater.shared.plugInOntruck[track - 1].equlizerAndPanner = FaderEqualizerAndPanner(node: PlugInCreater.shared.plugInOntruck[track - 1].node, pan: panValue, lowGain: lowGain, midGain: midGain, highGain: highGain, volume: volume)
        PlugInCreater.shared.plugInOntruck[track - 1].node = PlugInCreater.shared.plugInOntruck[track - 1].equlizerAndPanner.busBooster
        try? AudioKit.start()
    }

    
    func providePlugInNode(with HLDD: HLDDStudioPlugIn) -> AKNode {
        let plugIn = HLDD.plugIn
        switch plugIn {
        case .reverb(let reverb):
            return reverb
        case .guitarProcessor(let GhinoGuitarProcessor):
            return GhinoGuitarProcessor
        case .delay(let delay):
            return delay
        case .chorus(let chorus):
            return chorus
        }
    }
    
    func resetTrackNode(Track: Int) {
        
        try? AudioKit.stop()
        let numberOfPlugIn = plugInOntruck[Track - 1].plugInArr.count
        
        PlugInCreater.shared.plugInOntruck[Track - 1].node = PlugInCreater.shared.plugInOntruck[Track - 1].inputNode

        if numberOfPlugIn != 0 {
            
            for seq in 0 ..< numberOfPlugIn {
                
                PlugInCreater.shared.plugInOntruck[Track - 1].plugInArr[seq].plugIn.replaceInputNodeInPlugIn(node: PlugInCreater.shared.plugInOntruck[Track - 1].node)
                
                            PlugInCreater.shared.plugInOntruck[Track - 1].node = PlugInCreater.shared.providePlugInNode(with: plugInOntruck[Track - 1].plugInArr[seq])
            }
            
        }
        
        try? AudioKit.start()
    }
    
    func deletePlugInOnTrack(_ track: Int, seq: Int) {
        try? AudioKit.stop()
        let column = track - 1
        PlugInCreater.shared.plugInOntruck[column].plugInArr.remove(at: seq)
        
        PlugInCreater.shared.resetTrackNode(Track: track)
        PlugInCreater.shared.resetTrack(track: track)
    }
    
    func plugInBypass(_ track: Int, seq: Int) {
        try? AudioKit.stop()
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].plugIn {
        case .reverb(let reverb):
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = false
                reverb.start()
            case false:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = true
                reverb.bypass()
            }
            
        case .guitarProcessor(let guitarProcessor):
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = false
                guitarProcessor.start()
                
            case false:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = true
                guitarProcessor.bypass()
            }
        case .delay(let delay):
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = false
                delay.start()
            case false:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = true
                delay.bypass()
            }
        case .chorus(let chorus):
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = false
                chorus.start()
            case false:
                PlugInCreater.shared.plugInOntruck[track].plugInArr[seq].bypass = true
                chorus.bypass()
            }
        }
        try? AudioKit.start()
    }
    
}
//extensionAKReverbFactoryProperty
let reverbFactory = ["Cathedral", "Large Hall", "Large Hall 2",
                     "Large Room", "Large Room 2", "Medium Chamber",
                     "Medium Hall", "Medium Hall 2", "Medium Hall 3",
                     "Medium Room", "Plate", "Small Room"]

extension AKReverb {
    private static var _myComputedProperty = [String: String]()
    
    var factory:String {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return AKReverb._myComputedProperty[tmpAddress] ?? "Cathedral"
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            AKReverb._myComputedProperty[tmpAddress] = newValue
        }
    }
}

extension AKRhinoGuitarProcessor {
    private static var _myComputedProperty = [String: Double]()
    
    var HLDDPreGain: Double {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return AKRhinoGuitarProcessor._myComputedProperty[tmpAddress] ?? 2.0
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            AKRhinoGuitarProcessor._myComputedProperty[tmpAddress] = newValue
        }
    }
    
    var HLDDPostGain: Double {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return AKRhinoGuitarProcessor._myComputedProperty[tmpAddress] ?? 0.5
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            AKRhinoGuitarProcessor._myComputedProperty[tmpAddress] = newValue
        }
    }
}
