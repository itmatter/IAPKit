//
//  UIViewController+ShakeVC.m
//  IAPKit
//
//  Created by 李礼光 on 2017/3/28.
//  Copyright © 2017年 李礼光. All rights reserved.
//

#import "UIViewController+ShakeVC.h"

@implementation UIViewController (ShakeVC)

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"XXX motionBegan");
    
    for (int i = 0; i<1100100; i++) {
        for (UIView *view in self.view.subviews) {
            if ([view canBecomeFirstResponder]) {
                [view motionBegan:motion withEvent:event];
            }
        }
        
    }
    NSLog(@"1111111111111111");
    return;
}

// 摇一摇取消摇动
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"XXX motionCancelled");
    for (UIView *view in self.view.subviews) {
        if ([view canBecomeFirstResponder]) {
            [view motionCancelled:motion withEvent:event];
        }
    }
    return;
}

// 摇一摇摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"XXX motionEnded");
    for (UIView *view in self.view.subviews) {
        if ([view canBecomeFirstResponder]) {
            [view motionEnded:motion withEvent:event];
        }
    }
    return;
}


@end
