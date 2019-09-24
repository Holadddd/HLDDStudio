//
//  PlugInView.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit
import AudioKit


class PlugInView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var layerView: UIView!
    
    @IBOutlet weak var buttomLayerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(PlugInReverbTableViewCell.nib, forCellReuseIdentifier: "PlugInReverbTableViewCell")
        tableView.register(PlugInGuitarProcessorTableViewCell.nib, forCellReuseIdentifier: "PlugInGuitarProcessorTableViewCell")
        tableView.register(PlugInDelayTableViewCell.nib, forCellReuseIdentifier: "PlugInDelayTableViewCell")
        tableView.register(PlugInChorusTableViewCell.nib, forCellReuseIdentifier: "PlugInChorusTableViewCell")
        
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.frame = layerView.bounds
        topGradientLayer.colors = [UIColor.black.cgColor, UIColor.darkGray.cgColor]
        layerView.layer.addSublayer(topGradientLayer)
        
        let buttomGradientLayer = CAGradientLayer()
        buttomGradientLayer.frame = layerView.bounds
        buttomGradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        buttomLayerView.layer.addSublayer(buttomGradientLayer)
    }
    
}
