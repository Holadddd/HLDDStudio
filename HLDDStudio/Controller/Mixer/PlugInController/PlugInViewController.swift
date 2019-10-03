//
//  PlugInViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit

class PlugInViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var plugInView: PlugInView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        backButton.addTarget(self,
                             action: #selector(PlugInViewController.backButtonAction),
                             for: .touchUpInside)
        
        plugInView.tableView.delegate = self
        
        plugInView.tableView.dataSource = self
        
        plugInView.tableView.register(PlugInReverbTableViewCell.nib,
                                      forCellReuseIdentifier: "PlugInReverbTableViewCell")
        
        plugInView.tableView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        plugInView.tableView.reloadData()
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        AppUtility.lockOrientation(.portrait,
                                   andRotateTo: .portrait,
                                   complete: nil)
    }
    
    @objc func backButtonAction() {
        
        dismiss(animated: true) {
            
        }
    }
}

extension PlugInViewController: UITableViewDelegate {
    
}

extension PlugInViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        let track = PlugInManager.shared.showingTrackOnPlugInVC
        
        return PlugInManager.shared.plugInOntruck[track].plugInArr.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let track = PlugInManager.shared.showingTrackOnPlugInVC
        
        switch PlugInManager.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn {
            
        case .reverb(let reverb):
            
            guard let cell = plugInView
                .tableView
                .dequeueReusableCell(withIdentifier: String(describing: PlugInReverbTableViewCell.self))
                as? PlugInReverbTableViewCell
                else { fatalError() }
            
            cell.plugInBarView.plugInTitleLabel.text = "Reverb"
            //defauld factory
            cell.factoryTextField.text = reverb.factory
            
            cell.dryWetMixLabel.text = String(format: "%.2f", reverb.dryWetMix)
            
            cell.dryWetMixKnob.value = Float(reverb.dryWetMix)
            
            switch PlugInManager.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
                
            case true:
                
                cell.plugInBarView.bypassButton.isSelected = true
                
                cell.dryWetMixKnob.isEnabled = false
                
                cell.factoryTextField.isEnabled = false
            case false:
                
                cell.plugInBarView.bypassButton.isSelected = false
                
                cell.dryWetMixKnob.isEnabled = true
                
                cell.factoryTextField.isEnabled = true
            }
            
            cell.delegate = self
            
            cell.datasource = self
            
            return cell
        case .guitarProcessor(let guitarProcessor):
            
            guard let cell = plugInView
                .tableView
                .dequeueReusableCell(withIdentifier: String(describing: PlugInGuitarProcessorTableViewCell.self))
                as? PlugInGuitarProcessorTableViewCell
                else { fatalError() }
            
            cell.plugInBarView.plugInTitleLabel.text = "GuitarProcessor"
            
            cell.distLabel.text = String(format: "%.2f", guitarProcessor.distortion)
            
            cell.disKnob.value = Float(guitarProcessor.distortion)
            
            cell.preGainLabel.text = String(format: "%.2f", guitarProcessor.preGain)
            
            cell.preGainKnob.value = Float(guitarProcessor.preGain)
            
            cell.outputGainLabel.text = String(format: "%.2f", guitarProcessor.postGain)
            
            cell.outputKnob.value = Float(guitarProcessor.postGain)
            
            switch PlugInManager.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
                
            case true:
                
                cell.plugInBarView.bypassButton.isSelected = true
            case false:
                
                cell.plugInBarView.bypassButton.isSelected = false
            }
            
            cell.delegate = self
            
            cell.datasource = self
            
            return cell
        case .delay(let delay):
            
            guard let cell = plugInView
                .tableView
                .dequeueReusableCell(withIdentifier: String(describing: PlugInDelayTableViewCell.self))
                as? PlugInDelayTableViewCell
                else { fatalError() }
            
            cell.plugInBarView.plugInTitleLabel.text = "Delay"
            
            cell.timeLabel.text = String(format: "%.2f", delay.time)
            
            cell.timeKnob.value = Float(delay.time)
            
            cell.feedbackLabel.text = String(format: "%.2f", delay.feedback)
            
            cell.feedbackKnob.value = Float(delay.feedback)
            
            cell.mixLabel.text = String(format: "%.2f", delay.dryWetMix)
            
            cell.mixKnob.value = Float(delay.dryWetMix)
            
            switch PlugInManager.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
                
            case true:
                
                cell.plugInBarView.bypassButton.isSelected = true
            case false:
                
                cell.plugInBarView.bypassButton.isSelected = false
            }
            
            cell.delegate = self
            
            cell.datasource = self
            
            return cell
        case .chorus(let chorus):
            
            guard let cell = plugInView
                .tableView
                .dequeueReusableCell(withIdentifier: String(describing: PlugInChorusTableViewCell.self))
                as? PlugInChorusTableViewCell
                else { fatalError() }
            
            cell.plugInBarView.plugInTitleLabel.text = "Chorus"
            
            cell.feedbackLabel.text = String(format: "%.2f", chorus.feedback)
            
            cell.feedbackKnob.value = Float(chorus.feedback)
            
            cell.depthLabel.text = String(format: "%.2f", chorus.depth)
            
            cell.depthKnob.value = Float(chorus.depth)
            
            cell.mixLabel.text = String(format: "%.2f", chorus.dryWetMix)
            
            cell.mixKnob.value = Float(chorus.dryWetMix)
            
            cell.frequencyLabel.text = String(format: "%.2f", chorus.frequency)
            
            cell.frequencyKnob.value = Float(chorus.frequency)
            
            switch PlugInManager.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
                
            case true:
                
                cell.plugInBarView.bypassButton.isSelected = true
            case false:
                
                cell.plugInBarView.bypassButton.isSelected = false
            }
            
            cell.delegate = self
            
            cell.datasource = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 200
    }
    
}
