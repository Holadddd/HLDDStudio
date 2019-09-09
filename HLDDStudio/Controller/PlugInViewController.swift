//
//  PlugInViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

protocol PlugInViewControllerDelegate: AnyObject {
    
    func plugInReverbBypass(indexPathAtPlugInArr indexPath: IndexPath)
    
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
        let mixer = plugInArr[indexPath.row]
        switch mixer.plugIn {
        case .reverb:
            guard let cell = plugInView.tableView.dequeueReusableCell(withIdentifier: "PlugInReverbTableViewCell") as? PlugInReverbTableViewCell else { fatalError() }
            cell.plugInBarView.plugInTitleLabel.text = "Reverb"
            cell.plugInBarView.bypassButton.isSelected = mixer.byPass
            cell.delegate = self
            cell.datasource = self
            return cell
        }
        
    }
    
}
//PlugInReverbProtocol
extension PlugInViewController: PlugInReverbTableViewCellDelegate {
   
    
    
    func dryWetMixValueChange(_ sender: UISlider) {
        print(sender.value)
    }
    
    func plugInReverbFactorySelect(_ factory: String) {
        print("ReverbSelectFactoryAs:\(factory)")
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
