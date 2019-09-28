//
//  DrumMachineViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit
import G3GridView

class DrumMachineViewController: UIViewController {
    
    @IBOutlet var drumMachineView: DrumMachineView!
    
    let mainW = UIScreen.main.bounds.width
    let mainH = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drumMachineView.delegate = self
        drumMachineView.datasource = self
        //DrumEditingGridView
        drumMachineView.drumEditingGridView.delegate = self
        drumMachineView.drumEditingGridView.dataSource = self
        
        drumMachineView.drumBarGridView.delegate = self
        drumMachineView.drumBarGridView.dataSource = self
        
        drumMachineView.drumPatternGridView.delegate = self
        drumMachineView.drumPatternGridView.dataSource = self
        
        
        if DrumMachineManger.manger.needDefaultPattern {
            DrumMachineManger.manger.creatPattern(withType: .kicks, fileIndex: 0)
            DrumMachineManger.manger.creatPattern(withType: .snares, fileIndex: 22)
            DrumMachineManger.manger.creatPattern(withType: .hihats, fileIndex: 0)
            DrumMachineManger.manger.creatPattern(withType: .percussion, fileIndex: 19)
            DrumMachineManger.manger.creatPattern(withType: .percussion, fileIndex: 20)
            DrumMachineManger.manger.creatPattern(withType: .percussion, fileIndex: 21)
            //only connect in firstTime
            MixerManger.manger.mixerForMaster.connect(input: DrumMachineManger.manger.drumMixer, bus: 3)
            DrumMachineManger.manger.needDefaultPattern = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        FirebaseManager.createEventWith(category: .DrumMachineController, action: .ViewDidAppear, label: .UsersEvent, value: .one)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //need to stop drumMachine
        DrumMachineManger.manger.stopPlayingDrumMachine()
//        try? AudioKit.stop()
//        MixerManger.manger.mixerForMaster.disconnectInput(bus: 3)
//        try? AudioKit.start()
    }
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        drumMachineView.drumEditingGridView.reloadData()
        drumMachineView.drumBarGridView.reloadData()
        drumMachineView.drumPatternGridView.reloadData()
    }
   
}

extension DrumMachineViewController: DrumMachineDelegate {
    
    func rotateDrumMachineView(isLandscapeRight: Bool, completion: @escaping () -> Void) {
        switch isLandscapeRight {
        case true:
            DispatchQueue.main.async {
                
                AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight, complete: completion)
                
            }
        case false:
            DispatchQueue.main.async {
                
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: completion)
            }
        }
    }
  
    func popDrumMachineView() {
        print("popDrumMachineView")
        dismiss(animated: true, completion: nil)
    }
    
    func playDrum(bpm: Int) {
        DrumMachineManger.manger.bpm = bpm
        DrumMachineManger.manger.playDrumMachine()
    }
    
    func stopPlayingDrum() {
        DrumMachineManger.manger.stopPlayingDrumMachine()
    }
    
    func savePattern(withName: String) {
        print("savePattern")
    }
    
}

extension DrumMachineViewController: DrumMachineDatasource {
    
}

