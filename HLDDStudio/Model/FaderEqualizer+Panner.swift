//
//  FaderEqualizer.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import AudioKit
import UIKit


class FaderEqualizerAndPanner {
    
    var busPanner: AKPanner!
    
    var busLowEQ: AKEqualizerFilter!
    
    var busMidEQ: AKEqualizerFilter!
    
    var busHighEQ: AKEqualizerFilter!
    
    var busBooster: AKBooster!
    
    init(node: AKNode) {
        let node = PlugInCreater.shared.plugInOntruck[0].node
        busPanner = AKPanner(node, pan: 0)
        busLowEQ = AKEqualizerFilter(busPanner, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
        busMidEQ = AKEqualizerFilter(busLowEQ, centerFrequency: 2_000, bandwidth: 2_282, gain: 1.0)
        busHighEQ = AKEqualizerFilter(busMidEQ, centerFrequency: 12_000, bandwidth: 8_112, gain: 1.0)
        busBooster = AKBooster(busHighEQ, gain: 1)
    }
    
}
