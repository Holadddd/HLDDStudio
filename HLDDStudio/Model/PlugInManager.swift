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
    var name: String
    var plugInArr: [HLDDStudioPlugIn]
    var inputNode: AKNode
    var node: AKNode
    var bus: Int
    var pan: Double
    var low: Double
    var mid: Double
    var high: Double
    var volume: Double
}

struct HLDDStudioPlugIn {
    var plugIn: PlugIn
    var bypass: Bool
    var sequence: Int
}

//exist plugIn
let existPlugInArr = ["Reverb", "GuitarProcessor" , "Delay", "Chorus"]
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
            self = .reverb(newReverb)
            
        case let .guitarProcessor(guitarProcessor):
            
            let newRhinoGuitarProcessor = AKRhinoGuitarProcessor(node, preGain: guitarProcessor.HLDDPreGain, postGain: guitarProcessor.postGain, lowGain: -0.5, midGain: -0.5, highGain: -0.5, distortion: guitarProcessor.distortion)
            
            
            self = .guitarProcessor(newRhinoGuitarProcessor)
        case .delay(let delay):
            let newDelay = AKDelay(node, time: delay.time, feedback: delay.feedback, lowPassCutoff: 22_050, dryWetMix: delay.dryWetMix)
            self = .delay(newDelay)
        case .chorus(let chorus):
            let newChorus = AKChorus(node, frequency: chorus.frequency, depth: chorus.depth, feedback: chorus.frequency, dryWetMix: chorus.dryWetMix)
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
    
    var plugInOntruck: [HLDDMixerTrack] = [HLDDMixerTrack(name: "BUS1", plugInArr: [], inputNode: AKNode(), node: AKNode(), bus: 1, pan: 0, low: 0, mid: 0, high: 0, volume: 1),
                                           HLDDMixerTrack(name: "BUS2", plugInArr: [], inputNode: AKNode(), node: AKNode(), bus: 2, pan: 0, low: 0, mid: 0, high: 0, volume: 1)] {
        didSet {
            
            
            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: IndexPath(row: eventRow, column: eventColumn), userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: self, userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didRemovePlugIn, object: self, userInfo: nil))
        }
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
                        for seq in 0 ..< numberOfPlugIn{
                let lastNode = PlugInCreater.shared.plugInOntruck[Track - 1].node
                
                PlugInCreater.shared.plugInOntruck[Track - 1].plugInArr[seq].plugIn.replaceInputNodeInPlugIn(node: lastNode)
                
                PlugInCreater.shared.plugInOntruck[Track - 1].node = PlugInCreater.shared.providePlugInNode(with: plugInOntruck[Track - 1].plugInArr[seq])
            }
            
        }
        
        try? AudioKit.start()
//        plugInOntruck[column].node = providePlugInNode(with: plugInOntruck[column].plugInArr[numberOfPlugIn - 1])
    }
    
    func deletePlugInOnTrack(_ track: Int, seq: Int) {
        try? AudioKit.stop()
        let column = track - 1
        PlugInCreater.shared.plugInOntruck[column].plugInArr.remove(at: seq)
        
        PlugInCreater.shared.resetTrackNode(Track: track)
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
            print("factoryset")
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
            print("factoryset")
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
            print("factoryset")
        }
    }
}