extension DrumMachineViewController: GridViewDelegate{
    func gridView(_ gridView: GridView, didScaleAt scale: CGFloat) {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
        
            drumMachineView.drumPatternGridView.contentScale(scale)
            //drumMachineView.drumEditingGridView.contentOffset = CGPoint(x: 0, y: 0)
            
        case drumMachineView.drumBarGridView:
            return
        case drumMachineView.drumPatternGridView:
            
            drumMachineView.drumEditingGridView.contentScale(scale)
            drumMachineView.drumBarGridView.contentScale(scale)
            //drumMachineView.drumPatternGridView.contentOffset = CGPoint(x: 0, y: 0)
        default:
            return
        }
        drumMachineView.drumBarGridView.contentOffset = CGPoint(x: 0, y: 0)
        drumMachineView.drumEditingGridView.contentOffset = CGPoint(x: 0, y: 0)
        drumMachineView.drumPatternGridView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case drumMachineView.drumEditingGridView:
            let x = drumMachineView.drumPatternGridView.contentOffset.x
            let y = drumMachineView.drumEditingGridView.contentOffset.y
            let offset = CGPoint(x: x, y: y)
            drumMachineView.drumPatternGridView.setContentOffset(offset, animated: false)
        case drumMachineView.drumBarGridView:
            let x = drumMachineView.drumBarGridView.contentOffset.x
            let y = drumMachineView.drumPatternGridView.contentOffset.y
            let offset = CGPoint(x: x, y: y)
            drumMachineView.drumPatternGridView.setContentOffset(offset, animated: false)
        case drumMachineView.drumPatternGridView:
            let x = drumMachineView.drumPatternGridView.contentOffset.x
            let y = drumMachineView.drumPatternGridView.contentOffset.y
            drumMachineView.drumEditingGridView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            drumMachineView.drumBarGridView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        
        default:
            print("")
        }
    }
    
}


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
            return 16
        case drumMachineView.drumPatternGridView:
            return 16
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        var witdth: CGFloat = 0
        let controlW = drumMachineView.controlView.bounds.width
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            let w = drumMachineView.drumEditingGridView.frame.width
            return w
        case drumMachineView.drumBarGridView:
            if UIDevice.current.orientation.isPortrait {
                witdth = (mainW - controlW)/4
            } else {
                witdth = (mainH - controlW)/16.1
            }
            
        case drumMachineView.drumPatternGridView:
            if UIDevice.current.orientation.isPortrait {
                witdth = (mainW - controlW)/4
            } else {
                witdth = (mainH - controlW)/16.1
            }
        default:
            return 0
        }
        return witdth
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let controlH = drumMachineView.controlView.bounds.height
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            if UIDevice.current.orientation.isPortrait {
                height = (mainH - controlH)/3
            } else {
                
                height = (mainW - controlH)/6
            }
        case drumMachineView.drumBarGridView:
            let h = drumMachineView.drumBarGridView.frame.height
            return h
        case drumMachineView.drumPatternGridView:
            if UIDevice.current.orientation.isPortrait {
                height = (mainH - controlH)/3
            } else {
                height = (mainW - controlH)/6
            }
        default:
            return 80
        }
        return height
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        let patterInfo = DrumMachineManger.manger.pattern[indexPath.row]
        switch gridView {
        case drumMachineView.drumEditingGridView:
            
            var cell = GridViewCell()
            if UIDevice.current.orientation.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingGridViewCell", for: indexPath) as? DrumEditingGridViewCell else { fatalError() }
                
                switch patterInfo.drumType {
                case .classic:
                    vCell.drumType = .classic
                    vCell.typeLabel.text = "Classic"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumClassic), for: .normal)
                case .hihats:
                    vCell.drumType = .hihats
                    vCell.typeLabel.text = "Hi-Hats"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumHihats), for: .normal)
                case .kicks:
                    vCell.drumType = .kicks
                    vCell.typeLabel.text = "Kicks"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumKicks), for: .normal)
                case .percussion:
                    vCell.drumType = .percussion
                    vCell.typeLabel.text = "Percussion"
                    vCell.samplePlayButton.setImage(UIImage.asset(.drumPercussion), for: .normal)
                case .snares:
                    vCell.drumType = .snares
                    vCell.typeLabel.text = "Snares"
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
                
                hCell.samplePickTextField.text = patterInfo.fileName
                hCell.delegate = self
                cell = hCell
            }
            
            return cell
        case drumMachineView.drumBarGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumBarGridViewCell", for: indexPath) as? DrumBarGridViewCell else { fatalError() }
            let numberOfBeat = cell.indexPath.column + 1
            switch cell.indexPath.column % 4 {
            case 0:
                cell.firstLabel.text = "\(numberOfBeat)"
                cell.secondLabel.text = ""
                cell.thirdLabel.text = ""
                cell.fourthLabel.text = ""
            case 1:
                cell.firstLabel.text = ""
                cell.secondLabel.text = "\(numberOfBeat)"
                cell.thirdLabel.text = ""
                cell.fourthLabel.text = ""
            case 2:
                cell.firstLabel.text = ""
                cell.secondLabel.text = ""
                cell.thirdLabel.text = "\(numberOfBeat)"
                cell.fourthLabel.text = ""
            case 3:
                cell.firstLabel.text = ""
                cell.secondLabel.text = ""
                cell.thirdLabel.text = ""
                cell.fourthLabel.text = "\(numberOfBeat)"
            default:
                print("pass")
            }
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
                cell.backgroundColor = .blue
            }
            cell.delegate = self
            return cell
        case drumMachineView.drumPatternGridView:
            var cell = GridViewCell()
            if UIDevice.current.orientation.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternGridViewCell", for: indexPath) as?   DrumPatternGridViewCell else { fatalError() }
                
                vCell.selectButton.isSelected = patterInfo.drumBeatPattern.beatPattern[indexPath.column]
                vCell.drumLabel.text = "\(indexPath)"
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

extension DrumMachineViewController: DrumEditingGridViewCellDelegate {
    
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
    
    func patternSelecte(cell: GridViewCell, isSelected: Bool) {
        let indexPath = cell.indexPath
        
        DrumMachineManger.manger.pattern[indexPath.row].drumBeatPattern.beatPattern[indexPath.column] = isSelected
    }

}

extension DrumMachineViewController{
    
    
}

