//
//  DrumMachineGridViewDelegate.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

extension DrumMachineViewController: GridViewDelegate{
    
    func gridView(_ gridView: GridView,
                  didScaleAt scale: CGFloat) {
        
        switch gridView {
            
        case drumMachineView.drumEditingGridView:
            
            drumMachineView.drumPatternGridView.contentScale(scale)
        case drumMachineView.drumBarGridView:
            
            return
        case drumMachineView.drumPatternGridView:
            
            drumMachineView.drumEditingGridView.contentScale(scale)
            
            drumMachineView.drumBarGridView.contentScale(scale)
        default:
            
            return
        }
        
        drumMachineView.drumBarGridView.contentOffset = CGPoint(x: 0, y: 0)
        
        drumMachineView.drumEditingGridView.contentOffset = CGPoint(x: 0, y: 0)
        
        drumMachineView.drumPatternGridView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func gridView(_ gridView: GridView,
                  didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        switch scrollView {
            
        case drumMachineView.drumEditingGridView:
            
            let x = drumMachineView.drumPatternGridView.contentOffset.x
            
            let y = drumMachineView.drumEditingGridView.contentOffset.y
            
            let offset = CGPoint(x: x, y: y)
            
            drumMachineView.drumPatternGridView.setContentOffset(offset,
                                                                 animated: false)
        case drumMachineView.drumBarGridView:
            
            let x = drumMachineView.drumBarGridView.contentOffset.x
            
            let y = drumMachineView.drumPatternGridView.contentOffset.y
            
            let offset = CGPoint(x: x, y: y)
            
            drumMachineView.drumPatternGridView.setContentOffset(offset,
                                                                 animated: false)
        case drumMachineView.drumPatternGridView:
            
            let x = drumMachineView.drumPatternGridView.contentOffset.x
            
            let y = drumMachineView.drumPatternGridView.contentOffset.y
            
            drumMachineView.drumEditingGridView.setContentOffset(CGPoint(x: 0, y: y),
                                                                 animated: false)
            
            drumMachineView.drumBarGridView.setContentOffset(CGPoint(x: x, y: 0),
                                                             animated: false)
        default:
            
            break
        }
    }
}
