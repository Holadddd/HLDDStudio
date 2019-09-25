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
        
        drumMachineView.drumBarGridView.delegate = self
        drumMachineView.drumBarGridView.dataSource = self
        
        drumMachineView.drumPatternGridView.delegate = self
        drumMachineView.drumPatternGridView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.createEventWith(category: .DrumMachineController, action: .ViewDidAppear, label: .UsersEvent, value: .one)
        
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
            return 1
        case drumMachineView.drumBarGridView:
            return 2
        case drumMachineView.drumPatternGridView:
            return 3
        default:
            return 0
        }
    }
    
    func numberOfColumns(in gridView: GridView) -> Int {
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return 1
        case drumMachineView.drumBarGridView:
            return 3
        case drumMachineView.drumPatternGridView:
            return 2
        default:
            return 0
        }
    }
    
    func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat {
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            let w = drumMachineView.drumEditingGridView.frame.width
            return w
        case drumMachineView.drumBarGridView:
            
            return DrumPatternFrame.Width
        case drumMachineView.drumPatternGridView:
            print(DrumPatternFrame.Width)
            return DrumPatternFrame.Width
        default:
            return 0
        }
        
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return DrumPatternFrame.Heigh
        case drumMachineView.drumBarGridView:
            let h = drumMachineView.drumBarGridView.frame.height
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
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingGridViewCell", for: indexPath) as? DrumEditingGridViewCell else { fatalError() }
            
            cell.delegate = self
            return cell
        case drumMachineView.drumBarGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumBarGridViewCell", for: indexPath) as? DrumBarGridViewCell else { fatalError() }
            
            cell.delegate = self
            return cell
        case drumMachineView.drumPatternGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternGridViewCell", for: indexPath) as?   DrumPatternGridViewCell else { fatalError() }
            
            cell.delegate = self
            return cell
        default:
            return GridViewCell()
        }
        
    }
    
}

extension DrumMachineViewController: DrumEditingGridViewCellDelegate {

}

extension DrumMachineViewController: DrumBarGridViewCellDelegate {

}

extension DrumMachineViewController: DrumPatternGridViewCellDelegate {

}
