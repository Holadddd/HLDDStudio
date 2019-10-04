//
//  DrumMachineDelegate.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

extension DrumMachineViewController: DrumMachineDelegate {
    
    func rotateDrumMachineView(isLandscapeRight: Bool,
                               completion: @escaping () -> Void) {
        
        switch isLandscapeRight {
            
        case true:
            
            DispatchQueue.main.async {
                
                DrumMachineManger.manger.isPortrait = false
                
                AppUtility.lockOrientation(.landscapeRight,
                                           andRotateTo: .landscapeRight) {
                                            
                }
            }
        case false:
            
            DispatchQueue.main.async {
                
                DrumMachineManger.manger.isPortrait = true
                
                AppUtility.lockOrientation(.portrait,
                                           andRotateTo: .portrait) {
                                            
                }
            }
        }
    }
    
    func popDrumMachineView() {
        
        dismiss(animated: true,
                completion: nil)
    }
    
    func playDrum(bpm: Int) {
        
        DrumMachineManger.manger.bpm = bpm
        
        DrumMachineManger.manger.playDrumMachine()
    }
    
    func stopPlayingDrum() {
        
        DrumMachineManger.manger.stopPlayingDrumMachine()
    }
    
    func savePattern(withName: String) {
        
    }
}
