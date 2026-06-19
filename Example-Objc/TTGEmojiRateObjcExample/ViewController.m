//
//  ViewController.m
//  TTGEmojiRateObjcExample
//
//  Created by zorro on 16/5/18.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "ViewController.h"

@import TTGEmojiRate;

typedef NS_ENUM(NSInteger, ObjcDemoCardLayout) {
    ObjcDemoCardLayoutCompact,
    ObjcDemoCardLayoutWide
};

typedef NS_ENUM(NSInteger, ObjcDemoPathKind) {
    ObjcDemoPathKindNone,
    ObjcDemoPathKindWaveform,
    ObjcDemoPathKindLightning,
    ObjcDemoPathKindCrown,
    ObjcDemoPathKindDiamond
};

static UIColor *ObjcDemoBackgroundColor(void) {
    return [UIColor colorWithRed:0.965 green:0.976 blue:0.988 alpha:1.0];
}

static NSString *ObjcDemoValueText(float value, float maximum) {
    return [NSString stringWithFormat:@"%.1f / %.0f", value, maximum];
}

static UIStackView *ObjcDemoControlRow(NSString *title, UIView *control) {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    label.textColor = UIColor.secondaryLabelColor;
    [label.widthAnchor constraintEqualToConstant:70].active = YES;

    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[label, control]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    row.spacing = 8;
    return row;
}

@interface ObjcDemoScrollView : UIScrollView
@end

@interface ObjcDemoPathDelegate : NSObject <TTGEmojiRateViewPathDelegate>
@property (nonatomic) ObjcDemoPathKind kind;
- (instancetype)initWithKind:(ObjcDemoPathKind)kind;
@end

@interface ObjcDemoCase : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caseDescription;
@property (nonatomic) float value;
@property (nonatomic) float minimum;
@property (nonatomic) float maximum;
@property (nonatomic) float step;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *colorFrom;
@property (nonatomic, strong) UIColor *colorTo;
@property (nonatomic, strong) UIColor *gradientFrom;
@property (nonatomic, strong) UIColor *gradientTo;
@property (nonatomic) BOOL gradientEnabled;
@property (nonatomic) NSInteger gestureDirection;
@property (nonatomic) BOOL tapToRateEnabled;
@property (nonatomic) BOOL readOnly;
@property (nonatomic) CGFloat dragSensitivity;
@property (nonatomic) BOOL showsSlider;
@property (nonatomic, copy) NSString *dragTip;
@property (nonatomic) BOOL fullWidth;
@property (nonatomic) NSInteger expressionPreset;
@property (nonatomic) NSInteger eyeStyle;
@property (nonatomic) NSInteger mouthStyle;
@property (nonatomic) BOOL showAccessories;
@property (nonatomic) CGFloat accessoryScale;
@property (nonatomic) NSInteger faceShape;
@property (nonatomic) BOOL faceShapeMorphEnabled;
@property (nonatomic) BOOL faceFillEnabled;
@property (nonatomic, strong) UIColor *faceFillColor;
@property (nonatomic) BOOL faceFillDynamicColor;
@property (nonatomic) BOOL faceFillGradientEnabled;
@property (nonatomic) NSInteger customPathMode;
@property (nonatomic) ObjcDemoPathKind pathKind;
@property (nonatomic, copy) NSString *code;
+ (instancetype)caseWithTitle:(NSString *)title description:(NSString *)description value:(float)value;
@end

@interface ObjcDemoPage : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pageDescription;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, copy) NSArray<ObjcDemoCase *> *cases;
+ (instancetype)pageWithTitle:(NSString *)title description:(NSString *)description accentColor:(UIColor *)accentColor cases:(NSArray<ObjcDemoCase *> *)cases;
@end

@interface ObjcCodeBlockView : UIView
- (instancetype)initWithCode:(NSString *)code;
@end

@interface ObjcDemoCardView : UIView
- (instancetype)initWithDemo:(ObjcDemoCase *)demo layout:(ObjcDemoCardLayout)layout;
@end

@interface ObjcDemoLinkButton : UIControl
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle accentColor:(UIColor *)accentColor;
+ (instancetype)buttonWithPage:(ObjcDemoPage *)page;
@end

@interface ObjcPlaygroundPanelView : UIView
@end

@interface ObjcDemoSectionViewController : UIViewController
- (instancetype)initWithPage:(ObjcDemoPage *)page;
@end

@interface ObjcVerticalInteractionViewController : UIViewController
@end

@interface ViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, copy) NSArray<ObjcDemoPage *> *pages;
@end

@implementation ObjcDemoScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIControl.class]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end

@implementation ObjcDemoPathDelegate

- (instancetype)initWithKind:(ObjcDemoPathKind)kind {
    self = [super init];
    if (self) {
        _kind = kind;
    }
    return self;
}

- (UIBezierPath *)emojiRateView:(EmojiRateView *)rateView pathIn:(CGRect)rect rateProgress:(CGFloat)rateProgress {
    switch (self.kind) {
        case ObjcDemoPathKindWaveform:
            return [self waveformPathInRect:rect progress:rateProgress];
        case ObjcDemoPathKindLightning:
            return [self lightningPathInRect:rect];
        case ObjcDemoPathKindCrown:
            return [self crownPathInRect:rect];
        case ObjcDemoPathKindDiamond:
            return [self diamondPathInRect:rect progress:rateProgress];
        case ObjcDemoPathKindNone:
            return nil;
    }
}

