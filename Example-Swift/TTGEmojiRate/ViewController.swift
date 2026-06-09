//
//  ViewController.swift
//  TTGEmojiRate
//
//  Created by zekunyan on 10/17/2015.
//  Copyright (c) 2015 zekunyan. All rights reserved.
//

import UIKit
import TTGEmojiRate

class ViewController: UIViewController {
    @IBOutlet weak var rateValueLabel: UILabel!
    @IBOutlet weak var emojiRateView: EmojiRateView!

    let ratingTexts = ["Very bad", "Bad", "Normal", "Good", "Very good", "Perfect"]

    override func viewDidLoad() {
        super.viewDidLoad()

        emojiRateView.minimumRateValue = 0
        emojiRateView.maximumRateValue = 10
        emojiRateView.rateStep = 0.5
        emojiRateView.isTapToRateEnabled = true

        emojiRateView.rateValueChangeCallback = { [weak self] rateValue in
            guard let self else { return }
            let rateRange = emojiRateView.maximumRateValue - emojiRateView.minimumRateValue
            let progress = rateRange > 0 ? (rateValue - emojiRateView.minimumRateValue) / rateRange : 0
            let normalizedIndex = min(Int(progress * Float(ratingTexts.count - 1)), ratingTexts.count - 1)
            rateValueLabel.text = String(
                format: "%.1f / %.1f, %@",
                rateValue,
                emojiRateView.maximumRateValue,
                ratingTexts[normalizedIndex])
        }
        emojiRateView.setRateValue(5, animated: false)
    }

    // Actions

    @IBAction func showEyesChanged(_ sender: UISwitch) {
        emojiRateView.rateShowEyes = sender.isOn
    }

    @IBAction func makeRandomColorRange(_ sender: UIButton) {
        emojiRateView.rateColorRange = (newRandomColor(), newRandomColor())
    }

    @IBAction func rateLineWidthChanged(_ sender: UISlider) {
        emojiRateView.rateLineWidth = CGFloat(sender.value)
    }

    @IBAction func mouthWidthChanged(_ sender: UISlider) {
        emojiRateView.rateMouthWidth = CGFloat(sender.value)
    }

    @IBAction func lipWidthChanged(_ sender: UISlider) {
        emojiRateView.rateLipWidth = CGFloat(sender.value)
    }

    @IBAction func eyeWidthChanged(_ sender: UISlider) {
        emojiRateView.rateEyeWidth = CGFloat(sender.value)
    }

    private func newRandomColor() -> UIColor {
        UIColor(hue: newRandomNumber(), saturation: newRandomNumber(), brightness: newRandomNumber(), alpha: 1)
    }

    private func newRandomNumber() -> CGFloat {
        CGFloat.random(in: 0...1)
    }
}

