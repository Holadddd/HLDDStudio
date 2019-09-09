//
//  PlugInManager.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/9.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation

struct HLDDStudioPlugIn {
    var plugIn: PlugIn
    var byPass: Bool
}

enum PlugIn {
    case reverb
}
