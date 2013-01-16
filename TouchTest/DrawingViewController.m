//
//  DrawingViewController.m
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "DrawingViewController.h"
#import "DrawingView.h"

@interface DrawingViewController ()

@end

@implementation DrawingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	DrawingView* gestureView = [[DrawingView alloc] initWithFrame: self.view.bounds];
    [self.view addSubview: gestureView];
    [gestureView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
