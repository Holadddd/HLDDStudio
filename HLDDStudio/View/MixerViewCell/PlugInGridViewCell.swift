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

protocol PlugInGridViewCellDataSource: AnyObject {
    func plugInTrack() -> [HLDDStudioPlugIn]
}

class PlugInGridViewCell: GridViewCell {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var vc: ViewController?
    
    let imageViewOne = UIImageView(image: UIImage.asset(.PlugInBackgroundView1))
    let imageViewTwo = UIImageView(image: UIImage.asset(.PlugInBackgroundView6))
    static var nib: UINib {
        return UINib(nibName: "PlugInGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        tableView.register(PlugInTableViewCell.nib, forCellReuseIdentifier: "PlugInTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        imageViewTwo.alpha = 0.2
        imageViewOne.addSubview(imageViewTwo)
        imageViewTwo.contentMode = .scaleAspectFill
        tableView.backgroundView = imageViewOne
        //for next time renew
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlugInGridViewCell.didChangePlugIn(_:)),
                                               name: .didUpdatePlugIn, object: nil)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        imageViewTwo.frame = tableView.frame
    }
    
    @objc func didChangePlugIn(_ notification: Notification){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("didChangePlugIn")
    }
}

extension PlugInGridViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
        cell.plugInMarqueeLabel.restartLabel()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selfVc = vc else { fatalError() }
        DispatchQueue.main.async {
            selfVc.performSegue(withIdentifier: "PlugInTableViewSegue", sender: nil)
        }
        
    }
    
}

extension PlugInGridViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PlugInCreater.shared.plugInOntruck.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlugInTableViewCell") as? PlugInTableViewCell else{ fatalError() }
        
        switch PlugInCreater.shared.plugInOntruck[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else { fatalError() }
            cell.plugInLabel.text = "REVERB"
            cell.plugInMarqueeLabel.text = "Factory: \(reverb.factory), DryWetMixValue: \(String(format:"%.2f", reverb.dryWetMix) )"
            
            switch PlugInCreater.shared.plugInOntruck[indexPath.row].bypass {
            case true:
                
                cell.bypassButton.isSelected = true
                reverb.bypass()
            case false:
                
                cell.bypassButton.isSelected = false
                reverb.start()
            }
        }
        cell.delegate = vc
        
        return cell
    }
    
}
