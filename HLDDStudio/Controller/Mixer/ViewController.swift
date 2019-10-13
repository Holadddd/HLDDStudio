//
//  ViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import Foundation
import G3GridView
import AVKit
import AudioKit
import Firebase
import Crashlytics

class ViewController: UIViewController {
    
    var bufferTime: Double = 2.0
    
//    var filePlayer = AKPlayer()
//    
//    var filePlayerTwo = AKPlayer()
//    
    @IBOutlet var mixerView: MixerView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mixerView.delegate = self
        
        mixerView.datasource = self
        
        mixerView.trackGridView.delegate = self
        
        mixerView.trackGridView.dataSource = self
        
        MixerManger.manger.metronomeBooster.gain = 0
        
        MixerManger.manger.mixerForMaster.connect(input: MixerManger.manger.mixer,
                                                  bus: 1)
        
        MixerManger.manger.mixerForMaster.connect(input: MixerManger.manger.metronomeBooster,
                                                  bus: 0)
        
        AudioKit.output = MixerManger.manger.mixerForMaster
        //MakeTwoTrackNode
        for (index, _) in PlugInManager.shared.plugInOntruck.enumerated() {
            
            PlugInManager.shared.plugInOntruck[index].inputNode = AKPlayer()
            
            MixerManger.manger.mixer.connect(input: PlugInManager.shared.plugInOntruck[index].inputNode,
                                             bus: index + 1)
        }
        
        for (index, _) in PlugInManager.shared.plugInOntruck.enumerated() {
            setTrackNode(track: index + 1)
        }
        
        try? AudioKit.start()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.notificationTitleChange),
                                               name: .mixerNotificationTitleChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.notificationSubTitleChange),
                                               name: .mixerNotificationSubTitleChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.notificationBarTitleChange),
                                               name: .mixerBarTitleChange,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        FirebaseManager.createEventWith(category: .ViewController,
                                        action: .ViewDidAppear,
                                        label: .UsersEvent,
                                        value: .one)
        
        AppUtility.lockOrientation(.portrait,
                                   andRotateTo: .portrait,
                                   complete: nil)
        
        MixerManger.manger.title(with: .HLDDStudio)
        
        MixerManger.manger.subTitle(with: .selectInputDevice)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        mixerView.inputDeviceTextField.text = AudioKit.inputDevice?.deviceID
    }
    
    override func viewWillLayoutSubviews() {
        
        mixerView.masterFader.layoutSubviews()
    }
    
    func setTrackNode(track: Int) {
        
        try? AudioKit.stop()
        
        MixerManger.manger.mixer.disconnectInput(bus: track)
        
        PlugInManager.shared.resetTrackNode(Track: track)
        
        PlugInManager.shared.resetTrack(track: track)
        
        MixerManger.manger.mixer.connect(input: PlugInManager.shared.plugInOntruck[track - 1].node,
                                         bus: track)
        
        try? AudioKit.start()
    }
    
    @objc func notificationTitleChange(_ notification: Notification){
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self else { return }
            
            MixerManger.manger.title(with: .HLDDStudio)
            
            strongSelf.mixerView.notificationTitleLabel.text = MixerManger.manger.titleContent
        }
    }
    
    @objc func notificationSubTitleChange(_ notification: Notification){
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self else { return }
            
            MixerManger.manger.title(with: .HLDDStudio)
            
            strongSelf.mixerView.notificationSubTitleLabel.text = MixerManger.manger.subTitleContent
        }
    }
    
    @objc func notificationBarTitleChange(_ notification: Notification) {
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.mixerView.barLabel.text = "\(MixerManger.manger.bar) | \((MixerManger.manger.beat % 4) + 1 )"
        }
    }
}

extension ViewController {
    
    func enabledMixerFunctionalButton(){
        
        MixerManger.manger.isenabledMixerFunctionalButton = true
        
        DispatchQueue.main.async { [weak self] in
            
            guard let stromgSelf = self else { fatalError() }
            
            stromgSelf.mixerView.tempoTextField.isEnabled = true
            
            stromgSelf.mixerView.startRecordTextField.isEnabled = true
            
            stromgSelf.mixerView.stopRecordTextField.isEnabled = true
            
            NotificationCenter.default.post(.init(name: .enabledIOButton))
        }
    }
    
    func disabledMixerFunctionalButton(){
        
        MixerManger.manger.isenabledMixerFunctionalButton = false
        
        DispatchQueue.main.async { [ weak self ] in
            
            guard let stromgSelf = self else { fatalError() }
            
            stromgSelf.mixerView.tempoTextField.isEnabled = false
            
            stromgSelf.mixerView.startRecordTextField.isEnabled = false
            
            stromgSelf.mixerView.stopRecordTextField.isEnabled = false
            
            NotificationCenter.default.post(.init(name: .disabledIOButton))
        }
    }
}

extension ViewController {
    //Here
    func plugInProvide(row: Int,
                       column: Int,
                       plugIn: PlugIn) {
        let busOnMixer = column + 1
        
        let trackSeq = column + 1
        
        try? AudioKit.stop()
        
        switch plugIn {
            
        case .reverb:
            
            MixerManger.manger.mixer.disconnectInput(
                bus: busOnMixer)
            
            PlugInManager.shared.plugInOntruck[column].plugInArr.append(
                HLDDStudioPlugIn(plugIn: .reverb(AKReverb( PlugInManager.shared.plugInOntruck[column].node)),
                                 bypass: false,
                                 sequence: row))
            
        case .guitarProcessor:
            
            MixerManger.manger.mixer.disconnectInput(
                bus: busOnMixer)
            
            PlugInManager.shared.plugInOntruck[column].plugInArr.append(
                HLDDStudioPlugIn(
                    plugIn: .guitarProcessor(
                        AKRhinoGuitarProcessor(
                            PlugInManager.shared.plugInOntruck[column].node)),
                    bypass: false,
                    sequence: row)
            )
        case .delay:
            
            MixerManger.manger.mixer.disconnectInput(bus: busOnMixer)
            
            PlugInManager.shared.plugInOntruck[column].plugInArr.append(
                HLDDStudioPlugIn(
                    plugIn: .delay(
                        AKDelay(
                            PlugInManager.shared.plugInOntruck[column].node)),
                    bypass: false,
                    sequence: row))
        case .chorus:
            
            MixerManger.manger.mixer.disconnectInput(bus: busOnMixer)
            
            PlugInManager.shared.plugInOntruck[column].plugInArr.append(
                HLDDStudioPlugIn(
                    plugIn: .chorus(AKChorus(PlugInManager.shared.plugInOntruck[column].node)),
                    bypass: false,
                    sequence: row))
        }
        
        PlugInManager.shared.resetTrackNode(Track: trackSeq)
        
        setTrackNode(track: trackSeq)
    }
}
