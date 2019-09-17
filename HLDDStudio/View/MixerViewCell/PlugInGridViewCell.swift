//
//  PlugInGridViewCell.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/7.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import G3GridView
import UIKit
import AudioKit

protocol PlugInGridViewCellDelegate: AnyObject {
    
    func bypassPlugin(atRow row: Int,Column column: Int)
    
    func perforPlugInVC(forTrack column: Int)
    
    func resetTrackOn(Track track: Int) 
}

protocol PlugInGridViewCellDataSource: AnyObject {
    func plugInTrack() -> [HLDDStudioPlugIn]
}

class PlugInGridViewCell: GridViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isNumberOfRowPassData = false
    
    weak var delegate: PlugInGridViewCellDelegate?
    
    let imageViewOne = UIImageView(image: UIImage.asset(.PlugInBackgroundView1))
    let imageViewTwo = UIImageView(image: UIImage.asset(.PlugInBackgroundView6))
    static var nib: UINib {
        return UINib(nibName: "PlugInGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        tableView.register(PlugInTableViewCell.nib, forCellReuseIdentifier: "PlugInTableViewCell")
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        
        imageViewTwo.alpha = 0.2
        imageViewOne.addSubview(imageViewTwo)
        imageViewTwo.contentMode = .scaleAspectFill
        tableView.backgroundView = imageViewOne
        //for next time renew
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlugInGridViewCell.didInsertPlugIn(_:)),
                                               name: .didInsertPlugIn, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlugInGridViewCell.didUpdatePlugIn(_:)),
                                               name: .didUpdatePlugIn, object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(PlugInGridViewCell.didRemovePlugIn(_:)),
//                                               name: .didRemovePlugIn, object: nil)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        imageViewTwo.frame = tableView.frame
        //tableView.layoutIfNeeded()
    }
    
    @objc func didInsertPlugIn(_ notification: Notification){
        //make animation
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func didUpdatePlugIn(_ notification: Notification){

        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("mixerCellPlugInUpdate")
        }
    }
    @objc func didRemovePlugIn(_ notification: Notification){
        //make animation
        
        print("didRemovePlugIn")
    }
}

extension PlugInGridViewCell: PlugInTableViewCellDelegate{
    
    func bypassPlugin(_ cell: PlugInTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError() }
        let row = indexPath.row
        let column = self.indexPath.column
        delegate?.bypassPlugin(atRow: row, Column: column)
    }
    
}

extension PlugInGridViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
        cell.plugInMarqueeLabel.restartLabel()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.perforPlugInVC(forTrack: self.indexPath.column)
    }
    
}

extension PlugInGridViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    //!!!!!!!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let gridCell = tableView.superview as? PlugInGridViewCell else { fatalError() }
        
        return PlugInCreater.shared.plugInOntruck[gridCell.indexPath.column].plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let gridCell = tableView.superview as? PlugInGridViewCell else { fatalError() }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
    
        switch PlugInCreater.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            cell.plugInLabel.text = "REVERB"
            cell.plugInMarqueeLabel.text = "Factory: \(reverb.factory), DryWetMixValue: \(String(format:"%.2f.", reverb.dryWetMix) )"
            print("Factory: \(reverb.factory)")
            switch PlugInCreater.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].bypass {
            case true:
                
                cell.bypassButton.isSelected = true
                reverb.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                reverb.start()
            }
        }
        
        cell.delegate = self
        cell.plugInMarqueeLabel.restartLabel()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let gridCell = tableView.superview as? PlugInGridViewCell else { fatalError() }
        let track = gridCell.indexPath.column + 1
        let seq = indexPath.row
        //this method need trigger by editingStyle
        if editingStyle == .delete {
            PlugInCreater.shared.deletePlugInOnTrack(track, seq: seq)
            delegate?.resetTrackOn(Track: track)
        }
        
        if editingStyle == .insert{
            
            print(indexPath)
        }
    }

}