- (UIBezierPath *)waveformPathInRect:(CGRect)rect progress:(CGFloat)progress {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat margin = width * 0.14;
    [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, margin, margin)]];

    CGFloat baseline = y + height * 0.56;
    CGFloat amplitude = height * (0.06 + progress * 0.16);
    [path moveToPoint:CGPointMake(x + width * 0.24, baseline)];
    for (NSInteger step = 1; step <= 7; step += 1) {
        CGFloat pointX = x + width * (0.24 + (CGFloat)step * 0.075);
        CGFloat pointY = baseline + (step % 2 == 0 ? amplitude : -amplitude);
        [path addLineToPoint:CGPointMake(pointX, pointY)];
    }

    [path moveToPoint:CGPointMake(x + width * 0.34, y + height * 0.36)];
    [path addLineToPoint:CGPointMake(x + width * 0.42, y + height * 0.36)];
    [path moveToPoint:CGPointMake(x + width * 0.58, y + height * 0.36)];
    [path addLineToPoint:CGPointMake(x + width * 0.66, y + height * 0.36)];
    return path;
}

- (UIBezierPath *)lightningPathInRect:(CGRect)rect {
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat margin = w * 0.14;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, margin, margin)]];
    [path moveToPoint:CGPointMake(x + w * 0.56, y + h * 0.22)];
    [path addLineToPoint:CGPointMake(x + w * 0.36, y + h * 0.52)];
    [path addLineToPoint:CGPointMake(x + w * 0.51, y + h * 0.52)];
    [path addLineToPoint:CGPointMake(x + w * 0.42, y + h * 0.78)];
    [path addLineToPoint:CGPointMake(x + w * 0.68, y + h * 0.43)];
    [path addLineToPoint:CGPointMake(x + w * 0.52, y + h * 0.43)];
    [path closePath];
    return path;
}

- (UIBezierPath *)crownPathInRect:(CGRect)rect {
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(x + w * 0.18, y + h * 0.28)];
    [path addLineToPoint:CGPointMake(x + w * 0.34, y + h * 0.10)];
    [path addLineToPoint:CGPointMake(x + w * 0.50, y + h * 0.30)];
    [path addLineToPoint:CGPointMake(x + w * 0.66, y + h * 0.10)];
    [path addLineToPoint:CGPointMake(x + w * 0.82, y + h * 0.28)];
    [path addLineToPoint:CGPointMake(x + w * 0.76, y + h * 0.42)];
    [path addLineToPoint:CGPointMake(x + w * 0.24, y + h * 0.42)];
    [path closePath];
    return path;
}

- (UIBezierPath *)diamondPathInRect:(CGRect)rect progress:(CGFloat)progress {
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat inset = w * (0.12 - progress * 0.04);
    CGRect adjusted = CGRectInset(rect, inset, inset);
    CGFloat midX = CGRectGetMidX(adjusted);
    CGFloat midY = CGRectGetMidY(adjusted);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(midX, CGRectGetMinY(adjusted))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(adjusted), midY)];
    [path addLineToPoint:CGPointMake(midX, CGRectGetMaxY(adjusted))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(adjusted), midY)];
    [path closePath];
    [path moveToPoint:CGPointMake(x + w * 0.32, y + h * 0.46)];
    [path addLineToPoint:CGPointMake(x + w * 0.42, y + h * 0.46)];
    [path moveToPoint:CGPointMake(x + w * 0.58, y + h * 0.46)];
    [path addLineToPoint:CGPointMake(x + w * 0.68, y + h * 0.46)];
    [path moveToPoint:CGPointMake(x + w * 0.32, y + h * 0.62)];
    [path addCurveToPoint:CGPointMake(x + w * 0.68, y + h * 0.62)
            controlPoint1:CGPointMake(x + w * 0.42, y + h * (0.68 + progress * 0.08))
            controlPoint2:CGPointMake(x + w * 0.58, y + h * (0.68 + progress * 0.08))];
    return path;
}

@end

@implementation ObjcDemoCase

+ (instancetype)caseWithTitle:(NSString *)title description:(NSString *)description value:(float)value {
    ObjcDemoCase *demo = [[ObjcDemoCase alloc] init];
    demo.title = title;
    demo.caseDescription = description;
    demo.value = value;
    demo.minimum = 0;
    demo.maximum = 10;
    demo.step = 0;
    demo.lineWidth = 10;
    demo.colorFrom = UIColor.systemCyanColor;
    demo.colorTo = UIColor.systemBlueColor;
    demo.gradientFrom = demo.colorFrom;
    demo.gradientTo = demo.colorTo;
    demo.gradientEnabled = YES;
    demo.gestureDirection = 1;
    demo.tapToRateEnabled = YES;
    demo.readOnly = NO;
    demo.dragSensitivity = 5;
    demo.showsSlider = YES;
    demo.dragTip = @"Drag the face itself, or use the slider.";
    demo.fullWidth = NO;
    demo.expressionPreset = 0;
    demo.eyeStyle = 0;
    demo.mouthStyle = 0;
    demo.showAccessories = YES;
    demo.accessoryScale = 1;
    demo.faceShape = 0;
    demo.faceShapeMorphEnabled = NO;
    demo.faceFillEnabled = NO;
    demo.faceFillColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    demo.faceFillDynamicColor = NO;
    demo.faceFillGradientEnabled = NO;
    demo.customPathMode = 0;
    demo.pathKind = ObjcDemoPathKindNone;
    return demo;
}

@end

@implementation ObjcDemoPage

+ (instancetype)pageWithTitle:(NSString *)title description:(NSString *)description accentColor:(UIColor *)accentColor cases:(NSArray<ObjcDemoCase *> *)cases {
    ObjcDemoPage *page = [[ObjcDemoPage alloc] init];
    page.title = title;
    page.pageDescription = description;
    page.accentColor = accentColor;
    page.cases = cases;
    return page;
}

@end

@implementation ObjcCodeBlockView

- (instancetype)initWithCode:(NSString *)code {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.06 green:0.07 blue:0.10 alpha:1.0];
        self.layer.cornerRadius = 8;

        UILabel *label = [[UILabel alloc] init];
        label.text = code;
        label.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightSemibold];
        label.textColor = UIColor.whiteColor;
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];

        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [label.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10]
        ]];
    }
    return self;
}

@end

@implementation ObjcDemoCardView {
    ObjcDemoCase *_demo;
    ObjcDemoCardLayout _layout;
    EmojiRateView *_rateView;
    UILabel *_valueLabel;
    UISlider *_slider;
    BOOL _isUpdating;
    ObjcDemoPathDelegate *_pathDelegate;
}

