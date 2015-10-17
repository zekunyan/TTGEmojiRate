//
//  EmojiRateView.swift
//  EmojiRate
//
//  Created by zorro on 15/10/17.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class EmojiRateView: UIView {
    private static let rateFaceMargin: CGFloat = 12
    
    private var touchPoint: CGPoint? = nil
    
    // Public property
    @IBInspectable
    public var rateLineWidth: CGFloat = 14 {
        didSet {
            if rateLineWidth > 20 {
                rateLineWidth = 20
            }
            if rateLineWidth < 1 {
                rateLineWidth = 1
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateColor: UIColor = UIColor.init(red: 55 / 256, green: 46 / 256, blue: 229 / 256, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateDynamicColor: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateMouthWidth: CGFloat = 0.6 {
        didSet {
            if rateMouthWidth > 0.7 {
                rateMouthWidth = 0.7
            }
            if rateMouthWidth < 0.2 {
                rateMouthWidth = 0.2
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateMouthVerticalPosition: CGFloat = 0.35 {
        didSet {
            if rateMouthVerticalPosition > 0.5 {
                rateMouthVerticalPosition = 0.5
            }
            if rateMouthVerticalPosition < 0.1 {
                rateMouthVerticalPosition = 0.1
            }
            
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateShowEyes: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateEyeWidth: CGFloat = 0.2 {
        didSet {
            if rateEyeWidth > 0.3 {
                rateEyeWidth = 0.3
            }
            if rateEyeWidth < 0.1 {
                rateEyeWidth = 0.1
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateEyeVerticalPosition: CGFloat = 0.6 {
        didSet {
            if rateEyeVerticalPosition > 0.8 {
                rateEyeVerticalPosition = 0.8
            }
            if rateEyeVerticalPosition < 0.6 {
                rateEyeVerticalPosition = 0.6
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var rateValue: Float = 2.5 {
        didSet {
            if rateValue > 5 {
                rateValue = 5
            }
            if rateValue < 0 {
                rateValue = 0
            }
            
            // Update color
            if rateDynamicColor {
                let hue = 165 + 195 * (5 - rateValue) / 5
                self.rateColor = UIColor.init(hue: CGFloat(hue / 360), saturation: 0.8, brightness: 0.9, alpha: 1)
            }
            
            // Callback
            self.rateValueChangeCallback?(newRateValue: rateValue)
            
            self.setNeedsDisplay()
        }
    }
    
    public var rateValueChangeCallback: ((newRateValue: Float) -> Void)? = nil
    
    // Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // Draw
    public override func drawRect(rect: CGRect) {
        drawFaceWithRect(rect)
        drawMouthWithRect(rect)
        drawEyeWithRect(rect, isLeftEye: true)
        drawEyeWithRect(rect, isLeftEye: false)
    }
    
    // Init configure
    private func configure() {
        self.backgroundColor = UIColor.clearColor()
        self.clearsContextBeforeDrawing = true
        self.multipleTouchEnabled = false
    }
    
    // Draw - Face
    private func drawFaceWithRect(rect: CGRect) {
        let facePath = UIBezierPath(ovalInRect: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(EmojiRateView.rateFaceMargin, EmojiRateView.rateFaceMargin, EmojiRateView.rateFaceMargin, EmojiRateView.rateFaceMargin)))
        rateColor.setStroke()
        facePath.lineWidth = rateLineWidth
        facePath.stroke()
    }
    
    // Draw - Mouth
    private func drawMouthWithRect(rect: CGRect) {
        let width = CGRectGetWidth(rect)
        let height = CGRectGetWidth(rect)
        
        let leftPoint = CGPointMake(
            width * (1 - rateMouthWidth) / 2,
            height * (1 - rateMouthVerticalPosition))
        
        let rightPoint = CGPointMake(
            width - leftPoint.x,
            leftPoint.y)
        
        let centerPoint = CGPointMake(
            width / 2,
            leftPoint.y + height * 0.3 * (CGFloat(rateValue) - 2.5) / 5)
        
        let mouthPath = UIBezierPath()
        mouthPath.moveToPoint(leftPoint)
        
        mouthPath.addCurveToPoint(
            centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPointMake(centerPoint.x - width * 0.2, centerPoint.y))
        
        mouthPath.addCurveToPoint(
            rightPoint,
            controlPoint1: CGPointMake(centerPoint.x + width * 0.2, centerPoint.y),
            controlPoint2: rightPoint)
        
        mouthPath.lineCapStyle = CGLineCap.Round;
        rateColor.setStroke()
        mouthPath.lineWidth = rateLineWidth
        mouthPath.stroke()
    }
    
    // Draw - Eye
    private func drawEyeWithRect(rect: CGRect, isLeftEye: Bool) {
        if !rateShowEyes {
            return
        }
        
        let width = CGRectGetWidth(rect)
        let height = CGRectGetWidth(rect)
        
        let leftPoint = CGPointMake(
            ((isLeftEye ? 0.25 : 0.75) - rateEyeWidth / 2) * width + EmojiRateView.rateFaceMargin * (isLeftEye ? 2 : -2),
            (1 - rateEyeVerticalPosition) * height)
        
        let centerPoint = CGPointMake(
            (isLeftEye ? 0.25 : 0.75) * width + EmojiRateView.rateFaceMargin * (isLeftEye ? 2 : -2),
            leftPoint.y - height * 0.1 * (CGFloat(rateValue > 2.5 ? rateValue : 2.5) - 2.5) / 5)
        
        let rightPoint = CGPointMake(
            leftPoint.x + width * rateEyeWidth,
            leftPoint.y)
        
        let eyePath = UIBezierPath()
        eyePath.moveToPoint(leftPoint)
        
        eyePath.addCurveToPoint(
            centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPointMake(centerPoint.x - width * 0.06, centerPoint.y))
        
        eyePath.addCurveToPoint(
            rightPoint,
            controlPoint1: CGPointMake(centerPoint.x + width * 0.06, centerPoint.y),
            controlPoint2: rightPoint)
        
        eyePath.lineCapStyle = CGLineCap.Round
        rateColor.setStroke()
        eyePath.lineWidth = rateLineWidth
        eyePath.stroke()
    }
    
    // Touch override
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchPoint = touches.first?.locationInView(self)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let currentPoint = touches.first?.locationInView(self)
        // Change rate value
        rateValue = rateValue + Float((currentPoint!.y - touchPoint!.y) / CGRectGetHeight(self.bounds) * 0.6)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchPoint = nil
    }
}