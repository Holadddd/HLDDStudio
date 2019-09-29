//
//  DrumPatternGridViewCell.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/9/25.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit

protocol DrumPatternGridViewCellDelegate: AnyObject {
    
    func patternSelecte(cell: GridViewCell, isSelected: Bool)
    
}
class DrumPatternGridViewCell: GridViewCell {
    
    @IBOutlet weak var drumLabel: UILabel!
    
    @IBOutlet weak var animateView: UIView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    weak var delegate: DrumPatternGridViewCellDelegate?
    
    
    static var nib: UINib {
        return UINib(nibName: "DrumPatternGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        selectButton.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(drumPatternAnimation), name:.drumMachinePatternAnimation, object: nil)
        
        
    }
    
    @objc func selectButtonAction() {
        selectButton.isSelected = !selectButton.isSelected
        switch selectButton.isSelected {
        case true:
            animateView.backgroundColor = .blue
        case false:
            animateView.backgroundColor = .white
        }
        delegate?.patternSelecte(cell: self, isSelected: selectButton.isSelected)
    }
    
    @objc func drumPatternAnimation(_ notification: Notification){
        guard let info = notification.object as? DrumMachinePatternAnimationInfo else{ fatalError() }
        
        if info.indexPath == self.indexPath{
            
            let dispatchTime = DispatchTime(uptimeNanoseconds: info.startTime.audioTimeStamp.mHostTime)
            
            let animate = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
                self.animateView.backgroundColor = .blue
                //self.selectButton.backgroundColor = .blue
            }
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                //self.selectButton.backgroundColor = .yellow
                self.animateView.backgroundColor = .yellow
                animate.startAnimation()
            }
        }
    }
}
