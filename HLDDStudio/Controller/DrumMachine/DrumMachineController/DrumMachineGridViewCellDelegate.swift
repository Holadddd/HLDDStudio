//
//  DrumMachineGridViewCellDelegate.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

extension DrumMachineViewController: DrumEditingGridViewCellDelegate {
    func changDrumType(cell: GridViewCell, drumType: DrumType) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.changeDrumType(atRow: row, drumType: drumType)
    }
    
    func deletDrumPattern(cell: GridViewCell) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.removeDrumPattern(atRow: row)
        
    }
    
    
    func panValueChange(cell: GridViewCell, value: Float) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.pattern[row].equlizerAndPanner.busPanner.pan = Double(value)
        print(DrumMachineManger.manger.pattern[row].equlizerAndPanner.busPanner.pan)
    }
    
    func volumeValueChange(cell: GridViewCell, value: Float) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.pattern[row].equlizerAndPanner.busBooster.gain = Double(value)
    }
    
    
    func playSample(cell: GridViewCell) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.pattern[row].filePlayer.play()
    }
    
    func changeDrumSample(cell: GridViewCell, drumType: DrumType, sampleIndex: Int) {
        let row = cell.indexPath.row
        DrumMachineManger.manger.changeDrumSample(atRow: row, withType: drumType, fileIndex: sampleIndex)
    }
}

extension DrumMachineViewController: DrumBarGridViewCellDelegate {
    
}

extension DrumMachineViewController: DrumPatternGridViewCellDelegate {
    
    func patternSelected(cell: GridViewCell, isSelected: Bool) {
        let indexPath = cell.indexPath
        
        DrumMachineManger.manger.pattern[indexPath.row].drumBeatPattern.beatPattern[indexPath.column] = isSelected
    }

}
