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
        
        emojiRateView.rateValueChangeCallback = {(rateValue: Float) -> Void in
            self.rateValueLabel.text = String(
                format: "%.2f / 5.0, %@",
                rateValue, self.ratingTexts[Int(rateValue)])
        }
    }
    
    // Actions
    
    @IBAction func showEyesChanged(sender: UISwitch) {
        emojiRateView.rateShowEyes = sender.isOn
    }
    
    @IBAction func makeRandomColorRange(sender: UIButton) {
        emojiRateView.rateColorRange = (newRandomColor(), newRandomColor())
    }
    
    @IBAction func rateLineWidthChanged(sender: UISlider) {
        emojiRateView.rateLineWidth = CGFloat(sender.value)
    }
 
    @IBAction func mouthWidthChanged(sender: UISlider) {
        emojiRateView.rateMouthWidth = CGFloat(sender.value)
    }
    
    @IBAction func lipWidthChanged(sender: UISlider) {
        emojiRateView.rateLipWidth = CGFloat(sender.value)
    }
    
    @IBAction func eyeWidthChanged(sender: UISlider) {
        emojiRateView.rateEyeWidth = CGFloat(sender.value)
    }
    
    private func newRandomColor() -> UIColor {
        return UIColor.init(hue: newRandomNumber(), saturation: newRandomNumber(), brightness: newRandomNumber(), alpha: newRandomNumber())
    }
    
    private func newRandomNumber() -> CGFloat {

        return CGFloat(Double(Int(arc4random()) % 1000) / 1000)
    }
}

