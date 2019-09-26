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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.createEventWith(category: .DrumMachineController, action: .ViewDidAppear, label: .UsersEvent, value: .one)
    
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        switch gridView {
        case drumMachineView.drumEditingGridView:
            return 10
        case drumMachineView.drumBarGridView:
            return 1
        case drumMachineView.drumPatternGridView:
            return 10
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
        switch gridView {
        case drumMachineView.drumEditingGridView:
            var cell = GridViewCell()
            if UIDevice.current.orientation.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingGridViewCell", for: indexPath) as? DrumEditingGridViewCell else { fatalError() }
                vCell.drumTypeLabel.text = "\(indexPath)"
                vCell.delegate = self
                cell = vCell
            } else {
                guard let hCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumEditingHorizontalGridViewCell", for: indexPath) as? DrumEditingHorizontalGridViewCell else { fatalError() }
                
                hCell.delegate = self
                cell = hCell
            }
            
            return cell
        case drumMachineView.drumBarGridView:
            guard let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumBarGridViewCell", for: indexPath) as? DrumBarGridViewCell else { fatalError() }
            cell.barLabel.text = "\(indexPath)"
            cell.delegate = self
            return cell
        case drumMachineView.drumPatternGridView:
            var cell = GridViewCell()
            if UIDevice.current.orientation.isPortrait {
                guard let vCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternGridViewCell", for: indexPath) as?   DrumPatternGridViewCell else { fatalError() }
                vCell.drumLabel.text = "\(indexPath)"
                vCell.delegate = self
                cell = vCell
            } else {
                guard let hCell = gridView.dequeueReusableCell(withReuseIdentifier: "DrumPatternHorizontalGridViewCell", for: indexPath) as? DrumPatternHorizontalGridViewCell else { fatalError() }
                
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

}

extension DrumMachineViewController: DrumBarGridViewCellDelegate {

}

extension DrumMachineViewController: DrumPatternGridViewCellDelegate {
    func patternSelecte(cell: DrumPatternGridViewCell, isSelected: Bool) {
        print("\(cell.indexPath), \(isSelected)")
    }

}
