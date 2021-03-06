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
    
    func rotateDrumMachineView(isLandscapeRight: Bool,
                               completion:@escaping ()->Void )
    
    func popDrumMachineView()
    
    func playDrum(bpm: Int)
    
    func stopPlayingDrum()
    
    func savePattern(withName: String)
}

protocol DrumMachineDatasource: AnyObject {
    
}

class DrumMachineView: UIView {
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var rotateButton: UIButton!
    
    var tempoArr: [Int] = []
    
    let tempoPicker = UIPickerView()
    
    @IBOutlet weak var tempoTextField: UITextField! {
        
        didSet {
            
            tempoPicker.delegate = self
            
            tempoPicker.dataSource = self
            
            tempoTextField.inputView = tempoPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 28,
                                  height: 28)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                            size: CGSize(width: 28, height: 28)))
            
            view.addSubview(button)
            
            view.isUserInteractionEnabled = false
            
            button.isUserInteractionEnabled = false
            
            tempoTextField.rightView = view
            
            tempoTextField.rightViewMode = .always
            
            tempoTextField.text = "\(DrumMachineManger.manger.bpm)"
            
            tempoTextField.delegate = self
        }
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var playAndStopButton: UIButton!
    
    @IBOutlet weak var drumEditingGridView: GridView!
    
    @IBOutlet weak var drumBarGridView: GridView!
    
    @IBOutlet weak var drumPatternGridView: GridView!
    
    weak var delegate: DrumMachineDelegate?
    
    weak var datasource: DrumMachineDatasource?
    //parameter
    let infinitable = false
    
    let minScale = Scale(x: 1,
                         y: 1)
    
    let maxScale = Scale(x: 1,
                         y: 1)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        //registCell
        drumEditingGridView.register(DrumEditingGridViewCell.nib,
                                     forCellWithReuseIdentifier: String(describing: DrumEditingGridViewCell.self))
        
        drumEditingGridView.register(DrumEditingHorizontalGridViewCell.nib,
                                     forCellWithReuseIdentifier: String(describing: DrumEditingHorizontalGridViewCell.self))
        
        drumBarGridView.register(DrumBarGridViewCell.nib,
                                 forCellWithReuseIdentifier: String(describing: DrumBarGridViewCell.self))
        
        drumPatternGridView.register(DrumPatternGridViewCell.nib,
                                     forCellWithReuseIdentifier: String(describing: DrumPatternGridViewCell.self))
        
        drumPatternGridView.register(DrumPatternHorizontalGridViewCell.nib,
                                     forCellWithReuseIdentifier: String(describing: DrumPatternHorizontalGridViewCell.self))
        //clipBounds
        drumEditingGridView.clipsToBounds = true
        
        drumBarGridView.clipsToBounds = true
        
        drumPatternGridView.clipsToBounds = true
        //bouncesZoom
        drumEditingGridView.bounces = false
        
        drumBarGridView.bounces = false
        
        drumPatternGridView.bounces = false
        //ScrollIndicator
        drumEditingGridView.showsHorizontalScrollIndicator = false
        
        drumEditingGridView.showsVerticalScrollIndicator = false
        
        drumBarGridView.showsHorizontalScrollIndicator = false
        
        drumBarGridView.showsVerticalScrollIndicator = false
        
        drumPatternGridView.showsHorizontalScrollIndicator = false
        
        drumPatternGridView.showsVerticalScrollIndicator = false
        
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
        drumEditingGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                             animated: false)
        
        drumBarGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                         animated: false)
        
        drumPatternGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                             animated: false)
        
        //inSet
        let insets = UIEdgeInsets(top: 0,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        
        drumEditingGridView.contentInset = insets
        
        drumBarGridView.contentInset = insets
        
        drumPatternGridView.contentInset = insets
        
        rotateButton.addTarget(self,
                               action: #selector(DrumMachineView.rotateButtonAction(_:)),
                               for: .touchUpInside)
        
        backButton.addTarget(self,
                             action: #selector(DrumMachineView.backButtonAction(_:)),
                             for: .touchUpInside)
        
        playAndStopButton.addTarget(self,
                                    action: #selector(DrumMachineView.playAndStopButtonAction(_:)),
                                    for: .touchUpInside)
        
        for tempo in 40...240 {
            
            tempoArr.append(tempo)
        }
    }
    
    override func layoutSubviews() {
        
        let offSet = UIEdgeInsets(top: 0,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        
        drumEditingGridView.contentInset = offSet
        
        drumBarGridView.contentInset = offSet
        
        drumPatternGridView.contentInset = offSet
        
        drumEditingGridView.invalidateLayout()
    }
    
    @objc func rotateButtonAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        delegate?.rotateDrumMachineView(isLandscapeRight: sender.isSelected,
                                        completion: { [ weak self ] in
                                            
                                            guard let strongSelf = self
                                                else{ fatalError() }
                                            
                                            DispatchQueue.main.async {
                                                
                                                strongSelf.drumEditingGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                                                                                animated: true)
                                                
                                                strongSelf.drumBarGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                                                                            animated: true)
                                                
                                                strongSelf.drumPatternGridView.setContentOffset(CGPoint(x: 0, y: 0),
                                                                                                animated: true)
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
            
            let bpmString = tempoTextField.text ?? "60"
            
            let bpm = Int(bpmString)
            
            delegate?.playDrum(bpm: bpm ?? 60)
            
            rotateButton.isEnabled = false
            
            tempoTextField.isEnabled = false
            
            drumEditingGridView.superview?.isUserInteractionEnabled = false
            
            drumBarGridView.superview?.isUserInteractionEnabled = false
            
            drumPatternGridView.superview?.isUserInteractionEnabled = false
        case false:
            
            delegate?.stopPlayingDrum()
            
            rotateButton.isEnabled = true
            
            tempoTextField.isEnabled = true
            
            drumEditingGridView.superview?.isUserInteractionEnabled = true
            
            drumBarGridView.superview?.isUserInteractionEnabled = true
            
            drumPatternGridView.superview?.isUserInteractionEnabled = true
        }
    }
    
    @objc func saveButtonAction(_ sender: UIButton) {
        
    }
}

extension DrumMachineView: UITextFieldDelegate {
    
}

extension DrumMachineView: UIPickerViewDelegate {
    
}

extension DrumMachineView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        return tempoArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        pickerView.backgroundColor = UIColor.B1
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.white
        
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let image = UIImageView.init(image: UIImage.asset(.StatusBarLayerView))
        
        pickerLabel.backgroundColor = .clear
        
        image.stickSubView(pickerLabel)
        
        pickerLabel.text = "\(tempoArr[row])"
        
        return image
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        tempoTextField.text = "\(tempoArr[row])"
        
        let bpm = Int(tempoArr[row])
        
        DrumMachineManger.manger.bpm = bpm
    }
}
