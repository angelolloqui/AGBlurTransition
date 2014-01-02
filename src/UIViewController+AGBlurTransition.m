//
//  UIViewController+AGBlurTransition.m
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import "UIViewController+AGBlurTransition.h"
#import <objc/runtime.h>

@implementation UIViewController (AGBlurTransition)

static void *const kAGBlurTransitionDelegateKey = (void *)&kAGBlurTransitionDelegateKey;
- (void)setAG_blurTransitionDelegate:(AGBlurTransitionDelegate *)AG_blurTransitionDelegate {
    objc_setAssociatedObject(self, kAGBlurTransitionDelegateKey, AG_blurTransitionDelegate, OBJC_ASSOCIATION_RETAIN);
}

- (AGBlurTransitionDelegate *)AG_blurTransitionDelegate {
    AGBlurTransitionDelegate *delegate = objc_getAssociatedObject(self, kAGBlurTransitionDelegateKey);
    if (!delegate) {
        delegate = [AGBlurTransitionDelegate new];
        [self setAG_blurTransitionDelegate:delegate];
    }
    return delegate;
}

@end
