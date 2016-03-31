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
    /// Rate default color for rateValue = 5
    private static let rateLineColorBest: UIColor = UIColor.init(hue: 165 / 360, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    
    /// Rate default color for rateValue = 0
    private static let rateLineColorWorst: UIColor = UIColor.init(hue: 1, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    
    // MARK: -
    // MARK: Private property.
    
    private var shapeLayer: CAShapeLayer = CAShapeLayer.init()
    private var shapePath: UIBezierPath = UIBezierPath.init()
    
    private var rateFaceMargin: CGFloat = 1
    private var touchPoint: CGPoint? = nil
    private var hueFrom: CGFloat = 0, saturationFrom: CGFloat = 0, brightnessFrom: CGFloat = 0, alphaFrom: CGFloat = 0
    private var hueDelta: CGFloat = 0, saturationDelta: CGFloat = 0, brightnessDelta: CGFloat = 0, alphaDelta: CGFloat = 0
    
    // MARK: -
    // MARK: Public property.
    
    /// Line width.
    @IBInspectable public var rateLineWidth: CGFloat = 14 {
        didSet {
            if rateLineWidth > 20 {
                rateLineWidth = 20
            }
            if rateLineWidth < 0.5 {
                rateLineWidth = 0.5
            }
            self.rateFaceMargin = rateLineWidth / 2
            redraw()
        }
    }
    
    /// Current line color.
    @IBInspectable public var rateColor: UIColor = UIColor.init(red: 55 / 256, green: 46 / 256, blue: 229 / 256, alpha: 1.0) {
        didSet {
            redraw()
        }
    }
    
    /// Color range
    public var rateColorRange: (from: UIColor, to: UIColor) = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest) {
        didSet {
            // Get begin color
            rateColorRange.from.getHue(&hueFrom, saturation: &saturationFrom, brightness: &brightnessFrom, alpha: &alphaFrom)
            
            // Get end color
            var hueTo: CGFloat = 1, saturationTo: CGFloat = 1, brightnessTo: CGFloat = 1, alphaTo: CGFloat = 1
            rateColorRange.to.getHue(&hueTo, saturation: &saturationTo, brightness: &brightnessTo, alpha: &alphaTo)
            
            // Update property
            hueDelta = hueTo - hueFrom
            saturationDelta = saturationTo - saturationFrom
            brightnessDelta = brightnessTo - brightnessFrom
            alphaDelta = alphaTo - alphaFrom
            
            // Force to refresh current color
            let currentRateValue = rateValue
            rateValue = currentRateValue
        }
    }
    
    /// If line color changes with rateValue.
    @IBInspectable public var rateDynamicColor: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Mouth width. From 0.2 to 0.7.
    @IBInspectable public var rateMouthWidth: CGFloat = 0.6 {
        didSet {
            if rateMouthWidth > 0.7 {
                rateMouthWidth = 0.7
            }
            if rateMouthWidth < 0.2 {
                rateMouthWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth lip width. From 0.2 to 0.9
    @IBInspectable public var rateLipWidth: CGFloat = 0.7 {
        didSet {
            if rateLipWidth > 0.9 {
                rateLipWidth = 0.9
            }
            if rateLipWidth < 0.2 {
                rateLipWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth vertical position. From 0.1 to 0.5.
    @IBInspectable public var rateMouthVerticalPosition: CGFloat = 0.35 {
        didSet {
            if rateMouthVerticalPosition > 0.5 {
                rateMouthVerticalPosition = 0.5
            }
            if rateMouthVerticalPosition < 0.1 {
                rateMouthVerticalPosition = 0.1
            }
            redraw()
        }
    }
    
    /// If show eyes.
    @IBInspectable public var rateShowEyes: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Eye width. From 0.1 to 0.3.
    @IBInspectable public var rateEyeWidth: CGFloat = 0.2 {
        didSet {
            if rateEyeWidth > 0.3 {
                rateEyeWidth = 0.3
            }
            if rateEyeWidth < 0.1 {
                rateEyeWidth = 0.1
            }
            redraw()
        }
    }
    
    /// Eye vertical position. From 0.6 to 0.8.
    @IBInspectable public var rateEyeVerticalPosition: CGFloat = 0.6 {
        didSet {
            if rateEyeVerticalPosition > 0.8 {
                rateEyeVerticalPosition = 0.8
            }
            if rateEyeVerticalPosition < 0.6 {
                rateEyeVerticalPosition = 0.6
            }
            redraw()
        }
    }
    
    /// Rate value. From 0 to 5.
    @IBInspectable public var rateValue: Float = 2.5 {
        didSet {
            if rateValue > 5 {
                rateValue = 5
            }
            if rateValue < 0 {
                rateValue = 0
            }
            
            // Update color
            if rateDynamicColor {
                let rate: CGFloat = CGFloat(rateValue / 5)
                
                // Calculate new color
                self.rateColor = UIColor.init(
                    hue: hueFrom + hueDelta * rate,
                    saturation: saturationFrom + saturationDelta * rate,
                    brightness: brightnessFrom + brightnessDelta * rate,
                    alpha: alphaFrom + alphaDelta * rate)
            }
            
            // Callback
            self.rateValueChangeCallback?(newRateValue: rateValue)
            
            redraw()
        }
    }
    
    /// Callback when rateValue changes.
    public var rateValueChangeCallback: ((newRateValue: Float) -> Void)? = nil
    
    /// Sensitivity when drag. From 1 to 10.
    public var rateDragSensitivity: CGFloat = 5 {
        didSet {
            if rateDragSensitivity > 10 {
                rateDragSensitivity = 10
            }
            if rateDragSensitivity < 1 {
                rateDragSensitivity = 1
            }
        }
    }
    
    // MARK: -
    // MARK: Public methods.
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    /**
     Override layoutSubviews
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: -
    // MARK: Private methods.
    
    /**
    Init configure.
    */
    private func configure() {
        self.backgroundColor = self.backgroundColor ?? UIColor.whiteColor()
        self.clearsContextBeforeDrawing = true
        self.multipleTouchEnabled = false
        
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        rateColorRange = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest)

        self.layer.addSublayer(shapeLayer)
        redraw()
    }
    
    /**
     Redraw all lines.
     */
    private func redraw() {
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = rateColor.CGColor;
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = rateLineWidth
        
        shapePath.removeAllPoints()
        shapePath.appendPath(facePathWithRect(self.bounds))
        shapePath.appendPath(mouthPathWithRect(self.bounds))
        shapePath.appendPath(eyePathWithRect(self.bounds, isLeftEye: true))
        shapePath.appendPath(eyePathWithRect(self.bounds, isLeftEye: false))
        
        shapeLayer.path = shapePath.CGPath
        self.setNeedsDisplay()
    }
    
    /**
     Generate face UIBezierPath
     
     - parameter rect: rect
     
     - returns: face UIBezierPath
     */
    private func facePathWithRect(rect: CGRect) -> UIBezierPath {
        let margin = rateFaceMargin + 2
        let facePath = UIBezierPath(ovalInRect: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(margin, margin, margin, margin)))
        return facePath
    }
    
    /**
     Generate mouth UIBezierPath
     
     - parameter rect: rect
     
     - returns: mouth UIBezierPath
     */
    private func mouthPathWithRect(rect: CGRect) -> UIBezierPath {
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
        
        let halfLipWidth = width * rateMouthWidth * rateLipWidth / 2
        
        let mouthPath = UIBezierPath()
        mouthPath.moveToPoint(leftPoint)
        
        mouthPath.addCurveToPoint(
            centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPointMake(centerPoint.x - halfLipWidth, centerPoint.y))
        
        mouthPath.addCurveToPoint(
            rightPoint,
            controlPoint1: CGPointMake(centerPoint.x + halfLipWidth, centerPoint.y),
            controlPoint2: rightPoint)
        
        return mouthPath
    }
    
    /**
     Generate eye UIBezierPath
     
     - parameter rect:      rect
     - parameter isLeftEye: is left eye
     
     - returns: eye UIBezierPath
     */
    private func eyePathWithRect(rect: CGRect, isLeftEye: Bool) -> UIBezierPath {
        if !rateShowEyes {
            return UIBezierPath.init()
        }
        
        let width = CGRectGetWidth(rect)
        let height = CGRectGetWidth(rect)
        
        let centerPoint = CGPointMake(
            width * (isLeftEye ? 0.30 : 0.70),
            height * (1 - rateEyeVerticalPosition) - height * 0.1 * (CGFloat(rateValue > 2.5 ? rateValue : 2.5) - 2.5) / 5)
        
        let leftPoint = CGPointMake(
            centerPoint.x - rateEyeWidth / 2 * width,
            height * (1 - rateEyeVerticalPosition))
        
        let rightPoint = CGPointMake(
            centerPoint.x + rateEyeWidth / 2 * width,
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
        
        return eyePath;
    }
    
    // MARK: Touch methods.
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchPoint = touches.first?.locationInView(self)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let currentPoint = touches.first?.locationInView(self)
        // Change rate value
        rateValue = rateValue + Float((currentPoint!.y - touchPoint!.y) / CGRectGetHeight(self.bounds) * rateDragSensitivity)
        // Save current point
        touchPoint = currentPoint
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchPoint = nil
    }
}