//
//  DrumMachineViewController.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/19.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class DrumMachineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
}
