//
//  UIStoryboard+Extension.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

private struct StoryboardCategory {
    
    static let main = "Main"
    
    static let drumMachine = "DrumMachine"
    
}

extension UIStoryboard {
    
    static var main: UIStoryboard { return stStoryboard(name: StoryboardCategory.main) }
    
    static var drumMachine: UIStoryboard { return stStoryboard(name: StoryboardCategory.drumMachine) }
    
    private static func stStoryboard(name: String) -> UIStoryboard {
        
        return UIStoryboard(name: name, bundle: nil)
    }
}
