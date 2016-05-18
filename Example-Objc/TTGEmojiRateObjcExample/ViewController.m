//
//  ViewController.m
//  TTGEmojiRateObjcExample
//
//  Created by zorro on 16/5/18.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "ViewController.h"

@import TTGEmojiRate;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EmojiRateView* rateView = [[EmojiRateView alloc] initWithFrame:CGRectMake(20, 40, 280, 280)];
    [self.view addSubview:rateView];
    
    [rateView setRateValueChangeCallback:^(float newRateValue) {
        NSLog(@"Rate: %g", newRateValue);
    }];
}

@end
