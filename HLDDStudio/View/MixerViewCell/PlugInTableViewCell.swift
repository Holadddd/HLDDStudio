//
//  PlugInTableViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import MarqueeLabel


protocol PlugInTableViewCellDelegate: AnyObject {
    
    func bypassPlugin(_ cell: PlugInTableViewCell)
}

class PlugInTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plugInLabel: UILabel!
    
    @IBOutlet weak var bypassButton: UIButton!
    
    @IBOutlet weak var plugInMarqueeLabel: MarqueeLabel!
    
    weak var delegate: PlugInTableViewCellDelegate?
    
    static var nib: UINib {
        
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        bypassButton.addTarget(self,
                               action: #selector(PlugInTableViewCell.bypassButtonDidTouch),
                               for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        
        super.setSelected(selected,
                          animated: animated)
    }

    @objc func bypassButtonDidTouch() {
        
        bypassButton.isSelected = !bypassButton.isSelected
        
        delegate?.bypassPlugin(self)
    }
}
