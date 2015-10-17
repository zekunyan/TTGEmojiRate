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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emojiRateView.rateValueChangeCallback = {(rateValue: Float) -> Void in
            self.rateValueLabel.text = String(format: "%.2f / 5.0", rateValue)
        }
    }
    
    // Actions
    
    @IBAction func showEyesChanged(sender: UISwitch) {
        emojiRateView.rateShowEyes = sender.on
    }
    
    @IBAction func showDynamicColorChanged(sender: UISwitch) {
        emojiRateView.rateDynamicColor = sender.on
    }
    
    @IBAction func rateLineWidthChanged(sender: UISlider) {
        emojiRateView.rateLineWidth = CGFloat(sender.value)
    }
 
    @IBAction func mouthWidthChanged(sender: UISlider) {
        emojiRateView.rateMouthWidth = CGFloat(sender.value)
    }
    
    @IBAction func eyeWidthChanged(sender: UISlider) {
        emojiRateView.rateEyeWidth = CGFloat(sender.value)
    }
}

