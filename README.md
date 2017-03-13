# TTGEmojiRate
An emoji-liked rating view for iOS, implemented in **Swift3**. 

[![Build Status](https://travis-ci.org/zekunyan/TTGEmojiRate.svg?branch=master)](https://travis-ci.org/zekunyan/TTGEmojiRate)
[![Version](https://img.shields.io/cocoapods/v/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![License](https://img.shields.io/cocoapods/l/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![Platform](https://img.shields.io/cocoapods/p/TTGEmojiRate.svg?style=flat)](http://cocoapods.org/pods/TTGEmojiRate)
[![Swift3](https://img.shields.io/badge/Swift-3-orange.svg)](https://developer.apple.com/swift/)

[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%2060-blue.svg)](https://github.com/zekunyan/TTGEmojiRate)
[![Total Download](https://img.shields.io/badge/Total%20Download-%3E%201,214-blue.svg)](https://github.com/zekunyan/TTGEmojiRate)

![Screenshot](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_example.gif)

**Inspired by [Rating Version A - Hoang Nguyen](https://dribbble.com/shots/2211556-Rating-Version-A)**

![Rating Version A - Hoang Nguyen](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_Dribbble.gif)

**Blog**  
[土土哥的技术Blog - Swift开源项目: TTGEmojiRate的实现](http://tutuge.me/2015/10/25/ttgemojirate-lib/)

## Features
* More interactive with Emoji and drag gesture.
* Highly customizable.
* Can be used in Interface Builder.

![IB example](https://github.com/zekunyan/TTGEmojiRate/raw/master/Resources/TTGEmojiRate_1.png)

## What
TTGEmojiRate is an emoji-liked rating view for iOS which is implemented in Swift.  
You can drop up and down on the Emoji face to change the rate, which is more interactive.  
TTGEmojiRate is also highly customizable that many features of it can be configure, like the emoji line width and the mouth width.

## Usage
### Use TTGEmojiRate

1. Create an instance of EmojiRateView and add it to the parent view.
```Swift
let rateView = EmojiRateView.init(frame: CGRectMake(0, 0, 200, 200))
rateView.center = self.view.center
self.view.addSubview(rateView)
```

2. Drop a view in the Interface builder and set the `Custom Class` to `EmojiRateView`

### Run example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
Swift3.  
Xcode8.  
iOS 8 and later.

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
`rateValueChangeCallback: ((newRateValue: Float) -> Void)?` defines the callback closure when `rateValue` changes.
```Swift
emojiRateView.rateValueChangeCallback = {(rateValue: Float) -> Void in
    NSLog("The new rate value is: \(rateValue)")
}
```

#### rateColorRange
`rateColorRange: (from: UIColor, to: UIColor)`  
When `rateValue` changes from 0 to 5, the `rateColor` will change from the `from: UIColor` to `to: UIColor`.
```
emojiRateView.rateColorRange = (
    UIColor.redColor(), 
    UIColor.greenColor()
)
```

#### rateDragSensitivity
`rateDragSensitivity: CGFloat` defines the sensitivity when drag to change rateValue. 

## Author
zekunyan, zekunyan@163.com

## License
TTGEmojiRate is available under the MIT license. See the LICENSE file for more info.


