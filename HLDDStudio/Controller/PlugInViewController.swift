//
//  PlugInViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import AudioKit

protocol PlugInViewControllerDelegate: AnyObject {
    
    func plugInReverbBypass(indexPathAtPlugInArr indexPath: IndexPath)
    
    func plugInReverbDryWetMixValueChange(value: Float)
    
    func plugInReverbSelectFactory(_ factoryRawValue: Int)
    
}

class PlugInViewController: UIViewController {
    
    var plugInArr: [HLDDStudioPlugIn]?
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var plugInView: PlugInView!
    
    
    weak var delegate: PlugInViewControllerDelegate?
    
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
        guard let plugInArr = plugInArr else { fatalError() }
        return plugInArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let plugInArr = plugInArr else { fatalError() }
        
        switch plugInArr[indexPath.row].plugIn {
        case .reverb(let reverb):
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInReverbTableViewCell") as? PlugInReverbTableViewCell else { fatalError() }
            guard let reverb = reverb as? AKReverb else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Reverb"
            //defauld factory
            
            cell.factoryTextField.text = reverb.factory
            cell.dryWetMixKnob.value = Float(reverb.dryWetMix)
            cell.dryWetMixLabel.text = String(format: "%.2f", reverb.dryWetMix)
            
            switch plugInArr[indexPath.row].bypass{
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
    
    
    
    func dryWetMixValueChange(_ value: Float) {
   
        delegate?.plugInReverbDryWetMixValueChange(value: value)
    }
    
    func plugInReverbFactorySelect(_ factoryRawValue: Int) {
        print("ReverbSelectFactoryAs:\(reverbFactory[factoryRawValue])")
        delegate?.plugInReverbSelectFactory(factoryRawValue)
    }
    
    func plugInReverbBypassSwitch(_ isBypass: Bool, cell: PlugInReverbTableViewCell) {
        print("ReverbisBypass:\(isBypass)")
        guard let indexPath = plugInView.tableView.indexPath(for: cell) else { fatalError() }
        delegate?.plugInReverbBypass(indexPathAtPlugInArr: indexPath)
        print(indexPath)
    }
}

extension PlugInViewController: PlugInReverbTableViewCellDatasource {

    func plugInReverbPresetParameter() -> [String]? {
        return ["set1", "set2", "set3"]
    }
    
}

