//
//  AGBlurTransitionDelegate.m
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import "AGBlurTransitionDelegate.h"
#import <Accelerate/Accelerate.h>

@interface UIImage (AGBlurTransition)
- (UIImage *)AG_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
@end

@interface AGBlurTransitionDelegate ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, weak) UIImageView *bluredImageView;
@property (nonatomic, weak) UIViewController *originalViewController;

@end

@implementation AGBlurTransitionDelegate

- (id)init {
    self = [super init];
    if (self) {
        _duration = 0.5f;
        _tintColor = [UIColor colorWithWhite:0 alpha:0.3];
        _blurRadius = 20;
        _saturationDeltaFactor = 1.8;
        _insets = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if (!self.originalViewController) {
        self.originalViewController = fromViewController;
    }
    
    if (fromViewController == self.originalViewController) {
        [self animateOpenTransition:transitionContext];
    }
    else if (toViewController == self.originalViewController) {
        [self animateCloseTransition:transitionContext];
    }
    else {
        [[transitionContext containerView] addSubview:toViewController.view];
        [transitionContext completeTransition:YES];
        //TODO: Handle error!
    }
}


#pragma mark - Helpers

- (void)animateOpenTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    UIView *containerView = [transitionContext containerView];
    
    // Add the view and backgrounds
    UIImage *originalImage = [self createImageFromView:fromViewController.view];
    self.backgroundView = [[UIView alloc] initWithFrame:finalFrame];
    UIImageView *blurImageView = [[UIImageView alloc] initWithFrame:self.backgroundView.bounds];
    blurImageView.image = [originalImage AG_applyBlurWithRadius:self.blurRadius
                                                      tintColor:self.tintColor
                                          saturationDeltaFactor:self.saturationDeltaFactor
                                                      maskImage:nil];
    self.bluredImageView = blurImageView;
    [self.backgroundView addSubview:self.bluredImageView];
    [self.backgroundView addSubview:toViewController.view];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    toViewController.view.frame = UIEdgeInsetsInsetRect(finalFrame, self.insets);
    [containerView addSubview:self.backgroundView];
    
    // Set initial state of animation
    toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    self.bluredImageView.alpha = 0.0;
    
    // Animate
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         toViewController.view.transform = CGAffineTransformIdentity;
                         blurImageView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         // Inform the context of completion
                         [transitionContext completeTransition:YES];
                         
                         //Hack! the view controller is resized and background view moved out of the transition view. We need to replace it
                         UIView *parent = toViewController.view.superview;
                         [self.backgroundView addSubview:toViewController.view];
                         [parent addSubview:self.backgroundView];
                     }];
}

- (void)animateCloseTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    // Obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    UIView *containerView = [transitionContext containerView];
    
    // Add the view and backgrounds
    [containerView addSubview:toViewController.view];
    [containerView addSubview:self.bluredImageView];
    [containerView addSubview:fromViewController.view];
    
    // Animate with keyframes
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  // keyframe one
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.2
                                                                animations:^{
                                                                    fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                                                                }];
                                  // keyframe two
                                  [UIView addKeyframeWithRelativeStartTime:0.2
                                                          relativeDuration:0.6
                                                                animations:^{
                                                                    fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.00001, 0.00001);
                                                                    self.bluredImageView.alpha = 0.0;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1.0
                                                                animations:^{
                                                                    self.bluredImageView.alpha = 0.0;
                                                                }];
                              }
                              completion:^(BOOL finished) {
                                  [self.bluredImageView removeFromSuperview];
                                  self.backgroundView = nil;
                                  [transitionContext completeTransition:YES];
                              }];
}


- (UIImage *)createImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end


@implementation UIImage(AGBlurTransition)


- (UIImage *)AG_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // check pre-conditions
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // set up output context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // draw base image
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // draw effect image
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // add in color tint
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // output image is ready
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end