- (instancetype)initWithDemo:(ObjcDemoCase *)demo layout:(ObjcDemoCardLayout)layout {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _demo = demo;
        _layout = layout;
        _rateView = [[EmojiRateView alloc] init];
        _valueLabel = [[UILabel alloc] init];
        _slider = [[UISlider alloc] init];
        [self configure];
    }
    return self;
}

- (void)configure {
    self.backgroundColor = UIColor.whiteColor;
    self.layer.cornerRadius = 18;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOpacity = 0.08;
    self.layer.shadowRadius = 18;
    self.layer.shadowOffset = CGSizeMake(0, 8);

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 10;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = _demo.title;
    titleLabel.font = [UIFont systemFontOfSize:_layout == ObjcDemoCardLayoutWide ? 22 : 17 weight:UIFontWeightHeavy];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;

    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = _demo.caseDescription;
    descriptionLabel.font = [UIFont systemFontOfSize:_layout == ObjcDemoCardLayoutWide ? 14 : 12 weight:UIFontWeightSemibold];
    descriptionLabel.textColor = UIColor.secondaryLabelColor;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = _layout == ObjcDemoCardLayoutWide ? 4 : 3;

    [self configureRateView];

    _valueLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    _valueLabel.textColor = UIColor.secondaryLabelColor;
    _valueLabel.textAlignment = NSTextAlignmentCenter;

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:descriptionLabel];
    [stack addArrangedSubview:_rateView];
    [stack addArrangedSubview:_valueLabel];

    if (_demo.showsSlider) {
        _slider.minimumValue = _demo.minimum;
        _slider.maximumValue = _demo.maximum;
        _slider.value = _demo.value;
        [_slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        [stack addArrangedSubview:_slider];

        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = _demo.dragTip;
        tipLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        tipLabel.textColor = UIColor.tertiaryLabelColor;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.numberOfLines = 2;
        [stack addArrangedSubview:tipLabel];
    }

    if (_demo.code.length > 0) {
        [stack addArrangedSubview:[[ObjcCodeBlockView alloc] initWithCode:_demo.code]];
    }

    CGFloat preferredHeight = [self preferredHeight];
    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintGreaterThanOrEqualToConstant:preferredHeight],
        [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [stack.topAnchor constraintEqualToAnchor:self.topAnchor constant:16],
        [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-16],
        [_rateView.widthAnchor constraintEqualToConstant:_layout == ObjcDemoCardLayoutWide ? 170 : 126],
        [_rateView.heightAnchor constraintEqualToAnchor:_rateView.widthAnchor]
    ]];

    if (_demo.showsSlider) {
        [_slider.widthAnchor constraintEqualToAnchor:stack.widthAnchor multiplier:0.88].active = YES;
    }
}

- (CGFloat)preferredHeight {
    if (_layout == ObjcDemoCardLayoutWide) {
        return _demo.code.length > 0 ? 440 : 360;
    }
    return _demo.code.length > 0 ? 408 : 320;
}

- (void)configureRateView {
    _rateView.backgroundColor = UIColor.clearColor;
    _rateView.minimumRateValue = _demo.minimum;
    _rateView.maximumRateValue = _demo.maximum;
    _rateView.rateStep = _demo.step;
    _rateView.rateLineWidth = _demo.lineWidth;
    [_rateView setRateColorFrom:_demo.colorFrom to:_demo.colorTo];
    [_rateView setRateGradientColorFrom:_demo.gradientFrom to:_demo.gradientTo];
    _rateView.rateGradientColorEnabled = _demo.gradientEnabled;
    _rateView.rateGradientStartPointX = 0;
    _rateView.rateGradientStartPointY = 0;
    _rateView.rateGradientEndPointX = 1;
    _rateView.rateGradientEndPointY = 1;
    _rateView.rateGestureDirection = _demo.gestureDirection;
    _rateView.recognizeSimultanousGestures = NO;
    _rateView.isTapToRateEnabled = _demo.tapToRateEnabled;
    _rateView.isReadOnly = _demo.readOnly;
    _rateView.rateDragSensitivity = _demo.dragSensitivity;
    _rateView.emojiExpressionPreset = _demo.expressionPreset;
    _rateView.emojiEyeStyle = _demo.eyeStyle;
    _rateView.emojiMouthStyle = _demo.mouthStyle;
    _rateView.emojiShowAccessories = _demo.showAccessories;
    _rateView.emojiAccessoryScale = _demo.accessoryScale;
    _rateView.faceShape = _demo.faceShape;
    _rateView.faceShapeMorphEnabled = _demo.faceShapeMorphEnabled;
    _rateView.faceFillEnabled = _demo.faceFillEnabled;
    _rateView.faceFillColor = _demo.faceFillColor;
    _rateView.faceFillDynamicColor = _demo.faceFillDynamicColor;
    _rateView.faceFillGradientEnabled = _demo.faceFillGradientEnabled;
    _rateView.customEmojiPathMode = _demo.customPathMode;
    if (_demo.pathKind != ObjcDemoPathKindNone) {
        _pathDelegate = [[ObjcDemoPathDelegate alloc] initWithKind:_demo.pathKind];
        _rateView.customPathDelegate = _pathDelegate;
    }

    __weak typeof(self) weakSelf = self;
    [_rateView setRateValueChangeCallback:^(float newRateValue) {
        [weakSelf syncValue:newRateValue];
    }];
    [_rateView setRateValue:_demo.value animated:NO];
}

- (void)syncValue:(float)value {
    _valueLabel.text = ObjcDemoValueText(value, _demo.maximum);
    if (_isUpdating) {
        return;
    }
    _isUpdating = YES;
    _slider.value = value;
    _isUpdating = NO;
}

- (void)sliderChanged {
    if (_isUpdating) {
        return;
    }
    [_rateView setRateValue:_slider.value animated:NO];
}

@end

