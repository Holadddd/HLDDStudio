//
//  UserManualViewController.swift
//  HLDDStudio
//
//  Created by ting hui wu on 2019/10/5.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class UserManualViewController: UIViewController {

    @IBAction func disMissButton(_ sender: UIButton) {
        
        dismiss(animated: true) {
            
        }
    }
    
    @IBOutlet weak var userManualView: UserManualView!
    
    
    @IBOutlet weak var manualScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userManualView.delegate = self
    }
}
extension UserManualViewController: UserManualViewDelegate{
    
    func recoverAnimate() {
        DispatchQueue.main.async { [ weak self ] in
            
            guard let strongSelf = self
            else { fatalError() }
            
            let animate = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
                
                strongSelf.userManualView.translatesAutoresizingMaskIntoConstraints = false

                strongSelf.userManualView.translatesAutoresizingMaskIntoConstraints = true
            }
            
            animate.startAnimation()
        }
    }
    
    
    func animation() {
        
        DispatchQueue.main.async { [ weak self ] in
            
            let animate = UIViewPropertyAnimator(duration: 0.5, curve: .linear){ [ weak self ] in
                
                guard let strongSelf = self
                    else { fatalError() }
                
                for (index, element) in strongSelf.userManualView.imageArr.enumerated() {
                    
                    if index == 0 {
                        element.frame.origin = CGPoint(x: 0, y: strongSelf.userManualView.TitelLabel.frame.maxY + 8)
                    } else {
                        let lastView = strongSelf.userManualView.labelViewArr[index - 1]
                        element.frame.origin = CGPoint(x: 0, y: lastView.frame.maxY + 8)
                    }
                    
                    strongSelf.userManualView.labelViewArr[index].frame.origin = CGPoint(x: 0, y: element.frame.maxY + 8)
                }
                
            }
            
            guard let strongSelf = self
            else { fatalError() }
            
            animate.startAnimation()
            
            strongSelf.manualScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: strongSelf.userManualView.InformationDigitalDisplayLabelView.frame.maxY)
            
            strongSelf.manualScrollView.layoutSubviews()
        }
        
    }
    
    
    
}
