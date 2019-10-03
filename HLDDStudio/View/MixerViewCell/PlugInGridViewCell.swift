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
        
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        
        super .awakeFromNib()
        
        tableView.register(PlugInTableViewCell.nib,
                           forCellReuseIdentifier: String(describing: PlugInTableViewCell.self))
        
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
                                               name: .didInsertPlugIn,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlugInGridViewCell.didUpdatePlugIn(_:)),
                                               name: .didUpdatePlugIn,
                                               object: nil)
    }
    
    override func layoutIfNeeded() {
        
        super.layoutIfNeeded()
        
        imageViewTwo.frame = tableView.frame
    }
    
    @objc func didInsertPlugIn(_ notification: Notification){
        //make animation
        DispatchQueue.main.async { [ weak self ] in
            
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func didUpdatePlugIn(_ notification: Notification){

        DispatchQueue.main.async { [ weak self ] in
            
            guard let self = self else  {return }
            
            self.tableView.reloadData()
        }
        
    }
    
    @objc func didRemovePlugIn(_ notification: Notification){
        //make animation
    }
}

extension PlugInGridViewCell: PlugInTableViewCellDelegate{
    
    func bypassPlugin(_ cell: PlugInTableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell)
            else { fatalError() }
        
        let row = indexPath.row
        
        let column = self.indexPath.column
        
        delegate?.bypassPlugin(atRow: row,
                               Column: column)
    }
}

extension PlugInGridViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: String(describing: PlugInTableViewCell.self))
            as? PlugInTableViewCell
            else{ fatalError() }
        
        cell.plugInMarqueeLabel.restartLabel()
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        delegate?.perforPlugInVC(forTrack: self.indexPath.column)
    }
}

extension PlugInGridViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        guard let gridCell = tableView.superview
            as? PlugInGridViewCell
            else { fatalError() }
        
        return PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let gridCell = tableView.superview as? PlugInGridViewCell else { fatalError() }
        
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: String(describing: PlugInTableViewCell.self))
            as? PlugInTableViewCell
            else{ fatalError() }
    
        switch PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].plugIn {
            
        case .reverb(let reverb):
            
            cell.plugInLabel.text = PlugInDescription.reverb.rawValue
            
            cell.plugInMarqueeLabel.text = "Factory: \(reverb.factory), DryWetMixValue: \(String(format:"%.2f", reverb.dryWetMix)).   "
            
            switch PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].bypass {
                
            case true:
                
                cell.bypassButton.isSelected = true
                
                reverb.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                
                reverb.start()
            }
        case .guitarProcessor(let guitarProcessor):
            
            cell.plugInLabel.text = PlugInDescription.guitarProcessor.rawValue
            
            cell.plugInMarqueeLabel.text = "PreGain: \(String(format:"%.2f", guitarProcessor.preGain)), Distortion:\(String(format:"%.2f", guitarProcessor.distortion)), PostGain:\(String(format:"%.2f", guitarProcessor.postGain)).   "
            
            switch PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].bypass {
                
            case true:
                
                cell.bypassButton.isSelected = true
                
                guitarProcessor.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                
                guitarProcessor.start()
            }
        case .delay(let delay):
            
            cell.plugInLabel.text = PlugInDescription.delay.rawValue
            
            cell.plugInMarqueeLabel.text = "Time: \(String(format:"%.2f", delay.time)), Feedback: \(String(format:"%.2f", delay.feedback)), Mix: \(String(format:"%.2f", delay.dryWetMix)).   "
            
            switch PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].bypass {
                
            case true:
                
                cell.bypassButton.isSelected = true
                
                delay.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                
                delay.start()
            }
        case .chorus(let chorus):
            
            cell.plugInLabel.text = PlugInDescription.chorus.rawValue
            
            cell.plugInMarqueeLabel.text = "Feedback: \(String(format:"%.2f", chorus.feedback)), Depth: \(String(format:"%.2f", chorus.depth)), Mix: \(String(format:"%.2f", chorus.dryWetMix)), Frequency: \(chorus.frequency).   "
            
            switch PlugInManager.shared.plugInOntruck[gridCell.indexPath.column].plugInArr[indexPath.row].bypass {
                
            case true:
                
                cell.bypassButton.isSelected = true
                
                chorus.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                
                chorus.start()
            }
        }
        
        cell.delegate = self
        
        cell.plugInMarqueeLabel.restartLabel()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        guard let gridCell = tableView.superview
            as? PlugInGridViewCell
            else { fatalError() }
        
        let track = gridCell.indexPath.column + 1
        
        let seq = indexPath.row
        //this method need trigger by editingStyle
        if editingStyle == .delete {
            DispatchQueue.main.async { [ weak self ] in
                
                guard let self = self else { return }
                
                PlugInManager.shared.deletePlugInOnTrack(track,
                                                         seq: seq)
                
                self.delegate?.resetTrackOn(Track: track)
            }
        }
    }
}
