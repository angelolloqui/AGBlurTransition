//
//  AGModalViewController.m
//  BlurTransitionExample
//
//  Created by Angel Garcia on 02/01/14.
//  Copyright (c) 2014 angelolloqui.com. All rights reserved.
//

#import "AGModalViewController.h"

@interface AGModalViewController ()

@end

@implementation AGModalViewController

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
- (IBAction)dismissModalAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
