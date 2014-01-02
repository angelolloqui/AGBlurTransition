//
//  AGBlurTransitionDelegate.h
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGBlurTransitionDelegate : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat saturationDeltaFactor;
@property (nonatomic, strong) UIColor *tintColor;

@end
