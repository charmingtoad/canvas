//
//  ViewController.m
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "ViewController.h"
#import "GesturePrintingView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	GesturePrintingView* gestureView = [[GesturePrintingView alloc] initWithFrame: self.view.bounds];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
