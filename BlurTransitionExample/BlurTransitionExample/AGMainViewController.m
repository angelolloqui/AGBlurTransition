//
//  AGMainViewController.m
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import "AGMainViewController.h"
#import "AGModalViewController.h"
#import "UIViewController+AGBlurTransition.h"

@interface AGMainViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation AGMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openModalAction:(id)sender {
    self.modalPresentationStyle = UIModalPresentationCustom;
    AGModalViewController *vc = [[AGModalViewController alloc] init];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.AG_blurTransitionDelegate;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.AG_blurTransitionDelegate;
}


@end
