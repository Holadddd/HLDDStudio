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
let existPlugInArr = ["REVERB", "REVERB2 REVERB2", "REVERB3 REVERB3 REVERB3", "REVERB4"]
enum PlugIn {
    
    case reverb(AKReverb)
    
    var neededInfo: AnyObject {
        switch self {
        case .reverb:
            return ReverNeededInfo(factory: "Cathedral") as AnyObject
        }
    }
    
    mutating func replaceInputNodeInPlugIn(node: AKNode)  {
        switch self {
        case let .reverb(reverb):
            let newReverb = AKReverb(node, dryWetMix: reverb.dryWetMix)
            guard let rawValue = reverbFactory.firstIndex(of: reverb.factory) else { fatalError() }
            guard let set = AVAudioUnitReverbPreset(rawValue: rawValue) else { fatalError() }
            newReverb.loadFactoryPreset(set)
            self = .reverb(newReverb)
            
        }
    }
}

struct ReverNeededInfo {
    var factory: String
}



class PlugInCreater {
    
    static let shared = PlugInCreater()
    
    var eventRow = 0
    
    var eventColumn = 0
    
    var showingTrackOnPlugInVC = 0
    
    var plugInOntruck: [HLDDMixerTrack] = [HLDDMixerTrack(name: "BUS1", plugInArr: [], node: AKNode(), bus: 1, pan: 0, low: 0, mid: 0, high: 0, volume: 1),
                                           HLDDMixerTrack(name: "BUS2", plugInArr: [], node: AKNode(), bus: 2, pan: 0, low: 0, mid: 0, high: 0, volume: 1)] {
        didSet {
            
            
            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: IndexPath(row: eventRow, column: eventColumn), userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: self, userInfo: nil))
//            NotificationCenter.default.post(.init(name: .didRemovePlugIn, object: self, userInfo: nil))
        }
    }
    
//    func plugInProvider(with plugIn: PlugIn<AKNode>) -> AKNode {
//        switch plugIn {
//        case .reverb:
//            return AKReverb()
//        }
//    }
    
    func providePlugInNode(with HLDD: HLDDStudioPlugIn) -> AKNode {
        let plugIn = HLDD.plugIn
        switch plugIn {
        case .reverb(let reverb):
            return reverb
        }
    }
    
    func resetTrackNode(column: Int) {
        
        try? AudioKit.stop()
        let numberOfPlugIn = plugInOntruck[column].plugInArr.count
        for seq in 0 ..< numberOfPlugIn{
            let lastNode = PlugInCreater.shared.plugInOntruck[column].node
            var plugIn = PlugInCreater.shared.plugInOntruck[column].plugInArr[seq].plugIn
            plugIn.replaceInputNodeInPlugIn(node: lastNode)
            PlugInCreater.shared.plugInOntruck[column].node = providePlugInNode(with: plugInOntruck[column].plugInArr[seq])
        }
        try? AudioKit.start()
//        plugInOntruck[column].node = providePlugInNode(with: plugInOntruck[column].plugInArr[numberOfPlugIn - 1])
    }
    
}
//extensionAKReverbFactoryProperty
let reverbFactory = ["Cathedral", "Large Hall", "Large Hall 2",
                     "Large Room", "Large Room 2", "Medium Chamber",
                     "Medium Hall", "Medium Hall 2", "Medium Hall 3",
                     "Medium Room", "Plate", "Small Room"]
extension AKReverb {
    
    struct Default {
        static var factory: String = "Cathedral"
    }
    var factory: String {
        get{
            return Default.factory
        }
        set(newFactory){
            Default.factory = newFactory
        }
        
    }
}

