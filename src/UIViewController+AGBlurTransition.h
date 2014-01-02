//
//  UIViewController+AGBlurTransition.h
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGBlurTransitionDelegate.h"

@interface UIViewController (AGBlurTransition)

@property (nonatomic, strong) AGBlurTransitionDelegate *AG_blurTransitionDelegate;

@end
