//
//  HLDDKnob.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/11.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol HLDDKnobDelegate:AnyObject {
    
    func knobValueDidChange(knobValue value: Float, knob: Knob)
    
    func knobIsTouching(bool: Bool, knob: Knob)
    
}

class Knob: UIControl {
    /** Contains the minimum value of the receiver. */
    var minimumValue: Float = -1
    
    /** Contains the maximum value of the receiver. */
    var maximumValue: Float = 1
    
    /** Contains the receiver’s current value. */
    var value: Float = 0 {
        didSet {
            reloadKnob()
        }
    }
    
    weak var delegate: HLDDKnobDelegate?
    
    var offsetY: CGFloat = 0.0
    
    func knobValueChange(dirIsUp: Bool) {
        let valueABSRange = abs(maximumValue - minimumValue)
        let scaleOfKnob:Float = 0.01
        switch dirIsUp {
        case true:
            guard value <= maximumValue-0.01 else{ return}
            value += valueABSRange * scaleOfKnob
            delegate?.knobValueDidChange(knobValue: value, knob: self)
        case false:
            guard value >= minimumValue+0.01 else {return}
            value -= valueABSRange * scaleOfKnob
            delegate?.knobValueDidChange(knobValue: value, knob: self)
        }
        
    }
    
    /** Contains a Boolean value indicating whether changes
     in the sliders value generate continuous update events. */
    var isContinuous = true
    // add imageView
    
    let knobMeasureView = UIImageView(image: UIImage(named: "HLDDKnobMeasure"))
    let knobView = UIImageView(image: UIImage(named: "HLDDKnob"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    private func commonInit() {
        //加入手勢
        let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(Knob.handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
        
        self.backgroundColor = .clear
        self.stickSubView(knobMeasureView)
        self.stickSubView(knobView)
        
    }
    
    @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
        delegate?.knobIsTouching(bool: gesture.userIsTouching, knob: self)
        //6
        let dir = gesture.dirIsUp
        knobValueChange(dirIsUp: dir)
    }
    
    func reloadKnob() {
        
        let valueABSRange = abs(maximumValue - minimumValue)
        
        let averangeValue = minimumValue + (valueABSRange / 2)
        
        let percentageOfValue = (value - averangeValue) / valueABSRange + 0.5
        
        let newAngle = CGFloat(-Double.pi * (5/6)) +  (CGFloat(Double.pi * (5/3)) * CGFloat(percentageOfValue))
        DispatchQueue.main.async {
            self.knobView.transform = CGAffineTransform.init(rotationAngle: newAngle)
        }
        
    }
}

import UIKit.UIGestureRecognizerSubclass

private class RotationGestureRecognizer: UIPanGestureRecognizer {
    private(set) var touchAngle: CGFloat = 0
    
    private(set) var dirIsUp: Bool = true
    
    private(set) var touchOffsetY: CGFloat = 0
    
    var userIsTouching = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        updateAngle(with: touches)
        userIsTouching = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        userIsTouching = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        //可以使用這個來追蹤使用者的手勢方向
        updateAngle(with: touches)
        //custom
        updateOffsetY(with: touches)
    }
    
    private func updateAngle(with touches: Set<UITouch>) {
        guard
            let touch = touches.first,
            let view = view
            else {
                return
        }
        let touchPoint = touch.location(in: view)
        touchAngle = angle(for: touchPoint, in: view)
    }
    //For Knob direction
    private func updateOffsetY(with touches: Set<UITouch>) {
        guard
            let touch = touches.first,
            let view = view
            else {
                return
        }
        let touchPoint = touch.location(in: view)
        if touchPoint.y != Offset.manager.offsetY && (touchPoint.y - Offset.manager.offsetY) < 0{
            //print("上升中")
            dirIsUp = true
            //每一次triger可以用來旋轉角度
        } else {
            //print("下降中")
            dirIsUp = false
        }
        touchOffsetY = touchPoint.y
        Offset.manager.offsetY = touchPoint.y
    }
    
    private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
}