@implementation ObjcDemoLinkButton

+ (instancetype)buttonWithPage:(ObjcDemoPage *)page {
    return [[self alloc] initWithTitle:page.title subtitle:page.pageDescription accentColor:page.accentColor];
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle accentColor:(UIColor *)accentColor {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 16;
        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.06;
        self.layer.shadowRadius = 14;
        self.layer.shadowOffset = CGSizeMake(0, 6);
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityLabel = title;
        self.accessibilityHint = subtitle;

        UIView *accentView = [[UIView alloc] init];
        accentView.backgroundColor = accentColor;
        accentView.layer.cornerRadius = 4;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy];
        titleLabel.numberOfLines = 2;

        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.text = subtitle;
        subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        subtitleLabel.textColor = UIColor.secondaryLabelColor;
        subtitleLabel.numberOfLines = 3;

        UIStackView *textStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, subtitleLabel]];
        textStack.axis = UILayoutConstraintAxisVertical;
        textStack.spacing = 4;

        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[accentView, textStack]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        row.spacing = 12;
        row.userInteractionEnabled = NO;
        row.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:row];

        [NSLayoutConstraint activateConstraints:@[
            [self.heightAnchor constraintGreaterThanOrEqualToConstant:92],
            [accentView.widthAnchor constraintEqualToConstant:8],
            [accentView.heightAnchor constraintEqualToConstant:54],
            [row.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [row.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
            [row.topAnchor constraintEqualToAnchor:self.topAnchor constant:14],
            [row.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-14]
        ]];
    }
    return self;
}

@end

@implementation ObjcPlaygroundPanelView {
    EmojiRateView *_rateView;
    UILabel *_valueLabel;
    UISlider *_valueSlider;
    UISlider *_lineWidthSlider;
    UISegmentedControl *_presetControl;
    UISegmentedControl *_faceControl;
    UISegmentedControl *_stepControl;
    UISwitch *_gradientSwitch;
    UISwitch *_fillSwitch;
    UISwitch *_accessoriesSwitch;
    UISwitch *_readOnlySwitch;
    UISwitch *_horizontalSwitch;
    BOOL _isUpdating;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rateView = [[EmojiRateView alloc] init];
        _valueLabel = [[UILabel alloc] init];
        _valueSlider = [[UISlider alloc] init];
        _lineWidthSlider = [[UISlider alloc] init];
        _presetControl = [[UISegmentedControl alloc] initWithItems:@[@"Clas...", @"Mood", @"Play", @"Diag", @"Min"]];
        _faceControl = [[UISegmentedControl alloc] initWithItems:@[@"Circle", @"Squircle", @"Blob", @"Shield"]];
        _stepControl = [[UISegmentedControl alloc] initWithItems:@[@"Free", @"0.5", @"1"]];
        _gradientSwitch = [[UISwitch alloc] init];
        _fillSwitch = [[UISwitch alloc] init];
        _accessoriesSwitch = [[UISwitch alloc] init];
        _readOnlySwitch = [[UISwitch alloc] init];
        _horizontalSwitch = [[UISwitch alloc] init];
        [self configure];
    }
    return self;
}

- (void)configure {
    self.backgroundColor = UIColor.whiteColor;
    self.layer.cornerRadius = 22;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOpacity = 0.08;
    self.layer.shadowRadius = 20;
    self.layer.shadowOffset = CGSizeMake(0, 10);

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentFill;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Interactive playground";
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightHeavy];

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"Tip: drag up or down on the emoji itself to rate the feeling, or use the slider for precise values.";
    tipLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    tipLabel.textColor = UIColor.secondaryLabelColor;
    tipLabel.numberOfLines = 2;

    _rateView.backgroundColor = UIColor.clearColor;
    _rateView.minimumRateValue = 0;
    _rateView.maximumRateValue = 10;
    _rateView.rateStep = 0;
    _rateView.rateLineWidth = 12;
    [_rateView setRateColorFrom:UIColor.systemCyanColor to:UIColor.systemBlueColor];
    [_rateView setRateGradientColorFrom:UIColor.systemCyanColor to:UIColor.systemIndigoColor];
    _rateView.rateGradientColorEnabled = YES;
    _rateView.rateGestureDirection = 0;
    _rateView.emojiExpressionPreset = 1;
    _rateView.faceShape = 0;
    _rateView.faceShapeMorphEnabled = NO;
    _rateView.faceFillEnabled = YES;
    _rateView.faceFillGradientEnabled = YES;
    _rateView.faceFillColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    __weak typeof(self) weakSelf = self;
    [_rateView setRateValueChangeCallback:^(float value) {
        [weakSelf syncValue:value];
    }];

    _valueLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightHeavy];
    _valueLabel.textAlignment = NSTextAlignmentCenter;

    _valueSlider.minimumValue = 0;
    _valueSlider.maximumValue = 10;
    [_valueSlider addTarget:self action:@selector(valueSliderChanged) forControlEvents:UIControlEventValueChanged];
    _lineWidthSlider.minimumValue = 4;
    _lineWidthSlider.maximumValue = 20;
    _lineWidthSlider.value = 12;
    [_lineWidthSlider addTarget:self action:@selector(lineWidthChanged) forControlEvents:UIControlEventValueChanged];

    _presetControl.selectedSegmentIndex = 1;
    _faceControl.selectedSegmentIndex = 0;
    _stepControl.selectedSegmentIndex = 0;
    [_presetControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    [_faceControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    [_stepControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];

    _gradientSwitch.on = YES;
    _fillSwitch.on = YES;
    _accessoriesSwitch.on = YES;
    _horizontalSwitch.on = NO;
    for (UISwitch *switchView in @[_gradientSwitch, _fillSwitch, _accessoriesSwitch, _readOnlySwitch, _horizontalSwitch]) {
        [switchView addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    }

    UIStackView *previewStack = [[UIStackView alloc] initWithArrangedSubviews:@[_rateView, _valueLabel]];
    previewStack.axis = UILayoutConstraintAxisVertical;
    previewStack.alignment = UIStackViewAlignmentCenter;
    previewStack.spacing = 10;

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:tipLabel];
    [stack addArrangedSubview:previewStack];
    [stack addArrangedSubview:ObjcDemoControlRow(@"Value", _valueSlider)];
    [stack addArrangedSubview:ObjcDemoControlRow(@"Line width", _lineWidthSlider)];
    [stack addArrangedSubview:ObjcDemoControlRow(@"Preset", _presetControl)];
    [stack addArrangedSubview:ObjcDemoControlRow(@"Face", _faceControl)];
    [stack addArrangedSubview:ObjcDemoControlRow(@"Step", _stepControl)];
    [stack addArrangedSubview:[self switchGrid]];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-18],
        [stack.topAnchor constraintEqualToAnchor:self.topAnchor constant:18],
        [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-18],
        [_rateView.widthAnchor constraintEqualToConstant:178],
        [_rateView.heightAnchor constraintEqualToAnchor:_rateView.widthAnchor]
    ]];

    _valueSlider.value = 7.5;
    [_rateView setRateValue:7.5 animated:NO];
}

