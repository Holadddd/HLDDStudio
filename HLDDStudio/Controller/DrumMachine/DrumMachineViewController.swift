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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drumMachineView.delegate = self
        drumMachineView.datasource = self
        //DrumEditingGridView
        drumMachineView.drumEditingGridView.delegate = self
        drumMachineView.drumEditingGridView.dataSource = self
        drumMachineView.drumEditingGridView.register(DrumEditingGridViewCell.nib, forCellWithReuseIdentifier: "DrumEditingGridViewCell")
        //BarGridView
        drumMachineView.barGridView.delegate = self
        drumMachineView.barGridView.dataSource = self
        drumMachineView.barGridView.register(BarGridViewCell.nib, forCellWithReuseIdentifier: "BarGridViewCell")
        
        drumMachineView.drumPatternGridView.delegate = self
        drumMachineView.drumPatternGridView.dataSource = self
        drumMachineView.drumPatternGridView.register(DrumPatternGridViewCell.nib, forCellWithReuseIdentifier: "DrumPatternGridViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
   
    
}

extension DrumMachineViewController: DrumMachineDelegate {
    
    func rotateDrumMachineView(isLandscapeRight: Bool) {
        switch isLandscapeRight {
        case true:
            DispatchQueue.main.async {
                AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
            }
        case false:
            DispatchQueue.main.async {
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            }
        }
    }
    
    func popDrumMachineView() {
        print("popDrumMachineView")
    }
    
    func playDrum() {
        print("playDrum")
    }
    
    func stopPlayingDrum() {
        print("stopPlayingDrum")
    }
    
    func savePattern(withName: String) {
        print("savePattern")
    }
    
}

extension DrumMachineViewController: DrumMachineDatasource {
    
}

extension DrumMachineViewController: GridViewDelegate{
    
}


extension DrumMachineViewController: GridViewDataSource {
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return 0
        case drumMachineView.barGridView:
            return 0
        case drumMachineView.drumPatternGridView:
            return 0
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            let w = drumMachineView.drumEditingGridView.frame.width
            return w
        case drumMachineView.barGridView:
            return DrumPatternFrame.Width
        case drumMachineView.drumPatternGridView:
            return DrumPatternFrame.Width
        default:
            return 0
        }
        
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return DrumPatternFrame.Heigh
        case drumMachineView.barGridView:
            let h = drumMachineView.barGridView.frame.height
            return h
        case drumMachineView.drumPatternGridView:
            return DrumPatternFrame.Heigh
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingGridViewCe;;", for: indexPath) as? DrumEditingGridViewCell else { fatalError()}
            
            cell.delegate = self
            return cell
        case drumMachineView.barGridView:
            
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "BarGridViewCell", for: indexPath) as? BarGridViewCell else { fatalError()}
            
            cell.delegate = self
            return cell
        case drumMachineView.drumPatternGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternGridViewCell", for: indexPath) as? DrumPatternGridViewCell else { fatalError()}
            
            cell.delegate = self
            return cell
        default:
            return GridViewCell()
        }
    }
    
}

extension DrumMachineViewController: DrumEditingGridViewCellDelegate {
    
}

extension DrumMachineViewController: BarGridViewCellDelegate {
    
}

extension DrumMachineViewController: DrumPatternGridViewCellDelegate {
    
}
