//
//  UIView+Extension.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/8.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

//@IBDesignable
extension UIView {

    func stickSubView(_ objectView: UIView) {
        
        objectView.removeFromSuperview()
        
        addSubview(objectView)
        
        objectView.translatesAutoresizingMaskIntoConstraints = false
        
        objectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        objectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        objectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        objectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func stickSubView(_ objectView: UIView, inset: UIEdgeInsets) {
        
        objectView.removeFromSuperview()
        
        addSubview(objectView)
        
        objectView.translatesAutoresizingMaskIntoConstraints = false
        
        objectView.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
        
        objectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
        
        objectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right).isActive = true
        
        objectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom).isActive = true
    }
}
