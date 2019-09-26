//
//  DrumMachineView.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import G3GridView

protocol DrumMachineDelegate: AnyObject {
    func rotateDrumMachineView(isLandscapeRight: Bool, completion:@escaping ()->Void )
    
    func popDrumMachineView()
    
    func playDrum()
    
    func stopPlayingDrum()
    
    func savePattern(withName: String)
}

protocol DrumMachineDatasource: AnyObject {
    
}

class DrumMachineView: UIView {
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var rotateButton: UIButton!
    
    @IBOutlet weak var patternNameTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var playAndStopButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
  
    @IBOutlet weak var drumEditingGridView: GridView!
    
    @IBOutlet weak var drumBarGridView: GridView!
    
    @IBOutlet weak var drumPatternGridView: GridView!
    
    weak var delegate: DrumMachineDelegate?
    
    weak var datasource: DrumMachineDatasource?
    //parameter
    let infinitable = false
    
    let minScale = Scale(x: 1, y: 1)
    
    let maxScale = Scale(x: 1, y: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //registCell
        drumEditingGridView.register(DrumEditingGridViewCell.nib, forCellWithReuseIdentifier: "DrumEditingGridViewCell")
        drumEditingGridView.register(DrumEditingHorizontalGridViewCell.nib, forCellWithReuseIdentifier: "DrumEditingHorizontalGridViewCell")
        drumBarGridView.register(DrumBarGridViewCell.nib, forCellWithReuseIdentifier: "DrumBarGridViewCell")
        drumPatternGridView.register(DrumPatternGridViewCell.nib, forCellWithReuseIdentifier: "DrumPatternGridViewCell")
        drumPatternGridView.register(DrumPatternHorizontalGridViewCell.nib, forCellWithReuseIdentifier: "DrumPatternHorizontalGridViewCell")
        //clipBounds
        drumEditingGridView.clipsToBounds = true
        drumBarGridView.clipsToBounds = true
        drumPatternGridView.clipsToBounds = true
        //bouncesZoom
        drumEditingGridView.bounces = false
        drumBarGridView.bounces = false
        drumPatternGridView.bounces = false
        
        drumEditingGridView.minimumZoomScale = 1
        drumBarGridView.minimumZoomScale = 1
        drumPatternGridView.minimumZoomScale = 1
        
        //loop(false)
        drumEditingGridView.isInfinitable = infinitable
        drumBarGridView.isInfinitable = infinitable
        drumPatternGridView.isInfinitable = infinitable
        //drumPatternGridViewScale
        drumPatternGridView.minimumScale = minScale
        drumPatternGridView.maximumScale = maxScale
        //drumEditingGridViewScale
        drumEditingGridView.minimumScale.y = drumPatternGridView.minimumScale.y
        drumEditingGridView.maximumScale.y = drumPatternGridView.maximumScale.y
        //drumBarGridViewScale
        drumBarGridView.minimumScale.x = drumPatternGridView.minimumScale.x
        drumBarGridView.maximumScale.x = drumPatternGridView.maximumScale.x
        
        //contentInset
        drumPatternGridView.contentInset.top = 0
        
        drumPatternGridView.scrollIndicatorInsets.top = 0
        drumPatternGridView.scrollIndicatorInsets.left = drumEditingGridView.bounds.width
        
        drumEditingGridView.contentInset.top = 0
        
        //scroll
        drumEditingGridView.superview?.isUserInteractionEnabled = true
        drumBarGridView.superview?.isUserInteractionEnabled = true
        drumPatternGridView.superview?.isUserInteractionEnabled = true
        
        //in
        drumEditingGridView.layoutWithoutFillForCell = true
        drumBarGridView.layoutWithoutFillForCell = true
        drumPatternGridView.layoutWithoutFillForCell = true
        
        //offset
        drumEditingGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        drumBarGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        drumPatternGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        rotateButton.addTarget(self, action: #selector(DrumMachineView.rotateButtonAction(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(DrumMachineView.backButtonAction(_:)), for: .touchUpInside)
        playAndStopButton.addTarget(self, action: #selector(DrumMachineView.playAndStopButtonAction(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(DrumMachineView.saveButtonAction(_:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        drumEditingGridView.frame.origin = CGPoint(x: 0, y: 0)
        
    }
    
    @objc func rotateButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.rotateDrumMachineView(isLandscapeRight: sender.isSelected, completion: {[weak self] in
            guard let strongSelf = self else{fatalError()}
            DispatchQueue.main.async {
                strongSelf.drumEditingGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                strongSelf.drumBarGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                strongSelf.drumPatternGridView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                //SetReloadData At VC viewWillTransition
                print("setContentOffset gridview.")
            }
        })
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
            drumEditingGridView.superview?.isUserInteractionEnabled = false
            drumBarGridView.superview?.isUserInteractionEnabled = false
            drumPatternGridView.superview?.isUserInteractionEnabled = false
        case false:
            delegate?.stopPlayingDrum()
            rotateButton.isEnabled = true
            drumEditingGridView.superview?.isUserInteractionEnabled = true
            drumBarGridView.superview?.isUserInteractionEnabled = true
            drumPatternGridView.superview?.isUserInteractionEnabled = true
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
