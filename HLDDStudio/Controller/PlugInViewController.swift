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
    
    var track = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(PlugInViewController.backButtonAction), for: .touchUpInside)
        
        plugInView.tableView.delegate = self
        plugInView.tableView.dataSource = self
        plugInView.tableView.register(PlugInReverbTableViewCell.nib, forCellReuseIdentifier: "PlugInReverbTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plugInView.tableView.reloadData()
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
        
        return PlugInCreater.shared.plugInOntruck[track].plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch PlugInCreater.shared.plugInOntruck[track].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInReverbTableViewCell") as? PlugInReverbTableViewCell else { fatalError() }
            guard let reverb = reverb as? AKReverb else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Reverb"
            //defauld factory
            
            cell.factoryTextField.text = reverb.factory
            cell.dryWetMixKnob.value = Float(reverb.dryWetMix)
            cell.dryWetMixLabel.text = String(format: "%.2f", reverb.dryWetMix)
            
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
        }
        
    }
    
}
//PlugInReverbProtocol
extension PlugInViewController: PlugInReverbTableViewCellDelegate {
    
    
    //FIXFIXNeedIndexPath
    func dryWetMixValueChange(_ value: Float) {
        
        switch PlugInCreater.shared.plugInOntruck[0].plugInArr[0].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else{ fatalError() }
            reverb.dryWetMix = Double(value)
        }
    }
    
    func plugInReverbFactorySelect(_ factoryRawValue: Int) {
        
        switch PlugInCreater.shared.plugInOntruck[0].plugInArr[0].plugIn {
        case .reverb(let reverb):
            
            guard let reverb = reverb as? AKReverb else{ fatalError() }
            
            
            //            guard let numberInFactory = reverbFactory.firstIndex(of: factory) else { fatalError()}
            let rawValue = factoryRawValue
            guard let set = AVAudioUnitReverbPreset(rawValue: rawValue) else { fatalError() }
            reverb.loadFactoryPreset(set)
            reverb.factory = reverbFactory[rawValue]
        }
    }
    
    func plugInReverbBypassSwitch(_ isBypass: Bool, cell: PlugInReverbTableViewCell) {
        print("ReverbisBypass:\(isBypass)")
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        try? AudioKit.stop()
        
        switch PlugInCreater.shared.plugInOntruck[0].plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let reverb = reverb as? AKReverb else { fatalError() }
            switch PlugInCreater.shared.plugInOntruck[0].plugInArr[indexPath.row].bypass {
            case true:
                PlugInCreater.shared.plugInOntruck[0].plugInArr[indexPath.row].bypass = false
                reverb.bypass()
            case false:
                PlugInCreater.shared.plugInOntruck[0].plugInArr[indexPath.row].bypass = true
                reverb.start()
            }
        }
        try? AudioKit.start()
    }
}

extension PlugInViewController: PlugInReverbTableViewCellDatasource {

    func plugInReverbPresetParameter() -> [String]? {
        return ["set1", "set2", "set3"]
    }
    
}

