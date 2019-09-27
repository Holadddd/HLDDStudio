//
//  UserManualView.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/27.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol UserManualViewDelegate: AnyObject {
    
    func animation()
    
    func recoverAnimate()
}

class UserManualView: UIView {
    
    @IBOutlet weak var TitelLabel: UILabel!
    
    @IBOutlet weak var DeviceInputPickerImage: UIImageView!
    
    @IBOutlet weak var RoutePickerImage: UIImageView!
    
    @IBOutlet weak var MetronomeImage: UIImageView!
    
    @IBOutlet weak var StopButtonImage: UIImageView!
    
    @IBOutlet weak var PlayAndPauseButtonImage: UIImageView!
    
    @IBOutlet weak var RecordButtonImage: UIImageView!
    
    @IBOutlet weak var RecordRegionSelectorImage: UIImageView!
    
    @IBOutlet weak var TempoDigitalDisplayImage: UIImageView!
    
    @IBOutlet weak var InformationDigitalDisplayImage: UIImageView!
    
    @IBOutlet weak var  DeviceInputPickerLabelView: UIView!
    
    @IBOutlet weak var  RoutePickerLabelView: UIView!
    
    @IBOutlet weak var  MetronomeLabelView: UIView!
    
    @IBOutlet weak var  StopButtonLabelView: UIView!
    
    @IBOutlet weak var  PlayAndPauseButtonLabelView: UIView!
    
    @IBOutlet weak var  RecordButtonLabelView: UIView!
    
    @IBOutlet weak var  RecordRegionSelectorLabelView: UIView!
    
    @IBOutlet weak var  TempoDigitalDisplayLabelView: UIView!
    
    @IBOutlet weak var  InformationDigitalDisplayLabelView: UIView!
    
    var imageArr:[UIImageView] = []
    
    var labelViewArr:[UIView] = []
    
    @IBAction func animationButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            delegate?.animation()
        } else {
            delegate?.recoverAnimate()
//            self.translatesAutoresizingMaskIntoConstraints = false
//            self.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    weak var delegate: UserManualViewDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        imageArr.append(DeviceInputPickerImage)
        imageArr.append(RoutePickerImage)
        imageArr.append(MetronomeImage)
        imageArr.append(StopButtonImage)
        imageArr.append(PlayAndPauseButtonImage)
        imageArr.append(RecordButtonImage)
        imageArr.append(RecordRegionSelectorImage)
        imageArr.append(TempoDigitalDisplayImage)
        imageArr.append(InformationDigitalDisplayImage)
        
        labelViewArr.append(DeviceInputPickerLabelView)
        labelViewArr.append(RoutePickerLabelView)
        labelViewArr.append(MetronomeLabelView)
        labelViewArr.append(StopButtonLabelView)
        labelViewArr.append(PlayAndPauseButtonLabelView)
        labelViewArr.append(RecordButtonLabelView)
        labelViewArr.append(RecordRegionSelectorLabelView)
        labelViewArr.append(TempoDigitalDisplayLabelView)
        labelViewArr.append(InformationDigitalDisplayLabelView)
        
    }
}