- (UIStackView *)switchGrid {
    NSArray<NSString *> *titles = @[@"Gradient", @"Fill", @"Details", @"Read only", @"Horizontal"];
    NSArray<UISwitch *> *switches = @[_gradientSwitch, _fillSwitch, _accessoriesSwitch, _readOnlySwitch, _horizontalSwitch];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.spacing = 10;

    for (NSInteger rowIndex = 0; rowIndex < 3; rowIndex += 1) {
        UIStackView *row = [[UIStackView alloc] init];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.distribution = UIStackViewDistributionFillEqually;
        row.spacing = 12;

        for (NSInteger column = 0; column < 2; column += 1) {
            NSInteger index = rowIndex * 2 + column;
            if (index < titles.count) {
                UILabel *label = [[UILabel alloc] init];
                label.text = titles[index];
                label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
                label.textColor = UIColor.secondaryLabelColor;
                UIStackView *item = [[UIStackView alloc] initWithArrangedSubviews:@[label, switches[index]]];
                item.axis = UILayoutConstraintAxisHorizontal;
                item.alignment = UIStackViewAlignmentCenter;
                item.spacing = 8;
                [row addArrangedSubview:item];
            } else {
                [row addArrangedSubview:[[UIView alloc] init]];
            }
        }
        [grid addArrangedSubview:row];
    }
    return grid;
}

- (void)syncValue:(float)value {
    _valueLabel.text = ObjcDemoValueText(value, 10);
    if (_isUpdating) {
        return;
    }
    _isUpdating = YES;
    _valueSlider.value = value;
    _isUpdating = NO;
}

- (void)valueSliderChanged {
    if (_isUpdating) {
        return;
    }
    [_rateView setRateValue:_valueSlider.value animated:NO];
}

- (void)lineWidthChanged {
    _rateView.rateLineWidth = _lineWidthSlider.value;
}

- (void)segmentedControlChanged {
    NSInteger presets[] = {0, 1, 2, 3, 4};
    NSInteger faces[] = {0, 2, 3, 5};
    float steps[] = {0, 0.5, 1};
    _rateView.emojiExpressionPreset = presets[_presetControl.selectedSegmentIndex];
    _rateView.faceShape = faces[_faceControl.selectedSegmentIndex];
    _rateView.rateStep = steps[_stepControl.selectedSegmentIndex];
}

- (void)switchChanged {
    _rateView.rateGradientColorEnabled = _gradientSwitch.on;
    _rateView.faceFillEnabled = _fillSwitch.on;
    _rateView.emojiShowAccessories = _accessoriesSwitch.on;
    _rateView.isReadOnly = _readOnlySwitch.on;
    _rateView.rateGestureDirection = _horizontalSwitch.on ? 1 : 0;
}

@end

@implementation ObjcDemoSectionViewController {
    ObjcDemoPage *_page;
    UIScrollView *_scrollView;
    UIStackView *_contentStack;
}

- (instancetype)initWithPage:(ObjcDemoPage *)page {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _page = page;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _page.title;
    self.view.backgroundColor = ObjcDemoBackgroundColor();
    [self configureScrollView];
    [self buildContent];
}

- (void)configureScrollView {
    _scrollView = [[ObjcDemoScrollView alloc] init];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];

    _contentStack = [[UIStackView alloc] init];
    _contentStack.axis = UILayoutConstraintAxisVertical;
    _contentStack.spacing = 20;
    _contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_contentStack.leadingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.leadingAnchor constant:20],
        [_contentStack.trailingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [_contentStack.topAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.topAnchor constant:20],
        [_contentStack.bottomAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.bottomAnchor constant:-34],
        [_contentStack.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor constant:-40]
    ]];
}

- (void)buildContent {
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = _page.pageDescription;
    descriptionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    descriptionLabel.textColor = UIColor.secondaryLabelColor;
    descriptionLabel.numberOfLines = 0;
    [_contentStack addArrangedSubview:descriptionLabel];

    BOOL usesFullWidth = NO;
    for (ObjcDemoCase *demo in _page.cases) {
        if (demo.fullWidth) {
            usesFullWidth = YES;
            break;
        }
    }

    if (usesFullWidth) {
        for (ObjcDemoCase *demo in _page.cases) {
            [_contentStack addArrangedSubview:[[ObjcDemoCardView alloc] initWithDemo:demo layout:ObjcDemoCardLayoutWide]];
        }
        return;
    }

    NSInteger index = 0;
    while (index < _page.cases.count) {
        UIStackView *row = [[UIStackView alloc] init];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.distribution = UIStackViewDistributionFillEqually;
        row.spacing = 14;
        for (NSInteger column = 0; column < 2; column += 1) {
            if (index < _page.cases.count) {
                [row addArrangedSubview:[[ObjcDemoCardView alloc] initWithDemo:_page.cases[index] layout:ObjcDemoCardLayoutCompact]];
            } else {
                [row addArrangedSubview:[[UIView alloc] init]];
            }
            index += 1;
        }
        [_contentStack addArrangedSubview:row];
    }
}

