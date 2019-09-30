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
        backButton.addTarget(self, action: #selector(PlugInViewController.backButtonAction), for: .touchUpInside)
        
        plugInView.tableView.delegate = self
        plugInView.tableView.dataSource = self
        plugInView.tableView.register(PlugInReverbTableViewCell.nib, forCellReuseIdentifier: "PlugInReverbTableViewCell")
        plugInView.tableView.bounces = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        plugInView.tableView.reloadData()
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait, complete: nil)
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true) {
            
        }
    }
    
}

extension PlugInViewController: UITableViewDelegate {
    
}

extension PlugInViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        return PlugInCreater.shared.plugInOntruck[track].plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInReverbTableViewCell") as? PlugInReverbTableViewCell else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Reverb"
            //defauld factory
            cell.factoryTextField.text = reverb.factory
            cell.dryWetMixLabel.text = String(format: "%.2f", reverb.dryWetMix)
            cell.dryWetMixKnob.value = Float(reverb.dryWetMix)
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
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
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInGuitarProcessorTableViewCell") as? PlugInGuitarProcessorTableViewCell else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "GuitarProcessor"
            
            cell.distLabel.text = String(format: "%.2f", guitarProcessor.distortion)
            cell.disKnob.value = Float(guitarProcessor.distortion)
            
            cell.preGainLabel.text = String(format: "%.2f", guitarProcessor.preGain)
            cell.preGainKnob.value = Float(guitarProcessor.preGain)
            
            cell.outputGainLabel.text = String(format: "%.2f", guitarProcessor.postGain)
            cell.outputKnob.value = Float(guitarProcessor.postGain)
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
            case true:
                cell.plugInBarView.bypassButton.isSelected = true
                
            case false:
                cell.plugInBarView.bypassButton.isSelected = false
                
            }
            cell.delegate = self
            cell.datasource = self
            return cell
        case .delay(let delay):
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInDelayTableViewCell") as? PlugInDelayTableViewCell else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Delay"
            
            cell.timeLabel.text = String(format: "%.2f", delay.time)
            cell.timeKnob.value = Float(delay.time)
            
            cell.feedbackLabel.text = String(format: "%.2f", delay.feedback)
            cell.feedbackKnob.value = Float(delay.feedback)
            
            cell.mixLabel.text = String(format: "%.2f", delay.dryWetMix)
            cell.mixKnob.value = Float(delay.dryWetMix)
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
            case true:
                cell.plugInBarView.bypassButton.isSelected = true
                
            case false:
                cell.plugInBarView.bypassButton.isSelected = false
                
            }
            cell.delegate = self
            cell.datasource = self
            return cell
        case .chorus(let chorus):
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInChorusTableViewCell") as? PlugInChorusTableViewCell else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Chorus"
            
            cell.feedbackLabel.text = String(format: "%.2f", chorus.feedback)
            cell.feedbackKnob.value = Float(chorus.feedback)
            
            cell.depthLabel.text = String(format: "%.2f", chorus.depth)
            cell.depthKnob.value = Float(chorus.depth)
            
            cell.mixLabel.text = String(format: "%.2f", chorus.dryWetMix)
            cell.mixKnob.value = Float(chorus.dryWetMix)
            
            cell.frequencyLabel.text = String(format: "%.2f", chorus.frequency)
            cell.frequencyKnob.value = Float(chorus.frequency)
            
            switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].bypass{
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
//PlugInReverbProtocol  要改成不局限於 reverb 讓要改參數直接呼叫 pluginmanger
extension PlugInViewController: PlugInControlDelegate {
    
    func plugInReverbFactorySelect(_ factoryRawValue: Int, cell: PlugInReverbTableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let set = AVAudioUnitReverbPreset(rawValue: factoryRawValue) else{ fatalError()}
            
            reverb.loadFactoryPreset(set)
            reverb.factory = reverbFactory[factoryRawValue]
            PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn = PlugIn.reverb(reverb)
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
    }
    
    func dryWetMixValueChange(_ value: Float, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(let reverb):
            reverb.dryWetMix = Double(value)
            PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.reverb(reverb)
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
    }
    
    func guitarProcessorValueChange(_ value: Float, type: GuitarProcessorValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(let guitarProcessor):
            switch type {
            case .dist:
                guitarProcessor.distortion = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            case .outputGain:
                guitarProcessor.postGain = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            case .HLDDPreGain:
                guitarProcessor.preGain = Double(value)
                guitarProcessor.HLDDPreGain = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.guitarProcessor(guitarProcessor)
            }
            return
        case .delay(_):
            return
        case .chorus(_):
            return
        }
        
    }
    
    func delayValueChange(_ value: Float, type: DelayValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(_):
            return
        case .delay(let delay):
            switch type {
            case .time:
                delay.time = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            case .feedback:
                delay.feedback = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            case .mix:
                delay.dryWetMix = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.delay(delay)
            }
            return
        case .chorus(_):
            return
        }
    }
    
    func chorusValueChange(_ value: Float, type: ChorusValueType, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn {
        case .reverb(_):
            return
        case .guitarProcessor(_):
            return
        case .delay(_):
            return
        case .chorus(let chorus):
            switch type{
            case .depth:
                chorus.depth = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .feedback:
                chorus.feedback = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .frequency:
                chorus.frequency = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            case .mix:
                chorus.dryWetMix = Double(value)
                PlugInCreater.shared.plugInOntruck[track].plugInArr[row].plugIn = PlugIn.chorus(chorus)
            }
            return
        }
    }
    
    func plugInBypassSwitch(_ isBypass: Bool, cell: UITableViewCell) {
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        let track = PlugInCreater.shared.showingTrackOnPlugInVC
        let row = indexPath.row
        PlugInCreater.shared.plugInBypass(track, seq: row)
        NotificationCenter.default.post(.init(name: .didUpdatePlugIn, object: nil, userInfo: nil))
        
    }
}

extension PlugInViewController: PlugInControlDatasource {
    
    func plugInReverbPresetParameter(cell: PlugInReverbTableViewCell) -> [String]? {
        return nil
    }
 
}

