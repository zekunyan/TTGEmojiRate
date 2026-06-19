//
//  EmojiRateView.swift
//  EmojiRate
//
//  Created by zorro on 15/10/17.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import Foundation
import UIKit

@objc public enum TTGEmojiRateExpressionPreset: Int {
    case classic = 0
    case expressive
    case playful
    case diagnostic
    case minimal
}

@objc public enum TTGEmojiRateEyeStyle: Int {
    case automatic = 0
    case classic
    case round
    case wink
    case star
    case heart
    case sleepy
    case angry
}

@objc public enum TTGEmojiRateMouthStyle: Int {
    case automatic = 0
    case classic
    case smile
    case frown
    case flat
    case openSmile
    case surprise
    case smirk
}

@objc public enum TTGEmojiRateGestureDirection: Int {
    case vertical = 0
    case horizontal
}

@objc public enum TTGEmojiRateCustomPathMode: Int {
    case builtIn = 0
    case replace
    case overlay
}

@objc public enum TTGEmojiRateFaceShape: Int {
    case circle = 0
    case roundedSquare
    case squircle
    case blob
    case capsule
    case shield
    case cloud
    case none
}

@objc public protocol TTGEmojiRateViewPathDelegate: AnyObject {
    func emojiRateView(_ rateView: EmojiRateView, pathIn rect: CGRect, rateProgress: CGFloat) -> UIBezierPath?
}

public typealias TTGEmojiRateCustomPathProvider = (_ rect: CGRect, _ rateProgress: CGFloat, _ rateView: EmojiRateView) -> UIBezierPath?
public typealias TTGEmojiRateCustomFacePathProvider = (_ rect: CGRect, _ rateProgress: CGFloat, _ rateView: EmojiRateView) -> UIBezierPath?

@IBDesignable
open class EmojiRateView: UIView {
    /// Default high-score stroke color.
    fileprivate static let rateLineColorBest = UIColor(red: 0.08, green: 0.38, blue: 0.95, alpha: 1.0)

    /// Default low-score stroke color.
    fileprivate static let rateLineColorWorst = UIColor(red: 0.45, green: 0.78, blue: 1.0, alpha: 1.0)