@end

@implementation ObjcVerticalInteractionViewController {
    EmojiRateView *_rateView;
    UISlider *_slider;
    UILabel *_valueLabel;
    BOOL _isUpdating;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Vertical drag";
    self.view.backgroundColor = ObjcDemoBackgroundColor();
    [self buildContent];
}

- (void)buildContent {
    _rateView = [[EmojiRateView alloc] init];
    _slider = [[UISlider alloc] init];
    _valueLabel = [[UILabel alloc] init];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 18;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Original vertical interaction";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightHeavy];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"Drag down or up directly on the emoji to change the value. Use the slider when you want precise control.";
    tipLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    tipLabel.textColor = UIColor.secondaryLabelColor;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 4;

    _rateView.backgroundColor = UIColor.clearColor;
    _rateView.minimumRateValue = 0;
    _rateView.maximumRateValue = 10;
    _rateView.rateStep = 0;
    _rateView.rateLineWidth = 13;
    _rateView.rateGestureDirection = 0;
    [_rateView setRateColorFrom:UIColor.systemCyanColor to:UIColor.systemBlueColor];
    [_rateView setRateGradientColorFrom:UIColor.systemCyanColor to:UIColor.systemIndigoColor];
    _rateView.rateGradientColorEnabled = YES;
    _rateView.emojiExpressionPreset = 1;
    _rateView.faceShape = 3;
    _rateView.faceShapeMorphEnabled = YES;
    _rateView.faceFillEnabled = YES;
    _rateView.faceFillGradientEnabled = YES;
    _rateView.faceFillColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    __weak typeof(self) weakSelf = self;
    [_rateView setRateValueChangeCallback:^(float value) {
        [weakSelf syncValue:value];
    }];

    _slider.minimumValue = 0;
    _slider.maximumValue = 10;
    [_slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];

    _valueLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightHeavy];

    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:tipLabel];
    [stack addArrangedSubview:_rateView];
    [stack addArrangedSubview:_valueLabel];
    [stack addArrangedSubview:_slider];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:26],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-26],
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:48],
        [_rateView.widthAnchor constraintEqualToConstant:230],
        [_rateView.heightAnchor constraintEqualToAnchor:_rateView.widthAnchor],
        [_slider.widthAnchor constraintEqualToAnchor:stack.widthAnchor]
    ]];

    _slider.value = 8.5;
    [_rateView setRateValue:8.5 animated:NO];
}

- (void)syncValue:(float)value {
    _valueLabel.text = ObjcDemoValueText(value, 10);
    if (_isUpdating) {
        return;
    }
    _isUpdating = YES;
    _slider.value = value;
    _isUpdating = NO;
}

- (void)sliderChanged {
    if (_isUpdating) {
        return;
    }
    [_rateView setRateValue:_slider.value animated:NO];
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TTGEmojiRate";
    self.view.backgroundColor = ObjcDemoBackgroundColor();
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.pages = [self buildPages];
    [self configureScrollView];
    [self buildContent];
}

- (void)configureScrollView {
    self.scrollView = [[ObjcDemoScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.canCancelContentTouches = YES;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    self.contentStack = [[UIStackView alloc] init];
    self.contentStack.axis = UILayoutConstraintAxisVertical;
    self.contentStack.spacing = 24;
    self.contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.contentStack.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor constant:20],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [self.contentStack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:20],
        [self.contentStack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-34],
        [self.contentStack.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor constant:-40]
    ]];
}

- (void)buildContent {
    UILabel *headlineLabel = [[UILabel alloc] init];
    headlineLabel.text = @"Rate by dragging a feeling";
    headlineLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightHeavy];
    headlineLabel.numberOfLines = 2;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Start with the original up/down emoji gesture for scoring mood, then tune value, shape, fill, stroke, and custom paths.";
    subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;

    [self.contentStack addArrangedSubview:headlineLabel];
    [self.contentStack setCustomSpacing:8 afterView:headlineLabel];
    [self.contentStack addArrangedSubview:subtitleLabel];
    [self.contentStack addArrangedSubview:[[ObjcPlaygroundPanelView alloc] init]];
    [self.contentStack addArrangedSubview:[self pageLinksView]];
}

- (UIView *)pageLinksView {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Explore focused demos";
    titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightHeavy];
    [stack addArrangedSubview:titleLabel];

    ObjcDemoLinkButton *verticalButton = [[ObjcDemoLinkButton alloc] initWithTitle:@"Vertical interaction"
                                                                           subtitle:@"The original up/down emoji gesture for rating a feeling, with slider fallback."
                                                                        accentColor:UIColor.systemIndigoColor];
    [verticalButton addTarget:self action:@selector(openVerticalDemo) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:verticalButton];

    NSInteger index = 0;
    for (ObjcDemoPage *page in self.pages) {
        ObjcDemoLinkButton *button = [ObjcDemoLinkButton buttonWithPage:page];
        button.tag = index;
        [button addTarget:self action:@selector(openDemoPage:) forControlEvents:UIControlEventTouchUpInside];
        [stack addArrangedSubview:button];
        index += 1;
    }
    return stack;
}

- (void)openDemoPage:(UIControl *)sender {
    ObjcDemoPage *page = self.pages[sender.tag];
    [self.navigationController pushViewController:[[ObjcDemoSectionViewController alloc] initWithPage:page] animated:YES];
}

- (void)openVerticalDemo {
    [self.navigationController pushViewController:[[ObjcVerticalInteractionViewController alloc] init] animated:YES];
}

