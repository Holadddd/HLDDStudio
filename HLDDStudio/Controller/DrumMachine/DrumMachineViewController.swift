//
//  DrumMachineViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class DrumMachineViewController: UIViewController {
    
    @IBOutlet var drumMachineView: DrumMachineView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drumMachineView.delegate = self
        drumMachineView.datasource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
   
    
}

extension DrumMachineViewController: DrumMachineDelegate {
    
    func rotateDrumMachineView(isLandscapeRight: Bool) {
        switch isLandscapeRight {
        case true:
            DispatchQueue.main.async {
                AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
            }
        case false:
            DispatchQueue.main.async {
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            }
        }
    }
    
    func popDrumMachineView() {
        print("popDrumMachineView")
    }
    
    func playDrum() {
        print("playDrum")
    }
    
    func stopPlayingDrum() {
        print("stopPlayingDrum")
    }
    
    func savePattern(withName: String) {
        print("savePattern")
    }
    
    
}

extension DrumMachineViewController: DrumMachineDatasource {
    
}
