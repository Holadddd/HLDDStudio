//
//  DrumMachineView.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol DrumMachineDelegate: AnyObject {
    func rotateDrumMachineView(isLandscapeRight: Bool)
    
    func popDrumMachineView()
    
    func playDrum()
    
    func stopPlayingDrum()
    
    func savePattern(withName: String)
}

protocol DrumMachineDatasource: AnyObject {
    
}

class DrumMachineView: UIView {
    
    @IBOutlet weak var rotateButton: UIButton!
    
    @IBOutlet weak var patternNameTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var playAndStopButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: DrumMachineDelegate?
    
    weak var datasource: DrumMachineDatasource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rotateButton.addTarget(self, action: #selector(DrumMachineView.rotateButtonAction(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(DrumMachineView.backButtonAction(_:)), for: .touchUpInside)
        
        playAndStopButton.addTarget(self, action: #selector(DrumMachineView.playAndStopButtonAction(_:)), for: .touchUpInside)
        
        saveButton.addTarget(self, action: #selector(DrumMachineView.saveButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func rotateButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.rotateDrumMachineView(isLandscapeRight: sender.isSelected)
    }
    
    @objc func backButtonAction(_ sender:UIButton){
        delegate?.popDrumMachineView()
    }
    
    @objc func playAndStopButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            delegate?.playDrum()
            rotateButton.isEnabled = false
        case false:
            delegate?.stopPlayingDrum()
            rotateButton.isEnabled = true
        }
        
    }
    
    @objc func saveButtonAction(_ sender: UIButton) {
        guard let fileName = patternNameTextField.text else{ return }
        guard fileName != "" else{ return }
        //Save and clean
        delegate?.savePattern(withName: fileName)
        patternNameTextField.text = nil
    }
}