    // MARK: -
    // MARK: Private property.

    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let faceFillLayer = CAShapeLayer()
    fileprivate let faceFillGradientLayer = CAGradientLayer()
    fileprivate let shapePath = UIBezierPath()
    fileprivate lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
    fileprivate lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))

    fileprivate var rateFaceMargin: CGFloat = 1
    fileprivate var touchPoint: CGPoint?
    fileprivate var hueFrom: CGFloat = 0, saturationFrom: CGFloat = 0, brightnessFrom: CGFloat = 0, alphaFrom: CGFloat = 0
    fileprivate var hueDelta: CGFloat = 0, saturationDelta: CGFloat = 0, brightnessDelta: CGFloat = 0, alphaDelta: CGFloat = 0
    fileprivate weak var customPathDelegateStorage: TTGEmojiRateViewPathDelegate?

    // MARK: -
    // MARK: Public property.

    /// Line width.
    @IBInspectable open var rateLineWidth: CGFloat = 14 {
        didSet {
            if rateLineWidth > 20 {
                rateLineWidth = 20
            }
            if rateLineWidth < 0.5 {
                rateLineWidth = 0.5
            }
            rateFaceMargin = rateLineWidth / 2
            redraw()
        }
    }

    /// Current line color.
    @IBInspectable open var rateColor = UIColor(red: 0.12, green: 0.48, blue: 0.94, alpha: 1.0) {
        didSet {
            redraw()
        }
    }

    /// Color range
    open var rateColorRange: (from: UIColor, to: UIColor) = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest) {
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
    @IBInspectable open var rateDynamicColor: Bool = true {
        didSet {
            redraw()
        }
    }

    /// Draws the emoji stroke with a gradient instead of a single stroke color.
    @IBInspectable open var rateGradientColorEnabled: Bool = false {
        didSet {
            updateShapeLayerHost()
            redraw()
        }
    }

    /// Stroke gradient colors.
    open var rateGradientColors: [UIColor] = [
        UIColor(red: 0.45, green: 0.78, blue: 1.0, alpha: 1),
        UIColor(red: 0.08, green: 0.38, blue: 0.95, alpha: 1)
    ] {
        didSet {
            redraw()
        }
    }

    /// Gradient start point x, from 0 to 1.
    @IBInspectable open var rateGradientStartPointX: CGFloat = 0 {
        didSet {
            rateGradientStartPointX = min(max(rateGradientStartPointX, 0), 1)
            redraw()
        }
    }

    /// Gradient start point y, from 0 to 1.
    @IBInspectable open var rateGradientStartPointY: CGFloat = 0 {
        didSet {
            rateGradientStartPointY = min(max(rateGradientStartPointY, 0), 1)
            redraw()
        }
    }

    /// Gradient end point x, from 0 to 1.
    @IBInspectable open var rateGradientEndPointX: CGFloat = 1 {
        didSet {
            rateGradientEndPointX = min(max(rateGradientEndPointX, 0), 1)
            redraw()
        }
    }

    /// Gradient end point y, from 0 to 1.
    @IBInspectable open var rateGradientEndPointY: CGFloat = 1 {
        didSet {
            rateGradientEndPointY = min(max(rateGradientEndPointY, 0), 1)
            redraw()
        }
    }

    /// Face outline shape. Use TTGEmojiRateFaceShape raw values.
    @IBInspectable open var faceShape: Int = TTGEmojiRateFaceShape.circle.rawValue {
        didSet {
            faceShape = clampedRawValue(faceShape, maxValue: TTGEmojiRateFaceShape.none.rawValue)
            redraw()
        }
    }

    /// Slightly morphs built-in face shapes with rate progress.
    @IBInspectable open var faceShapeMorphEnabled: Bool = false {
        didSet {
            redraw()
        }
    }

    /// Fills the face outline behind the emoji stroke.
    @IBInspectable open var faceFillEnabled: Bool = false {
        didSet {
            updateShapeLayerHost()
            redraw()
        }
    }

    /// Face fill color when dynamic fill and fill gradient are disabled.
    @IBInspectable open var faceFillColor: UIColor = UIColor(red: 0.12, green: 0.48, blue: 0.94, alpha: 0.12) {
        didSet {
            redraw()
        }
    }

    /// Face fill color range used when faceFillDynamicColor is enabled.
    open var faceFillColorRange: (from: UIColor, to: UIColor) = (
        UIColor(red: 0.45, green: 0.78, blue: 1.0, alpha: 0.12),
        UIColor(red: 0.08, green: 0.38, blue: 0.95, alpha: 0.16)
    ) {
        didSet {
            redraw()
        }
    }

    /// Changes the face fill color with rate progress.
    @IBInspectable open var faceFillDynamicColor: Bool = false {
        didSet {
            redraw()
        }
    }

    /// Draws the face fill with a gradient.
    @IBInspectable open var faceFillGradientEnabled: Bool = false {
        didSet {
            updateShapeLayerHost()
            redraw()
        }
    }

    /// Face fill gradient colors.
    open var faceFillGradientColors: [UIColor] = [
        UIColor(red: 0.67, green: 0.88, blue: 1.0, alpha: 0.18),
        UIColor(red: 0.08, green: 0.38, blue: 0.95, alpha: 0.12)
    ] {
        didSet {
            redraw()
        }
    }

    /// Mouth width. From 0.2 to 0.7.
    @IBInspectable open var rateMouthWidth: CGFloat = 0.6 {
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
    @IBInspectable open var rateLipWidth: CGFloat = 0.7 {
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
    @IBInspectable open var rateMouthVerticalPosition: CGFloat = 0.35 {
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
    @IBInspectable open var rateShowEyes: Bool = true {
        didSet {
            redraw()
        }
    }

    /// Eye width. From 0.1 to 0.3.
    @IBInspectable open var rateEyeWidth: CGFloat = 0.2 {
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
    @IBInspectable open var rateEyeVerticalPosition: CGFloat = 0.6 {
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

    /// Emoji expression preset. Use TTGEmojiRateExpressionPreset raw values.
    @IBInspectable open var emojiExpressionPreset: Int = TTGEmojiRateExpressionPreset.classic.rawValue {
        didSet {
            emojiExpressionPreset = clampedRawValue(emojiExpressionPreset, maxValue: TTGEmojiRateExpressionPreset.minimal.rawValue)
            redraw()
        }
    }

    /// Optional eye style override. Use TTGEmojiRateEyeStyle raw values.
    @IBInspectable open var emojiEyeStyle: Int = TTGEmojiRateEyeStyle.automatic.rawValue {
        didSet {
            emojiEyeStyle = clampedRawValue(emojiEyeStyle, maxValue: TTGEmojiRateEyeStyle.angry.rawValue)
            redraw()
        }
    }

    /// Optional mouth style override. Use TTGEmojiRateMouthStyle raw values.
    @IBInspectable open var emojiMouthStyle: Int = TTGEmojiRateMouthStyle.automatic.rawValue {
        didSet {
            emojiMouthStyle = clampedRawValue(emojiMouthStyle, maxValue: TTGEmojiRateMouthStyle.smirk.rawValue)
            redraw()
        }
    }

    /// Draws expression details such as brows, blush, tears, sweat, stars, and hearts.
    @IBInspectable open var emojiShowAccessories: Bool = true {
        didSet {
            redraw()
        }
    }

    /// Scales expression details. From 0 to 2.
    @IBInspectable open var emojiAccessoryScale: CGFloat = 1 {
        didSet {
            if emojiAccessoryScale > 2 {
                emojiAccessoryScale = 2
            }
            if emojiAccessoryScale < 0 {
                emojiAccessoryScale = 0
            }
            redraw()
        }
    }

    /// Minimum supported rate value.
    @IBInspectable open var minimumRateValue: Float = 0 {
        didSet {
            if minimumRateValue >= maximumRateValue {
                maximumRateValue = minimumRateValue + 1
            }
            rateValue = normalizedRateValue(rateValue)
        }
    }

    /// Maximum supported rate value.
    @IBInspectable open var maximumRateValue: Float = 5 {
        didSet {
            if maximumRateValue <= minimumRateValue {
                minimumRateValue = maximumRateValue - 1
            }
            rateValue = normalizedRateValue(rateValue)
        }
    }

    /// Increment used when changing the rate value. Use 0 for continuous values.
    @IBInspectable open var rateStep: Float = 0 {
        didSet {
            if rateStep < 0 {
                rateStep = 0
            }
            rateValue = normalizedRateValue(rateValue)
        }
    }

    /// Rate value. Clamped to minimumRateValue and maximumRateValue.
    @IBInspectable open var rateValue: Float = 2.5 {
        didSet {
            let adjustedValue = normalizedRateValue(rateValue)
            if adjustedValue != rateValue {
                rateValue = adjustedValue
                return
            }

            updateColorForCurrentRateValue()
            rateValueChangeCallback?(rateValue)
            redraw()
        }
    }

    /// Disable user interaction while still allowing the view to render a rate value.
    @IBInspectable open var isReadOnly: Bool = false {
        didSet {
            updateGestureAvailability()
        }
    }

    /// Allows taps on the view to set the rate value.
    @IBInspectable open var isTapToRateEnabled: Bool = true {
        didSet {
            updateGestureAvailability()
        }
    }

    /// If you are using this with a scroll view, for example, this allows the scroll view to recognize pan gestures at the same time.
    @IBInspectable open var recognizeSimultanousGestures: Bool = false

    /// Drag and tap mapping direction. Use TTGEmojiRateGestureDirection raw values.
    @IBInspectable open var rateGestureDirection: Int = TTGEmojiRateGestureDirection.vertical.rawValue {
        didSet {
            rateGestureDirection = clampedRawValue(rateGestureDirection, maxValue: TTGEmojiRateGestureDirection.horizontal.rawValue)
        }
    }

    /// Controls whether a custom emoji path replaces or overlays the built-in drawing.
    @IBInspectable open var customEmojiPathMode: Int = TTGEmojiRateCustomPathMode.builtIn.rawValue {
        didSet {
            customEmojiPathMode = clampedRawValue(customEmojiPathMode, maxValue: TTGEmojiRateCustomPathMode.overlay.rawValue)
            redraw()
        }
    }

    /// Swift-friendly full custom path provider.
    open var customEmojiPathProvider: TTGEmojiRateCustomPathProvider? {
        didSet {
            redraw()
        }
    }

    /// Swift-friendly custom face outline provider. Eyes, mouth, and accessories still use the built-in drawing.
    open var customFacePathProvider: TTGEmojiRateCustomFacePathProvider? {
        didSet {
            redraw()
        }
    }

    /// Objective-C friendly full custom path delegate.
    @objc open weak var customPathDelegate: TTGEmojiRateViewPathDelegate? {
        get {
            return customPathDelegateStorage
        }
        set {
            customPathDelegateStorage = newValue
            redraw()
        }
    }

    /// Current normalized rate progress, from 0 to 1.
    @objc open var rateProgress: CGFloat {
        return normalizedRateProgress
    }

    /// Callback when rateValue changes.
    open var rateValueChangeCallback: ((_ newRateValue: Float) -> Void)?

    /// Sensitivity when drag. From 1 to 10.
    @IBInspectable open var rateDragSensitivity: CGFloat = 5 {
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

    /// Sets the current rate value, optionally animating the path and color updates.
    @objc(setRateValue:animated:) open func setRateValue(_ value: Float, animated: Bool) {
        guard animated else {
            rateValue = value
            return
        }

        let oldPath = shapeLayer.path
        let oldColor = shapeLayer.presentation()?.strokeColor ?? shapeLayer.strokeColor
        rateValue = value
        let newPath = shapeLayer.path
        let newColor = shapeLayer.strokeColor

        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = oldPath
        pathAnimation.toValue = newPath
        pathAnimation.duration = 0.25
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = oldColor
        colorAnimation.toValue = newColor
        colorAnimation.duration = pathAnimation.duration
        colorAnimation.timingFunction = pathAnimation.timingFunction

        shapeLayer.add(pathAnimation, forKey: "TTGEmojiRate.path")
        shapeLayer.add(colorAnimation, forKey: "TTGEmojiRate.strokeColor")
    }

    /// Objective-C friendly color range setter.
    @objc(setRateColorFrom:to:) open func setRateColor(from fromColor: UIColor, to toColor: UIColor) {
        rateColorRange = (fromColor, toColor)
    }

    /// Objective-C friendly gradient color setter.
    @objc(setRateGradientColorFrom:to:) open func setRateGradientColor(from fromColor: UIColor, to toColor: UIColor) {
        rateGradientColors = [fromColor, toColor]
        rateGradientColorEnabled = true
    }

    /// Objective-C friendly rate value callback setter.
    @objc(setRateValueChangeCallback:) open func setRateValueChangeCallback(_ callback: ((Float) -> Void)?) {
        rateValueChangeCallback = callback
    }

    /// Objective-C friendly expression preset setter.
    @objc(setEmojiExpressionPresetValue:) open func setEmojiExpressionPreset(_ preset: TTGEmojiRateExpressionPreset) {
        emojiExpressionPreset = preset.rawValue
    }

    /// Objective-C friendly eye style setter.
    @objc(setEmojiEyeStyleValue:) open func setEmojiEyeStyle(_ style: TTGEmojiRateEyeStyle) {
        emojiEyeStyle = style.rawValue
    }

    /// Objective-C friendly mouth style setter.
    @objc(setEmojiMouthStyleValue:) open func setEmojiMouthStyle(_ style: TTGEmojiRateMouthStyle) {
        emojiMouthStyle = style.rawValue
    }

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
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }

    // MARK: -
    // MARK: Private methods.

    /**
    Init configure.
    */
    fileprivate func configure() {
        addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
        updateGestureAvailability()

        backgroundColor = backgroundColor ?? .white
        clearsContextBeforeDrawing = true
        isMultipleTouchEnabled = false

        faceFillLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        rateColorRange = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest)

        updateShapeLayerHost()
        redraw()
    }

    /**
     Redraw all lines.
     */
    fileprivate func redraw() {
        updateShapeLayerHost()
        shapeLayer.frame = self.bounds
        gradientLayer.frame = self.bounds
        gradientLayer.colors = resolvedGradientColors().map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: rateGradientStartPointX, y: rateGradientStartPointY)
        gradientLayer.endPoint = CGPoint(x: rateGradientEndPointX, y: rateGradientEndPointY)
        faceFillLayer.frame = self.bounds
        faceFillGradientLayer.frame = self.bounds
        faceFillGradientLayer.colors = resolvedFaceFillGradientColors().map { $0.cgColor }
        faceFillGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        faceFillGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        faceFillLayer.fillColor = resolvedFaceFillColor().cgColor
        shapeLayer.strokeColor = rateGradientColorEnabled ? UIColor.black.cgColor : rateColor.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = rateLineWidth

        shapePath.removeAllPoints()
        let facePath = facePathWithRect(self.bounds)
        let builtInPath = builtInEmojiPathWithRect(self.bounds)
        let customPath = customEmojiPathWithRect(self.bounds)
        faceFillLayer.path = facePath.cgPath

        switch resolvedCustomPathMode {
        case .builtIn:
            shapePath.append(builtInPath)
        case .replace:
            shapePath.append(customPath ?? builtInPath)
        case .overlay:
            shapePath.append(builtInPath)
            if let customPath {
                shapePath.append(customPath)
            }
        }

        shapeLayer.path = shapePath.cgPath
        setNeedsDisplay()
    }

    fileprivate func builtInEmojiPathWithRect(_ rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.append(facePathWithRect(rect))
        path.append(mouthPathWithRect(rect))
        path.append(eyePathWithRect(rect, isLeftEye: true))
        path.append(eyePathWithRect(rect, isLeftEye: false))
        path.append(eyebrowPathWithRect(rect, isLeftEye: true))
        path.append(eyebrowPathWithRect(rect, isLeftEye: false))
        path.append(accessoryPathWithRect(rect))
        return path
    }

    fileprivate func customEmojiPathWithRect(_ rect: CGRect) -> UIBezierPath? {
        if let customEmojiPathProvider {
            return customEmojiPathProvider(rect, normalizedRateProgress, self)
        }
        return customPathDelegateStorage?.emojiRateView(self, pathIn: rect, rateProgress: normalizedRateProgress)
    }

    fileprivate func updateShapeLayerHost() {
        updateFaceFillLayerHost()

        if rateGradientColorEnabled {
            if gradientLayer.superlayer == nil {
                layer.addSublayer(gradientLayer)
            }
            if shapeLayer.superlayer != nil {
                shapeLayer.removeFromSuperlayer()
            }
            gradientLayer.mask = shapeLayer
        } else {
            gradientLayer.mask = nil
            if gradientLayer.superlayer != nil {
                gradientLayer.removeFromSuperlayer()
            }
            if shapeLayer.superlayer == nil {
                layer.addSublayer(shapeLayer)
            }
        }
    }

    fileprivate func updateFaceFillLayerHost() {
        guard faceFillEnabled else {
            faceFillGradientLayer.mask = nil
            if faceFillGradientLayer.superlayer != nil {
                faceFillGradientLayer.removeFromSuperlayer()
            }
            if faceFillLayer.superlayer != nil {
                faceFillLayer.removeFromSuperlayer()
            }
            return
        }

        if faceFillGradientEnabled {
            if faceFillGradientLayer.superlayer == nil {
                layer.insertSublayer(faceFillGradientLayer, at: 0)
            }
            if faceFillLayer.superlayer != nil {
                faceFillLayer.removeFromSuperlayer()
            }
            faceFillGradientLayer.mask = faceFillLayer
        } else {
            faceFillGradientLayer.mask = nil
            if faceFillGradientLayer.superlayer != nil {
                faceFillGradientLayer.removeFromSuperlayer()
            }
            if faceFillLayer.superlayer == nil {
                layer.insertSublayer(faceFillLayer, at: 0)
            }
        }
    }

    fileprivate func resolvedGradientColors() -> [UIColor] {
        if rateGradientColors.isEmpty {
            return [rateColor, rateColor]
        }
        if rateGradientColors.count == 1 {
            return [rateGradientColors[0], rateGradientColors[0]]
        }
        return rateGradientColors
    }

    fileprivate func resolvedFaceFillGradientColors() -> [UIColor] {
        if faceFillGradientColors.isEmpty {
            return [resolvedFaceFillColor(), resolvedFaceFillColor()]
        }
        if faceFillGradientColors.count == 1 {
            return [faceFillGradientColors[0], faceFillGradientColors[0]]
        }
        return faceFillGradientColors
    }

    fileprivate func resolvedFaceFillColor() -> UIColor {
        guard faceFillDynamicColor else {
            return faceFillColor
        }

        return interpolatedColor(
            from: faceFillColorRange.from,
            to: faceFillColorRange.to,
            progress: normalizedRateProgress)
    }

    fileprivate func interpolatedColor(from fromColor: UIColor, to toColor: UIColor, progress: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        return UIColor(
            red: fromRed + (toRed - fromRed) * progress,
            green: fromGreen + (toGreen - fromGreen) * progress,
            blue: fromBlue + (toBlue - fromBlue) * progress,
            alpha: fromAlpha + (toAlpha - fromAlpha) * progress)
    }

    fileprivate func clampedRawValue(_ value: Int, maxValue: Int) -> Int {
        return min(max(value, 0), maxValue)
    }

    fileprivate func updateGestureAvailability() {
        panRecognizer.isEnabled = !isReadOnly
        tapRecognizer.isEnabled = !isReadOnly && isTapToRateEnabled
    }

    fileprivate func normalizedRateValue(_ value: Float) -> Float {
        let clampedValue = min(max(value, minimumRateValue), maximumRateValue)
        guard rateStep > 0 else {
            return clampedValue
        }

        let steps = round((clampedValue - minimumRateValue) / rateStep)
        let steppedValue = minimumRateValue + steps * rateStep
        return min(max(steppedValue, minimumRateValue), maximumRateValue)
    }

    fileprivate var normalizedRateProgress: CGFloat {
        let valueRange = maximumRateValue - minimumRateValue
        guard valueRange > 0 else {
            return 0
        }

        return CGFloat((rateValue - minimumRateValue) / valueRange)
    }

    fileprivate var resolvedExpressionPreset: TTGEmojiRateExpressionPreset {
        return TTGEmojiRateExpressionPreset(rawValue: emojiExpressionPreset) ?? .classic
    }

    fileprivate var resolvedEyeOverride: TTGEmojiRateEyeStyle {
        return TTGEmojiRateEyeStyle(rawValue: emojiEyeStyle) ?? .automatic
    }

    fileprivate var resolvedMouthOverride: TTGEmojiRateMouthStyle {
        return TTGEmojiRateMouthStyle(rawValue: emojiMouthStyle) ?? .automatic
    }

    fileprivate var resolvedGestureDirection: TTGEmojiRateGestureDirection {
        return TTGEmojiRateGestureDirection(rawValue: rateGestureDirection) ?? .vertical
    }

    fileprivate var resolvedCustomPathMode: TTGEmojiRateCustomPathMode {
        return TTGEmojiRateCustomPathMode(rawValue: customEmojiPathMode) ?? .builtIn
    }

    fileprivate var resolvedFaceShape: TTGEmojiRateFaceShape {
        return TTGEmojiRateFaceShape(rawValue: faceShape) ?? .circle
    }

    fileprivate func updateColorForCurrentRateValue() {
        guard rateDynamicColor else {
            return
        }

        let rate = normalizedRateProgress
        rateColor = UIColor(
            hue: hueFrom + hueDelta * rate,
            saturation: saturationFrom + saturationDelta * rate,
            brightness: brightnessFrom + brightnessDelta * rate,
            alpha: alphaFrom + alphaDelta * rate)
    }

    /**
     Generate face UIBezierPath

     - parameter rect: rect

     - returns: face UIBezierPath
     */
    fileprivate func facePathWithRect(_ rect: CGRect) -> UIBezierPath {
        if let customFacePathProvider {
            return customFacePathProvider(rect, normalizedRateProgress, self) ?? UIBezierPath()
        }

        guard resolvedFaceShape != .none else {
            return UIBezierPath()
        }

        let margin = rateFaceMargin + 2
        let faceRect = morphedFaceRect(rect.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)))

        switch resolvedFaceShape {
        case .circle:
            return UIBezierPath(ovalIn: faceRect)
        case .roundedSquare:
            return UIBezierPath(roundedRect: faceRect, cornerRadius: min(faceRect.width, faceRect.height) * 0.22)
        case .squircle:
            return squirclePath(in: faceRect)
        case .blob:
            return blobPath(in: faceRect)
        case .capsule:
            return UIBezierPath(roundedRect: faceRect.insetBy(dx: 0, dy: faceRect.height * 0.16), cornerRadius: faceRect.height * 0.34)
        case .shield:
            return shieldPath(in: faceRect)
        case .cloud:
            return cloudPath(in: faceRect)
        case .none:
            return UIBezierPath()
        }
    }

    fileprivate func morphedFaceRect(_ rect: CGRect) -> CGRect {
        guard faceShapeMorphEnabled else {
            return rect
        }

        let progress = normalizedRateProgress
        let verticalInset = rect.height * (0.05 - progress * 0.09)
        let horizontalInset = rect.width * (progress < 0.35 ? 0.02 : -0.02 * (progress - 0.35))
        return rect.insetBy(dx: horizontalInset, dy: verticalInset)
    }

    fileprivate func squirclePath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let radius = min(rect.width, rect.height) * 0.24
        let control = radius * 0.72
        let minX = rect.minX, maxX = rect.maxX, minY = rect.minY, maxY = rect.maxY

        path.move(to: CGPoint(x: minX + radius, y: minY))
        path.addLine(to: CGPoint(x: maxX - radius, y: minY))
        path.addCurve(to: CGPoint(x: maxX, y: minY + radius), controlPoint1: CGPoint(x: maxX - radius + control, y: minY), controlPoint2: CGPoint(x: maxX, y: minY + radius - control))
        path.addLine(to: CGPoint(x: maxX, y: maxY - radius))
        path.addCurve(to: CGPoint(x: maxX - radius, y: maxY), controlPoint1: CGPoint(x: maxX, y: maxY - radius + control), controlPoint2: CGPoint(x: maxX - radius + control, y: maxY))
        path.addLine(to: CGPoint(x: minX + radius, y: maxY))
        path.addCurve(to: CGPoint(x: minX, y: maxY - radius), controlPoint1: CGPoint(x: minX + radius - control, y: maxY), controlPoint2: CGPoint(x: minX, y: maxY - radius + control))
        path.addLine(to: CGPoint(x: minX, y: minY + radius))
        path.addCurve(to: CGPoint(x: minX + radius, y: minY), controlPoint1: CGPoint(x: minX, y: minY + radius - control), controlPoint2: CGPoint(x: minX + radius - control, y: minY))
        path.close()
        return path
    }

    fileprivate func blobPath(in rect: CGRect) -> UIBezierPath {
        let progress = normalizedRateProgress
        let path = UIBezierPath()
        let left = rect.minX + rect.width * (0.06 + progress * 0.02)
        let right = rect.maxX - rect.width * (0.04 + (1 - progress) * 0.02)
        let top = rect.minY + rect.height * (0.03 + (1 - progress) * 0.03)
        let bottom = rect.maxY - rect.height * (0.04 + progress * 0.02)
        let centerX = rect.midX

        path.move(to: CGPoint(x: centerX, y: top))
        path.addCurve(
            to: CGPoint(x: right, y: rect.midY),
            controlPoint1: CGPoint(x: rect.maxX - rect.width * 0.13, y: top - rect.height * 0.02),
            controlPoint2: CGPoint(x: right + rect.width * 0.04, y: rect.minY + rect.height * 0.34))
        path.addCurve(
            to: CGPoint(x: centerX, y: bottom),
            controlPoint1: CGPoint(x: right + rect.width * 0.02, y: rect.maxY - rect.height * 0.18),
            controlPoint2: CGPoint(x: rect.maxX - rect.width * 0.32, y: bottom + rect.height * 0.05))
        path.addCurve(
            to: CGPoint(x: left, y: rect.midY),
            controlPoint1: CGPoint(x: rect.minX + rect.width * 0.27, y: bottom - rect.height * 0.02),
            controlPoint2: CGPoint(x: left - rect.width * 0.04, y: rect.maxY - rect.height * 0.30))
        path.addCurve(
            to: CGPoint(x: centerX, y: top),
            controlPoint1: CGPoint(x: left - rect.width * 0.02, y: rect.minY + rect.height * 0.22),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.31, y: top - rect.height * 0.06))
        path.close()
        return path
    }

    fileprivate func shieldPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.02))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.22))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.02),
            controlPoint1: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.height * 0.58 + rect.minY),
            controlPoint2: CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.maxY - rect.height * 0.08))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.22),
            controlPoint1: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.maxY - rect.height * 0.08),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.03, y: rect.height * 0.58 + rect.minY))
        path.close()
        return path
    }

    fileprivate func cloudPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.maxY - rect.height * 0.26))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.43),
            controlPoint1: CGPoint(x: rect.minX + rect.width * 0.06, y: rect.maxY - rect.height * 0.25),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.minY + rect.height * 0.47))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.43, y: rect.minY + rect.height * 0.23),
            controlPoint1: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.26),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.minY + rect.height * 0.18))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.76, y: rect.minY + rect.height * 0.38),
            controlPoint1: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.minY + rect.height * 0.04),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.78, y: rect.minY + rect.height * 0.13))
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.maxY - rect.height * 0.24),
            controlPoint1: CGPoint(x: rect.maxX - rect.width * 0.04, y: rect.minY + rect.height * 0.34),
            controlPoint2: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.maxY - rect.height * 0.22))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.maxY - rect.height * 0.26))
        path.close()
        return path
    }

    /**
     Generate mouth UIBezierPath

     - parameter rect: rect

     - returns: mouth UIBezierPath
     */
    fileprivate func mouthPathWithRect(_ rect: CGRect) -> UIBezierPath {
        let style = resolvedMouthStyle()
        if style != .classic {
            return mouthPathWithRect(rect, style: style)
        }

        let width = rect.width
        let height = rect.width

        let leftPoint = CGPoint(
            x: width * (1 - rateMouthWidth) / 2,
            y: height * (1 - rateMouthVerticalPosition))

        let rightPoint = CGPoint(
            x: width - leftPoint.x,
            y: leftPoint.y)

        let centerPoint = CGPoint(
            x: width / 2,
            y: leftPoint.y + height * 0.3 * (normalizedRateProgress - 0.5))

        let halfLipWidth = width * rateMouthWidth * rateLipWidth / 2

        let mouthPath = UIBezierPath()
        mouthPath.move(to: leftPoint)

        mouthPath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - halfLipWidth, y: centerPoint.y))

        mouthPath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + halfLipWidth, y: centerPoint.y),
            controlPoint2: rightPoint)

        return mouthPath
    }

    fileprivate func resolvedMouthStyle() -> TTGEmojiRateMouthStyle {
        let override = resolvedMouthOverride
        if override != .automatic {
            return override
        }

        let progress = normalizedRateProgress
        switch resolvedExpressionPreset {
        case .classic:
            return .classic
        case .minimal:
            if progress < 0.36 {
                return .frown
            }
            if progress > 0.64 {
                return .smile
            }
            return .flat
        case .diagnostic:
            if progress < 0.22 {
                return .smirk
            }
            if progress < 0.44 {
                return .frown
            }
            if progress > 0.76 {
                return .smile
            }
            return .flat
        case .playful:
            if progress > 0.86 {
                return .openSmile
            }
            if progress < 0.18 {
                return .surprise
            }
            if progress < 0.42 {
                return .frown
            }
            return .smile
        case .expressive:
            if progress < 0.16 {
                return .frown
            }
            if progress < 0.38 {
                return .frown
            }
            if progress < 0.58 {
                return .flat
            }
            if progress > 0.9 {
                return .openSmile
            }
            return .smile
        }
    }

    fileprivate func mouthPathWithRect(_ rect: CGRect, style: TTGEmojiRateMouthStyle) -> UIBezierPath {
        let width = rect.width
        let height = rect.width
        let mouthY = height * (1 - rateMouthVerticalPosition)
        let mouthWidth = width * rateMouthWidth
        let leftPoint = CGPoint(x: (width - mouthWidth) / 2, y: mouthY)
        let rightPoint = CGPoint(x: (width + mouthWidth) / 2, y: mouthY)
        let lip = width * rateMouthWidth * rateLipWidth / 2
        let path = UIBezierPath()

        switch style {
        case .smile:
            path.move(to: leftPoint)
            let center = CGPoint(x: width / 2, y: mouthY + height * 0.14)
            path.addCurve(to: center, controlPoint1: leftPoint, controlPoint2: CGPoint(x: center.x - lip, y: center.y))
            path.addCurve(to: rightPoint, controlPoint1: CGPoint(x: center.x + lip, y: center.y), controlPoint2: rightPoint)

        case .frown:
            path.move(to: leftPoint)
            let center = CGPoint(x: width / 2, y: mouthY - height * 0.13)
            path.addCurve(to: center, controlPoint1: leftPoint, controlPoint2: CGPoint(x: center.x - lip, y: center.y))
            path.addCurve(to: rightPoint, controlPoint1: CGPoint(x: center.x + lip, y: center.y), controlPoint2: rightPoint)

        case .flat:
            path.move(to: CGPoint(x: width * 0.30, y: mouthY))
            path.addLine(to: CGPoint(x: width * 0.70, y: mouthY))

        case .openSmile:
            let rect = CGRect(x: width * 0.31, y: height * 0.58, width: width * 0.38, height: height * 0.20)
            path.append(UIBezierPath(ovalIn: rect))

        case .surprise:
            let diameter = width * 0.20
            let rect = CGRect(x: width * 0.5 - diameter / 2, y: height * 0.58, width: diameter, height: diameter * 1.18)
            path.append(UIBezierPath(ovalIn: rect))

        case .smirk:
            path.move(to: CGPoint(x: width * 0.31, y: mouthY - height * 0.015))
            path.addCurve(
                to: CGPoint(x: width * 0.70, y: mouthY + height * 0.08),
                controlPoint1: CGPoint(x: width * 0.41, y: mouthY - height * 0.09),
                controlPoint2: CGPoint(x: width * 0.58, y: mouthY + height * 0.1))

        case .automatic, .classic:
            return mouthPathWithRect(rect)
        }

        return path
    }

    /**
     Generate eye UIBezierPath

     - parameter rect:      rect
     - parameter isLeftEye: is left eye

     - returns: eye UIBezierPath
     */
    fileprivate func eyePathWithRect(_ rect: CGRect, isLeftEye: Bool) -> UIBezierPath {
        if !rateShowEyes {
            return UIBezierPath()
        }

        let style = resolvedEyeStyle(isLeftEye: isLeftEye)
        if style != .classic {
            return eyePathWithRect(rect, isLeftEye: isLeftEye, style: style)
        }

        let width = rect.width
        let height = rect.width

        let centerPoint = CGPoint(
            x: width * (isLeftEye ? 0.30 : 0.70),
            y: height * (1 - rateEyeVerticalPosition) - height * 0.1 * max(normalizedRateProgress - 0.5, 0))

        let leftPoint = CGPoint(
            x: centerPoint.x - rateEyeWidth / 2 * width,
            y: height * (1 - rateEyeVerticalPosition))

        let rightPoint = CGPoint(
            x: centerPoint.x + rateEyeWidth / 2 * width,
            y: leftPoint.y)

        let eyePath = UIBezierPath()
        eyePath.move(to: leftPoint)

        eyePath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - width * 0.06, y: centerPoint.y))

        eyePath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + width * 0.06, y: centerPoint.y),
            controlPoint2: rightPoint)

        return eyePath
    }

    fileprivate func resolvedEyeStyle(isLeftEye: Bool) -> TTGEmojiRateEyeStyle {
        let override = resolvedEyeOverride
        if override != .automatic {
            return override
        }

        let progress = normalizedRateProgress
        switch resolvedExpressionPreset {
        case .classic:
            return .classic
        case .minimal:
            return .sleepy
        case .diagnostic:
            if progress < 0.2 {
                return isLeftEye ? .angry : .round
            }
            if progress < 0.44 {
                return .sleepy
            }
            if progress > 0.82 {
                return .classic
            }
            return .round
        case .playful:
            if progress > 0.92 {
                return isLeftEye ? .star : .heart
            }
            if progress > 0.78 {
                return .heart
            }
            if progress < 0.18 {
                return .round
            }
            return .classic
        case .expressive:
            if progress < 0.18 {
                return .angry
            }
            if progress < 0.42 {
                return .round
            }
            if progress > 0.9 {
                return .sleepy
            }
            return .classic
        }
    }

    fileprivate func eyePathWithRect(_ rect: CGRect, isLeftEye: Bool, style: TTGEmojiRateEyeStyle) -> UIBezierPath {
        let width = rect.width
        let height = rect.width
        let center = CGPoint(
            x: width * (isLeftEye ? 0.30 : 0.70),
            y: height * (1 - rateEyeVerticalPosition) - height * 0.08 * max(normalizedRateProgress - 0.5, 0))
        let eyeWidth = width * rateEyeWidth
        let path = UIBezierPath()

        switch style {
        case .round:
            let radius = eyeWidth * 0.34
            path.append(UIBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)))

        case .wink, .sleepy:
            path.move(to: CGPoint(x: center.x - eyeWidth * 0.5, y: center.y))
            path.addCurve(
                to: CGPoint(x: center.x + eyeWidth * 0.5, y: center.y),
                controlPoint1: CGPoint(x: center.x - eyeWidth * 0.22, y: center.y + height * 0.035),
                controlPoint2: CGPoint(x: center.x + eyeWidth * 0.22, y: center.y + height * 0.035))

        case .star:
            path.append(starPath(center: center, radius: eyeWidth * 0.48, points: 5))

        case .heart:
            path.append(heartPath(center: center, size: eyeWidth * 0.82))

        case .angry:
            let direction: CGFloat = isLeftEye ? 1 : -1
            path.move(to: CGPoint(x: center.x - eyeWidth * 0.46, y: center.y - direction * height * 0.025))
            path.addLine(to: CGPoint(x: center.x + eyeWidth * 0.46, y: center.y + direction * height * 0.025))

        case .automatic, .classic:
            return eyePathWithRect(rect, isLeftEye: isLeftEye)
        }

        return path
    }

    fileprivate func eyebrowPathWithRect(_ rect: CGRect, isLeftEye: Bool) -> UIBezierPath {
        guard emojiShowAccessories else {
            return UIBezierPath()
        }

        let preset = resolvedExpressionPreset
        let progress = normalizedRateProgress
        guard preset == .expressive || preset == .diagnostic || (preset == .playful && progress < 0.3) else {
            return UIBezierPath()
        }

        let width = rect.width
        let height = rect.width
        let centerX = width * (isLeftEye ? 0.30 : 0.70)
        let baseY = height * 0.29
        let length = width * 0.14 * emojiAccessoryScale
        let slant: CGFloat

        if progress < 0.24 {
            slant = isLeftEye ? -height * 0.045 : height * 0.045
        } else if progress < 0.48 {
            slant = isLeftEye ? height * 0.03 : -height * 0.03
        } else {
            return UIBezierPath()
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: centerX - length / 2, y: baseY + slant))
        path.addLine(to: CGPoint(x: centerX + length / 2, y: baseY - slant))
        return path
    }

    fileprivate func accessoryPathWithRect(_ rect: CGRect) -> UIBezierPath {
        guard emojiShowAccessories, emojiAccessoryScale > 0 else {
            return UIBezierPath()
        }

        let progress = normalizedRateProgress
        let width = rect.width
        let height = rect.width
        let path = UIBezierPath()

        switch resolvedExpressionPreset {
        case .classic, .minimal:
            return path

        case .expressive:
            if progress < 0.24 {
                path.append(tearPath(center: CGPoint(x: width * 0.73, y: height * 0.45), size: width * 0.075 * emojiAccessoryScale))
            } else if progress > 0.72 {
                path.append(blushPath(center: CGPoint(x: width * 0.23, y: height * 0.54), size: width * 0.12 * emojiAccessoryScale))
                path.append(blushPath(center: CGPoint(x: width * 0.77, y: height * 0.54), size: width * 0.12 * emojiAccessoryScale))
            }
            if progress > 0.92 {
                path.append(sparklePath(center: CGPoint(x: width * 0.82, y: height * 0.22), size: width * 0.08 * emojiAccessoryScale))
            }

        case .playful:
            if progress > 0.72 {
                path.append(blushPath(center: CGPoint(x: width * 0.22, y: height * 0.55), size: width * 0.12 * emojiAccessoryScale))
                path.append(blushPath(center: CGPoint(x: width * 0.78, y: height * 0.55), size: width * 0.12 * emojiAccessoryScale))
            }
            if progress > 0.88 {
                path.append(sparklePath(center: CGPoint(x: width * 0.17, y: height * 0.22), size: width * 0.07 * emojiAccessoryScale))
                path.append(sparklePath(center: CGPoint(x: width * 0.84, y: height * 0.25), size: width * 0.08 * emojiAccessoryScale))
            }

        case .diagnostic:
            if progress < 0.22 {
                path.append(sweatPath(center: CGPoint(x: width * 0.77, y: height * 0.34), size: width * 0.07 * emojiAccessoryScale))
            } else if progress < 0.42 {
                path.append(tearPath(center: CGPoint(x: width * 0.28, y: height * 0.46), size: width * 0.058 * emojiAccessoryScale))
            } else if progress > 0.8 {
                path.append(blushPath(center: CGPoint(x: width * 0.77, y: height * 0.55), size: width * 0.1 * emojiAccessoryScale))
            }
        }

        return path
    }

    fileprivate func starPath(center: CGPoint, radius: CGFloat, points: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let count = max(points * 2, 4)
        for index in 0..<count {
            let angle = CGFloat(index) * .pi * 2 / CGFloat(count) - .pi / 2
            let pointRadius = index.isMultiple(of: 2) ? radius : radius * 0.42
            let point = CGPoint(x: center.x + cos(angle) * pointRadius, y: center.y + sin(angle) * pointRadius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        return path
    }

    fileprivate func heartPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let top = CGPoint(x: center.x, y: center.y - size * 0.18)
        path.move(to: top)
        path.addCurve(
            to: CGPoint(x: center.x - size * 0.5, y: center.y - size * 0.05),
            controlPoint1: CGPoint(x: center.x - size * 0.18, y: center.y - size * 0.5),
            controlPoint2: CGPoint(x: center.x - size * 0.5, y: center.y - size * 0.35))
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + size * 0.5),
            controlPoint1: CGPoint(x: center.x - size * 0.5, y: center.y + size * 0.18),
            controlPoint2: CGPoint(x: center.x - size * 0.18, y: center.y + size * 0.34))
        path.addCurve(
            to: CGPoint(x: center.x + size * 0.5, y: center.y - size * 0.05),
            controlPoint1: CGPoint(x: center.x + size * 0.18, y: center.y + size * 0.34),
            controlPoint2: CGPoint(x: center.x + size * 0.5, y: center.y + size * 0.18))
        path.addCurve(
            to: top,
            controlPoint1: CGPoint(x: center.x + size * 0.5, y: center.y - size * 0.35),
            controlPoint2: CGPoint(x: center.x + size * 0.18, y: center.y - size * 0.5))
        return path
    }

    fileprivate func tearPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x, y: center.y - size * 0.62))
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + size * 0.62),
            controlPoint1: CGPoint(x: center.x - size * 0.55, y: center.y - size * 0.08),
            controlPoint2: CGPoint(x: center.x - size * 0.42, y: center.y + size * 0.62))
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - size * 0.62),
            controlPoint1: CGPoint(x: center.x + size * 0.42, y: center.y + size * 0.62),
            controlPoint2: CGPoint(x: center.x + size * 0.55, y: center.y - size * 0.08))
        return path
    }

    fileprivate func sweatPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let path = tearPath(center: center, size: size)
        let shine = UIBezierPath()
        shine.move(to: CGPoint(x: center.x - size * 0.18, y: center.y - size * 0.06))
        shine.addLine(to: CGPoint(x: center.x + size * 0.02, y: center.y - size * 0.28))
        path.append(shine)
        return path
    }

    fileprivate func blushPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x - size * 0.5, y: center.y))
        path.addLine(to: CGPoint(x: center.x + size * 0.5, y: center.y))
        path.move(to: CGPoint(x: center.x - size * 0.34, y: center.y + size * 0.22))
        path.addLine(to: CGPoint(x: center.x + size * 0.34, y: center.y + size * 0.22))
        return path
    }

    fileprivate func sparklePath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x, y: center.y - size))
        path.addLine(to: CGPoint(x: center.x, y: center.y + size))
        path.move(to: CGPoint(x: center.x - size, y: center.y))
        path.addLine(to: CGPoint(x: center.x + size, y: center.y))
        path.move(to: CGPoint(x: center.x - size * 0.58, y: center.y - size * 0.58))
        path.addLine(to: CGPoint(x: center.x + size * 0.58, y: center.y + size * 0.58))
        path.move(to: CGPoint(x: center.x + size * 0.58, y: center.y - size * 0.58))
        path.addLine(to: CGPoint(x: center.x - size * 0.58, y: center.y + size * 0.58))
        return path
    }

    // MARK: Handling pan gestures.

    @objc fileprivate func panGestureAction(_ sender: UIPanGestureRecognizer) {
        guard !isReadOnly else {
            return
        }

        switch sender.state {
        case .began:
            touchPoint = sender.location(in: self)
            if resolvedGestureDirection == .horizontal, let touchPoint {
                setRateValue(rateValue(for: touchPoint), animated: false)
            }

        case .changed:
            guard let touchPoint else {
                return
            }

            let currentPoint = sender.location(in: self)
            switch resolvedGestureDirection {
            case .horizontal:
                setRateValue(rateValue(for: currentPoint), animated: false)
            case .vertical:
                let dragProgress = Float((currentPoint.y - touchPoint.y) / bounds.height * rateDragSensitivity)
                let valueDelta = dragProgress * (maximumRateValue - minimumRateValue)
                rateValue += valueDelta
                self.touchPoint = currentPoint
            }

        case .ended, .cancelled, .failed:
            touchPoint = nil

        default:
            break
        }
    }

    @objc fileprivate func tapGestureAction(_ sender: UITapGestureRecognizer) {
        guard !isReadOnly, isTapToRateEnabled, bounds.height > 0, bounds.width > 0 else {
            return
        }

        let location = sender.location(in: self)
        setRateValue(rateValue(for: location), animated: true)
    }

    fileprivate func rateValue(for location: CGPoint) -> Float {
        let rawProgress: CGFloat
        switch resolvedGestureDirection {
        case .horizontal:
            rawProgress = location.x / bounds.width
        case .vertical:
            rawProgress = location.y / bounds.height
        }
        let progress = min(max(rawProgress, 0), 1)
        return minimumRateValue + Float(progress) * (maximumRateValue - minimumRateValue)
    }
}

extension EmojiRateView : UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panRecognizer else {
            return true
        }

        let velocity = panRecognizer.velocity(in: self)
        switch resolvedGestureDirection {
        case .horizontal:
            return abs(velocity.x) > abs(velocity.y)
        case .vertical:
            return abs(velocity.y) > abs(velocity.x)
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return recognizeSimultanousGestures
    }
}
