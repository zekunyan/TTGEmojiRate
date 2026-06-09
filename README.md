# TTGEmojiRate
An emoji-like rating view for iOS, implemented in **Swift 5.9**.

**Android version: [PeterSmileRate](https://github.com/SilicorniO/PeterSmileRate) by [SilicorniO](https://github.com/SilicorniO). Great work ! :)**

[![Build Status](https://travis-ci.org/zekunyan/TTGEmojiRate.svg?branch=master)](https://travis-ci.org/zekunyan/TTGEmojiRate)
[![Version](https://img.shields.io/cocoapods/v/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![License](https://img.shields.io/cocoapods/l/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![Platform](https://img.shields.io/cocoapods/p/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift/)

[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%2060-blue.svg)](https://github.com/zekunyan/TTGEmojiRate)
[![Total Download](https://img.shields.io/badge/Total%20Download-%3E%201,214-blue.svg)](https://github.com/zekunyan/TTGEmojiRate)

![Screenshot](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_example.gif)

**Inspired by [Rating Version A - Hoang Nguyen](https://dribbble.com/shots/2211556-Rating-Version-A)**

![Rating Version A - Hoang Nguyen](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_Dribbble.gif)

**Blog**
[土土哥的技术Blog - Swift开源项目: TTGEmojiRate的实现](http://tutuge.me/2015/10/25/ttgemojirate-lib/)

## Features
* More interactive with Emoji, drag gesture, and tap-to-rate.
* Highly customizable.
* Configurable rating ranges and step values for 5-star, 10-point, NPS, and survey-style scoring.
* Optional read-only display mode and animated programmatic value updates.
* Can be used in Interface Builder.
* Supports Swift and Objective-C example apps.

![IB example](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_1.png)

## What
TTGEmojiRate is an emoji-like rating view for iOS which is implemented in Swift.
You can drag up and down or tap on the Emoji face to change the rate, which is more interactive.
TTGEmojiRate is also highly customizable: many features can be configured, such as the rating range, step value, emoji line width, mouth width, color range, read-only mode, and gesture sensitivity.

## Usage
### Use TTGEmojiRate

1. Create an instance of `EmojiRateView` and add it to the parent view.
```swift
let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
rateView.minimumRateValue = 0
rateView.maximumRateValue = 10
rateView.rateStep = 0.5
rateView.center = view.center
view.addSubview(rateView)
```

2. Drop a view in Interface Builder and set the `Custom Class` to `EmojiRateView`.

### Run examples
To run the example projects, clone the repo and run `pod install` from `Example-Swift` or `Example-Objc` first.

## Requirements
* Swift 5.9
* Xcode 15 or later
* iOS 16.0 or later

## Installation
### CocoaPods
You can use [CocoaPods](http://cocoapods.org) to install `TTGEmojiRate` by adding it to your `Podfile`:

```ruby
pod "TTGEmojiRate"
```

### Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install `TTGEmojiRate` by adding it to your `Cartfile`:
```
github "zekunyan/TTGEmojiRate"
```

## Customization
![Customization](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_2.png)

#### rateValueChangeCallback
`rateValueChangeCallback: ((Float) -> Void)?` defines the callback closure when `rateValue` changes.
```swift
emojiRateView.rateValueChangeCallback = { rateValue in
    NSLog("The new rate value is: \(rateValue)")
}
```

#### Rating range and step
`minimumRateValue`, `maximumRateValue`, and `rateStep` let the same control support continuous 0-5 ratings, 10-point ratings, whole-number survey scores, or half-step ratings.
```swift
emojiRateView.minimumRateValue = 1
emojiRateView.maximumRateValue = 10
emojiRateView.rateStep = 0.5
emojiRateView.setRateValue(7.5, animated: true)
```

#### Read-only and tap-to-rate
`isReadOnly` disables user gestures while keeping the current value visible. `isTapToRateEnabled` controls whether taps can update the rating.
```swift
emojiRateView.isReadOnly = false
emojiRateView.isTapToRateEnabled = true
```

#### Objective-C helpers
Objective-C callers can use selector-friendly APIs for animated value changes and color ranges.
```objective-c
[rateView setRateValue:6 animated:YES];
[rateView setRateColorFrom:[UIColor systemRedColor] to:[UIColor systemGreenColor]];
```

#### rateColorRange
`rateColorRange: (from: UIColor, to: UIColor)`
When `rateValue` moves from `minimumRateValue` to `maximumRateValue`, the `rateColor` will change from the `from` color to the `to` color.
```swift
emojiRateView.rateColorRange = (
    UIColor.red,
    UIColor.green
)
```

#### rateDragSensitivity
`rateDragSensitivity: CGFloat` defines the sensitivity when dragging to change `rateValue`.

## Suggested next steps
* **Performance:** Cache computed face, mouth, and eye paths per bounds/configuration and redraw only when inputs change; split face, mouth, and eye drawing into separate layers for cheaper partial updates.
* **Extensibility:** Add a style/configuration object and Swift Package Manager support for modern dependency managers.
* **Ease of use:** Provide delegate and Combine-style publisher APIs in addition to the callback, plus accessibility labels/adjustable actions for VoiceOver.
* **More scenarios:** Add horizontal drag mode, Dynamic Type-aware labels, dark mode presets, and right-to-left layout validation.
* **Testing:** Expand unit tests for color interpolation, gesture handling, and path generation; add UI snapshot tests for common styles.
* **Examples:** Keep both Swift and Objective-C demos current, and add a SwiftUI wrapper demo for apps that embed UIKit controls in SwiftUI.

## Author
zekunyan, zekunyan@163.com

## License
TTGEmojiRate is available under the MIT license. See the LICENSE file for more info.