- (NSArray<ObjcDemoPage *> *)buildPages {
    ObjcDemoCase *interactive = [ObjcDemoCase caseWithTitle:@"Vertical mood rating"
                                                description:@"A polished 0-10 rating control where users drag the emoji up or down to express score, mood, and feeling."
                                                      value:7.5];
    interactive.colorFrom = UIColor.systemTealColor;
    interactive.colorTo = UIColor.systemIndigoColor;
    interactive.gradientFrom = UIColor.systemTealColor;
    interactive.gradientTo = UIColor.systemIndigoColor;
    interactive.gestureDirection = 0;
    interactive.dragTip = @"Drag the face up or down, or use the slider.";
    interactive.fullWidth = YES;
    interactive.expressionPreset = 1;
    interactive.faceShape = 0;
    interactive.faceFillEnabled = YES;
    interactive.faceFillColor = [UIColor.systemTealColor colorWithAlphaComponent:0.12];
    interactive.code = @"rateView.maximumRateValue = 10\nrateView.rateStep = 0\nrateView.rateGestureDirection = vertical\nrateView.rateValueChangeCallback = ^(float score) {};";

    ObjcDemoCase *readOnly = [ObjcDemoCase caseWithTitle:@"Read-only summary"
                                             description:@"For review cards, dashboards, rankings, and confirmation screens where the rating should be visible but not editable."
                                                   value:8.5];
    readOnly.colorFrom = UIColor.systemIndigoColor;
    readOnly.colorTo = UIColor.systemGreenColor;
    readOnly.gradientFrom = UIColor.systemIndigoColor;
    readOnly.gradientTo = UIColor.systemGreenColor;
    readOnly.readOnly = YES;
    readOnly.showsSlider = NO;
    readOnly.dragTip = @"Read-only: gestures are disabled.";
    readOnly.fullWidth = YES;
    readOnly.expressionPreset = 1;
    readOnly.faceShape = 5;
    readOnly.faceFillEnabled = YES;
    readOnly.faceFillGradientEnabled = YES;
    readOnly.faceFillColor = [UIColor.systemIndigoColor colorWithAlphaComponent:0.14];
    readOnly.code = @"rateView.isReadOnly = YES\n[rateView setRateValue:8.5 animated:YES];";

    ObjcDemoPage *start = [ObjcDemoPage pageWithTitle:@"Start here"
                                           description:@"Two full-width examples for vertical mood input and read-only display use cases."
                                           accentColor:UIColor.systemTealColor
                                                 cases:@[interactive, readOnly]];

    ObjcDemoCase *angry = [ObjcDemoCase caseWithTitle:@"Angry" description:@"Low-score expressive face with brows and frown." value:1];
    angry.colorFrom = UIColor.systemRedColor; angry.colorTo = UIColor.systemOrangeColor; angry.gradientFrom = angry.colorFrom; angry.gradientTo = angry.colorTo; angry.expressionPreset = 1;
    ObjcDemoCase *diagnostic = [ObjcDemoCase caseWithTitle:@"Diagnostic" description:@"Useful for feedback flows and problem reports." value:2.5];
    diagnostic.colorFrom = UIColor.systemPinkColor; diagnostic.colorTo = UIColor.systemTealColor; diagnostic.gradientFrom = diagnostic.colorFrom; diagnostic.gradientTo = diagnostic.colorTo; diagnostic.expressionPreset = 3;
    ObjcDemoCase *neutral = [ObjcDemoCase caseWithTitle:@"Neutral" description:@"Minimal face for quiet product surfaces." value:5];
    neutral.colorFrom = UIColor.systemGrayColor; neutral.colorTo = UIColor.systemBlueColor; neutral.gradientFrom = neutral.colorFrom; neutral.gradientTo = neutral.colorTo; neutral.expressionPreset = 4;
    ObjcDemoCase *delight = [ObjcDemoCase caseWithTitle:@"Delight" description:@"Reward-style high score with expressive accessories." value:10];
    delight.colorFrom = UIColor.systemPurpleColor; delight.colorTo = UIColor.systemGreenColor; delight.gradientFrom = UIColor.systemPinkColor; delight.gradientTo = UIColor.systemGreenColor; delight.expressionPreset = 2;
    ObjcDemoPage *presets = [ObjcDemoPage pageWithTitle:@"Emotion presets"
                                            description:@"Preset expressions translate score into mood without requiring callers to hand-tune every curve."
                                            accentColor:UIColor.systemPinkColor
                                                  cases:@[angry, diagnostic, neutral, delight]];

    ObjcDemoCase *squircle = [ObjcDemoCase caseWithTitle:@"Squircle" description:@"Modern rounded-square face with soft fill." value:7];
    squircle.colorFrom = UIColor.systemBlueColor; squircle.colorTo = UIColor.systemGreenColor; squircle.gradientFrom = squircle.colorFrom; squircle.gradientTo = squircle.colorTo; squircle.expressionPreset = 1; squircle.faceShape = 2; squircle.faceShapeMorphEnabled = YES; squircle.faceFillEnabled = YES; squircle.faceFillColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    ObjcDemoCase *blob = [ObjcDemoCase caseWithTitle:@"Blob" description:@"Playful organic face with gradient fill." value:9];
    blob.colorFrom = UIColor.systemPurpleColor; blob.colorTo = UIColor.systemPinkColor; blob.gradientFrom = blob.colorFrom; blob.gradientTo = blob.colorTo; blob.expressionPreset = 2; blob.faceShape = 3; blob.faceShapeMorphEnabled = YES; blob.faceFillEnabled = YES; blob.faceFillGradientEnabled = YES; blob.faceFillColor = [UIColor.systemPinkColor colorWithAlphaComponent:0.16];
    ObjcDemoCase *capsule = [ObjcDemoCase caseWithTitle:@"Capsule" description:@"Compact horizontal rating badge." value:6];
    capsule.colorFrom = UIColor.systemIndigoColor; capsule.colorTo = UIColor.systemTealColor; capsule.gradientFrom = capsule.colorFrom; capsule.gradientTo = capsule.colorTo; capsule.expressionPreset = 4; capsule.faceShape = 4; capsule.faceFillEnabled = YES; capsule.faceFillDynamicColor = YES;
    ObjcDemoCase *cloud = [ObjcDemoCase caseWithTitle:@"Cloud" description:@"Soft cloud outline for friendly feedback." value:8];
    cloud.colorFrom = UIColor.systemCyanColor; cloud.colorTo = UIColor.systemBlueColor; cloud.gradientFrom = cloud.colorFrom; cloud.gradientTo = cloud.colorTo; cloud.expressionPreset = 2; cloud.faceShape = 6; cloud.faceFillEnabled = YES; cloud.faceFillColor = [UIColor.systemCyanColor colorWithAlphaComponent:0.16];
    ObjcDemoCase *noFace = [ObjcDemoCase caseWithTitle:@"No face" description:@"Draw only expression features for minimal UI." value:7.5];
    noFace.colorFrom = UIColor.systemPinkColor; noFace.colorTo = UIColor.systemPurpleColor; noFace.gradientFrom = noFace.colorFrom; noFace.gradientTo = noFace.colorTo; noFace.expressionPreset = 1; noFace.faceShape = 7;
    ObjcDemoPage *faces = [ObjcDemoPage pageWithTitle:@"Face shapes and fill"
                                          description:@"Use filled shapes, gradient fills, and morphing outlines so every emoji does not look like the same round face."
                                          accentColor:UIColor.systemBlueColor
                                                cases:@[squircle, blob, capsule, cloud, noFace]];

    ObjcDemoCase *gradient = [ObjcDemoCase caseWithTitle:@"Gradient stroke" description:@"Multi-stop stroke gradient for richer visuals." value:9.5];
    gradient.colorFrom = UIColor.systemPurpleColor; gradient.colorTo = UIColor.systemPinkColor; gradient.gradientFrom = UIColor.systemPurpleColor; gradient.gradientTo = UIColor.systemOrangeColor; gradient.expressionPreset = 2;
    ObjcDemoCase *star = [ObjcDemoCase caseWithTitle:@"Star eyes" description:@"Override eyes and mouth while keeping score behavior." value:9];
    star.colorFrom = UIColor.systemOrangeColor; star.colorTo = UIColor.systemYellowColor; star.gradientFrom = star.colorFrom; star.gradientTo = star.colorTo; star.eyeStyle = 4; star.mouthStyle = 5;
    ObjcDemoCase *heart = [ObjcDemoCase caseWithTitle:@"Heart eyes" description:@"Another component override preset." value:8];
    heart.colorFrom = UIColor.systemPinkColor; heart.colorTo = UIColor.systemPurpleColor; heart.gradientFrom = heart.colorFrom; heart.gradientTo = heart.colorTo; heart.eyeStyle = 5; heart.mouthStyle = 2;
    ObjcDemoCase *surprised = [ObjcDemoCase caseWithTitle:@"Surprised" description:@"Round eyes and O mouth for mid-score reaction." value:4.5];
    surprised.colorFrom = UIColor.systemIndigoColor; surprised.colorTo = UIColor.systemTealColor; surprised.gradientFrom = surprised.colorFrom; surprised.gradientTo = surprised.colorTo; surprised.eyeStyle = 2; surprised.mouthStyle = 6;
    ObjcDemoPage *components = [ObjcDemoPage pageWithTitle:@"Stroke and components"
                                               description:@"Control stroke gradient, eyes, mouth, accessories, and line width independently."
                                               accentColor:UIColor.systemOrangeColor
                                                     cases:@[gradient, star, heart, surprised]];

    ObjcDemoCase *waveform = [ObjcDemoCase caseWithTitle:@"Waveform" description:@"A full replacement path with face outline, eyes, and score-driven waveform mouth." value:6.5];
    waveform.lineWidth = 9; waveform.colorFrom = UIColor.systemBlueColor; waveform.colorTo = UIColor.systemTealColor; waveform.gradientFrom = waveform.colorFrom; waveform.gradientTo = waveform.colorTo; waveform.customPathMode = 1; waveform.pathKind = ObjcDemoPathKindWaveform;
    ObjcDemoCase *lightning = [ObjcDemoCase caseWithTitle:@"Lightning" description:@"A full replacement path that keeps the face outline around a branded inner symbol." value:8];
    lightning.lineWidth = 9; lightning.colorFrom = UIColor.systemOrangeColor; lightning.colorTo = UIColor.systemPinkColor; lightning.gradientFrom = lightning.colorFrom; lightning.gradientTo = lightning.colorTo; lightning.customPathMode = 1; lightning.pathKind = ObjcDemoPathKindLightning;
    ObjcDemoCase *crowned = [ObjcDemoCase caseWithTitle:@"Crowned" description:@"Overlay a custom crown on top of a built-in expression." value:9];
    crowned.colorFrom = UIColor.systemPurpleColor; crowned.colorTo = UIColor.systemGreenColor; crowned.gradientFrom = crowned.colorFrom; crowned.gradientTo = crowned.colorTo; crowned.expressionPreset = 1; crowned.customPathMode = 2; crowned.pathKind = ObjcDemoPathKindCrown;
    ObjcDemoCase *provider = [ObjcDemoCase caseWithTitle:@"Path delegate" description:@"Objective-C uses customPathDelegate to draw both outline and inner expression." value:7];
    provider.colorFrom = UIColor.systemBlueColor; provider.colorTo = UIColor.systemPurpleColor; provider.gradientFrom = provider.colorFrom; provider.gradientTo = provider.colorTo; provider.customPathMode = 1; provider.pathKind = ObjcDemoPathKindDiamond; provider.code = @"rateView.customEmojiPathMode = replace;\nrateView.customPathDelegate = delegate;";
    ObjcDemoPage *custom = [ObjcDemoPage pageWithTitle:@"Custom paths"
                                           description:@"Full path replacement and overlay support let consumers draw product-specific or branded rating graphics."
                                           accentColor:UIColor.systemPurpleColor
                                                 cases:@[waveform, lightning, crowned, provider]];

    return @[start, presets, faces, components, custom];
}

@end
