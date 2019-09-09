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
    var plugIn: PlugIn
    var byPass: Bool
}
//exist plugIn
enum PlugIn {
    
    case reverb
    
}


class PlugInCreater {
    
    static let shared = PlugInCreater()
    
    func plugInProvider(with plugIn: PlugIn) -> AKNode {
        switch plugIn {
        case .reverb:
            return AKReverb()
        }
    }
}
