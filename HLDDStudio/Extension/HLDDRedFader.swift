//
//  HLDDRedFader.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/9/13.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol HLDDRedFaderDelegate:AnyObject {
    
    func redFaderValueDidChange(faderValue value: Float, fader: RedFader)
    
    func redFaderIsTouching(bool: Bool, fader: RedFader)
    
}

class RedFader: UIControl {
    
    /** Contains the minimum value of the receiver. */
    var minimumValue: Float = -1
    
    /** Contains the maximum value of the receiver. */
    var maximumValue: Float = 1
    
    /** Contains the receiver’s current value. */
    var value: Float = 0 {
        didSet {
            reloadFader()
        }
    }
    
    weak var delegate: HLDDRedFaderDelegate?
    
    var offsetY: CGFloat = 0.0
    
    func faderValueChange(dirIsUp: Bool) {
        
    }
    
    /** Contains a Boolean value indicating whether changes
     in the sliders value generate continuous update events. */
    var isContinuous = true
    
    
    // add imageView
    
    let faderTrackView = UIImageView(image: UIImage(named: "FaderTrack"))
    let faderKnobView = UIImageView(image: UIImage(named: "RedFaderKnob"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = faderTrackView.bounds.width
        let h = faderTrackView.bounds.height
        faderTrackView.frame = self.bounds
        faderKnobView.frame = CGRect(origin: CGPoint(x: 0, y: h * 0.05), size: CGSize(width: w, height: w/3))
        reloadFader()
    }
    
    private func commonInit() {
        //加入手勢
        let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(RedFader.handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
        
        self.addSubview(faderTrackView)
        faderTrackView.addSubview(faderKnobView)
        
    }
    
    @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
        let isTouching = gesture.userIsTouching
        delegate?.redFaderIsTouching(bool: isTouching, fader: self)
        
        offsetY = gesture.touchOffsetY
        
        
        let w = faderTrackView.bounds.width
        let h = faderTrackView.bounds.height
        let minY = faderTrackView.frame.minY + h * 0.05
        let maxY = faderTrackView.frame.maxY - w/3
        let absRange = abs(maxY - minY)
        //use offset to reset value
        if offsetY < maxY  && offsetY > minY  {
            
            let percentageOfFader = abs( (offsetY - maxY) / absRange )
            //print(String(format: "%.2f", percentageOfFader))
            let valueRange = maximumValue - minimumValue
            value = Float(CGFloat(minimumValue) + CGFloat(abs(valueRange)) * CGFloat(percentageOfFader))
        } else {
            return
        }
        delegate?.redFaderValueDidChange(faderValue: value, fader: self)
        
    }
    
    func reloadFader() {
        
        let w = faderTrackView.bounds.width
        let h = faderTrackView.bounds.height
        let minY = faderTrackView.frame.minY + h * 0.05
        let maxY = faderTrackView.frame.maxY - w/3
        let valueRange = maximumValue - minimumValue
        //use value to reset offsetY
        if value < maximumValue && value > minimumValue {
            let absRange = abs(maxY - minY)
            let percntageOfFaderOffsetY = abs((value - minimumValue)/valueRange)
            DispatchQueue.main.async {
                self.faderKnobView.frame.origin.y = CGFloat(maxY - CGFloat(percntageOfFaderOffsetY) * absRange)
            }
        } else {
            
            return
            
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
