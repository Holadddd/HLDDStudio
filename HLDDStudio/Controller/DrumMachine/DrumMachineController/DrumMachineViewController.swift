//
//  DrumMachineViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

class DrumMachineViewController: UIViewController {
    
    @IBOutlet var drumMachineView: DrumMachineView!
    
    let mainW = UIScreen.main.bounds.width
    let mainH = UIScreen.main.bounds.height
    
    var controlH: CGFloat?
    var controlW: CGFloat?
    //20 is time heigh same at every iphone.
    let adjustValue = UIApplication.shared.statusBarFrame.height - 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drumMachineView.delegate = self
        drumMachineView.datasource = self
        //DrumEditingGridView
        drumMachineView.drumEditingGridView.delegate = self
        drumMachineView.drumEditingGridView.dataSource = self
        
        drumMachineView.drumBarGridView.delegate = self
        drumMachineView.drumBarGridView.dataSource = self
        
        drumMachineView.drumPatternGridView.delegate = self
        drumMachineView.drumPatternGridView.dataSource = self
        
        controlH = drumMachineView.controlView.bounds.height
        controlW = drumMachineView.controlView.bounds.width
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        FirebaseManager.createEventWith(category: .DrumMachineController, action: .ViewDidAppear, label: .UsersEvent, value: .one)
        
        DrumMachineManger.manger.isPortrait = true
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
        
        drumMachineView.tempoTextField.isEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        //need to stop drumMachine
        DrumMachineManger.manger.stopPlayingDrumMachine()
    }
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        drumMachineView.drumEditingGridView.reloadData()
        drumMachineView.drumBarGridView.reloadData()
        drumMachineView.drumPatternGridView.reloadData()
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        print("viewSafeAreaInsetsDidChange")
    }
}
