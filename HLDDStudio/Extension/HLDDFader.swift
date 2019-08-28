//
//  HLDDFader.swift
//  HLDDStudio
//
//  Created by wu1221 on 2019/8/28.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation
import UIKit

protocol HLDDFaderDelegate:AnyObject {
    
    func valueDidChange(faderValue value: Float)
    
}

class Fader: UIControl {
    
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
    
    weak var delegate: HLDDFaderDelegate?
    
    var offsetY: CGFloat = 0.0
    
    func faderValueChange(dirIsUp: Bool) {
        
    }
    
    /** Contains a Boolean value indicating whether changes
     in the sliders value generate continuous update events. */
    var isContinuous = true
    
    
    // add imageView
    
    let faderTrackView = UIImageView(image: UIImage(named: "FaderTrack"))
    let faderKnobView = UIImageView(image: UIImage(named: "FaderKnob"))
    
    
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
        
        faderTrackView.frame = self.bounds
        
    }
    
    private func commonInit() {
        //加入手勢
        let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(Fader.handleGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
        self.addSubview(faderTrackView)
    }
    
    @objc private func handleGesture(_ gesture: RotationGestureRecognizer) {
        faderKnobView.frame.origin.y -= 1
        print("touch")
    }
    
    func reloadFader() {
        
        
    }
}
import UIKit.UIGestureRecognizerSubclass

private class RotationGestureRecognizer: UIPanGestureRecognizer {
    private(set) var touchAngle: CGFloat = 0
    
    private(set) var dirIsUp: Bool = true
    
    private(set) var touchOffsetY: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        updateAngle(with: touches)
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
