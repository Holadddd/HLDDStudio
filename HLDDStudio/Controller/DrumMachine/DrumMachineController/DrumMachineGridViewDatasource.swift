//
//  DrumMachineGridViewDatasource.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/3.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

extension DrumMachineViewController: GridViewDataSource {
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        let patternCount = DrumMachineManger.manger.pattern.count
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return patternCount
        case drumMachineView.drumBarGridView:
            return 1
        case drumMachineView.drumPatternGridView:
            return patternCount
        default:
            return 0
        }
    }
    
    func numberOfColumns(in gridView: GridView) -> Int {
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return 1
        case drumMachineView.drumBarGridView:
            return DrumMachineScrollSettingInfo.numberOfBeatsInLandScapePage.rawValue
        case drumMachineView.drumPatternGridView:
            return DrumMachineScrollSettingInfo.numberOfBeatsInLandScapePage.rawValue
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        var witdth: CGFloat = 0
        guard let controlW = self.controlW else { fatalError() }
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            let w = drumMachineView.drumEditingGridView.frame.width
            return w
        case drumMachineView.drumBarGridView:
            if DrumMachineManger.manger.isPortrait {
                witdth = (mainW - controlW)/CGFloat(DrumMachineScrollSettingInfo.numberOfBeatsInOneBar.rawValue)
            } else {
                witdth = (mainH - controlW)/CGFloat(DrumMachineScrollSettingInfo.numberOfBeatsInLandScapePage.rawValue)
            }
            
        case drumMachineView.drumPatternGridView:
            if DrumMachineManger.manger.isPortrait {
                witdth = (mainW - controlW)/CGFloat(DrumMachineScrollSettingInfo.numberOfBeatsInOneBar.rawValue)
            } else {
                witdth = (mainH - controlW)/CGFloat(DrumMachineScrollSettingInfo.numberOfBeatsInLandScapePage.rawValue)
            }
        default:
            return 0
        }
        return witdth
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        guard let controlH = self.controlH else { fatalError()}
        switch gridView {
        case drumMachineView.drumEditingGridView:
            if DrumMachineManger.manger.isPortrait {
                height = (mainH - controlH)/4
            } else {
                
                height = (mainW - controlH)/6
            }
        case drumMachineView.drumBarGridView:
            let h = drumMachineView.drumBarGridView.frame.height
            return h
        case drumMachineView.drumPatternGridView:
            if DrumMachineManger.manger.isPortrait {
                height = (mainH - controlH)/4
            } else {
                height = (mainW - controlH)/6
            }
        default:
            return 80
        }
        return height
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            let patterInfo = DrumMachineManger.manger.pattern[indexPath.row]
            var cell = GridViewCell()
            if DrumMachineManger.manger.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingGridViewCell", for: indexPath) as? DrumEditingGridViewCell else { fatalError() }
                
                switch patterInfo.drumType {
                case .classic:
                    vCell.drumType = .classic
                    vCell.typeTextField.text = "Classic"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumClassic), for: .normal)
                case .hihats:
                    vCell.drumType = .hihats
                    vCell.typeTextField.text = "Hi-Hats"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumHihats), for: .normal)
                case .kicks:
                    vCell.drumType = .kicks
                    vCell.typeTextField.text = "Kicks"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumKicks), for: .normal)
                case .percussion:
                    vCell.drumType = .percussion
                    vCell.typeTextField.text = "Percussion"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumPercussion), for: .normal)
                case .snares:
                    vCell.drumType = .snares
                    vCell.typeTextField.text = "Snares"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumSnares), for: .normal)
                }
                
                vCell.panKnob.value = Float(patterInfo.equlizerAndPanner.busPanner.pan)
                vCell.volKnob.value = Float(patterInfo.equlizerAndPanner.busBooster.gain)
                
                vCell.samplePickTextField.text = patterInfo.fileName
                vCell.delegate = self
                cell = vCell
            } else {
                guard let hCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingHorizontalGridViewCell", for: indexPath) as? DrumEditingHorizontalGridViewCell else { fatalError() }
                switch patterInfo.drumType {
                case .classic:
                    hCell.drumType = .classic
                    hCell.samplePlayButton.setImage(UIImage.asset(.drumClassic), for: .normal)
                case .hihats:
                    hCell.drumType = .hihats
                    hCell.samplePlayButton.setImage(UIImage.asset(.drumHihats), for: .normal)
                case .kicks:
                    hCell.drumType = .kicks
                    hCell.samplePlayButton.setImage(UIImage.asset(.drumKicks), for: .normal)
                case .percussion:
                    hCell.drumType = .percussion
                    hCell.samplePlayButton.setImage(UIImage.asset(.drumPercussion), for: .normal)
                case .snares:
                    hCell.drumType = .snares
                    hCell.samplePlayButton.setImage(UIImage.asset(.drumSnares), for: .normal)
                }
                //Use contentOffset adjust value
                hCell.statusBarContentView.translatesAutoresizingMaskIntoConstraints = false
                
                hCell.statusBarContentView.widthAnchor.constraint(equalToConstant: adjustValue).isActive = true
                
                hCell.samplePickTextField.text = patterInfo.fileName
                hCell.delegate = self
                cell = hCell
            }
            
            return cell
        case drumMachineView.drumBarGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumBarGridViewCell", for: indexPath) as? DrumBarGridViewCell else { fatalError() }
            let numberOfBeat = cell.indexPath.column + 1
            switch Int(indexPath.column/4) {
            case 0:
                cell.backgroundColor = UIColor.hexStringToUIColor(hex: DrumMachinePatternBackgroundColor.firstSec.rawValue)
            case 1:
                cell.backgroundColor = UIColor.hexStringToUIColor(hex: DrumMachinePatternBackgroundColor.secondSec.rawValue)
            case 2:
                cell.backgroundColor = UIColor.hexStringToUIColor(hex: DrumMachinePatternBackgroundColor.thirdSec.rawValue)
            case 3:
                cell.backgroundColor = UIColor.hexStringToUIColor(hex: DrumMachinePatternBackgroundColor.fourthSec.rawValue)
            default:
                break
            }
            cell.barLabel.text = "\(numberOfBeat)"
            cell.delegate = self
            return cell
        case drumMachineView.drumPatternGridView:
            var cell = GridViewCell()
            let patterInfo = DrumMachineManger.manger.pattern[indexPath.row]
            if DrumMachineManger.manger.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternGridViewCell", for: indexPath) as?   DrumPatternGridViewCell else { fatalError() }
                
                vCell.selectButton.isSelected = patterInfo.drumBeatPattern.beatPattern[indexPath.column]
                
               
                vCell.delegate = self
                cell = vCell
            } else {
                guard let hCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternHorizontalGridViewCell", for: indexPath) as? DrumPatternHorizontalGridViewCell else { fatalError() }
                
                hCell.selectButton.isSelected = patterInfo.drumBeatPattern.beatPattern[indexPath.column]
                
                hCell.delegate = self
                
                cell = hCell
            }
            
            return cell
            
        default:
            return GridViewCell()
        }
        
    }
    
}
