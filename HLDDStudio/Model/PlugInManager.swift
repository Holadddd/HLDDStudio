//
//  PlugInManager.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/9.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit


struct HLDDStudioPlugIn {
    var plugIn: PlugIn<AKNode>
    var bypass: Bool
    var sequence: Int
}

//exist plugIn
enum PlugIn<T> {
    
    case reverb(T)
    
}



class PlugInCreater {
    
    static let shared = PlugInCreater()
    
    func plugInProvider(with plugIn: PlugIn<AKNode>) -> AKNode {
        switch plugIn {
        case .reverb:
            return AKReverb()
        }
    }
    
    func providePlugInNode(with HLDD: HLDDStudioPlugIn) -> AKNode {
        let plugIn = HLDD.plugIn
        switch plugIn {
        case .reverb(let reverb):
            return reverb
        }
        
    }
    
}
