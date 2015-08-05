//
//  DrawingViewController.m
//  Canvas
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSDrawingViewController.h"
#import "CVSDrawingView.h"
#import "CVSLineDrawingStrategy.h"
#import "CVSBoxDrawingStrategy.h"
#import "CVSTriangleDrawingStrategy.h"

@interface CVSDrawingViewController ()

@property (nonatomic, strong) CVSDrawingView *drawingView;

@end

@implementation CVSDrawingViewController

- (void)loadView
{
    UIView *rootView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    rootView.backgroundColor = [UIColor whiteColor];
    
    self.drawingView = [[CVSDrawingView alloc] initWithFrame:rootView.bounds];
    
//    DrawingView needs some re-working before it can handle being resized.
//    Currently resizing can cause drawn lines to get visually broken up.
//    self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [rootView addSubview:self.drawingView];
    
    UIButton *clearButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [clearButton setTitle: @"Clear" forState:UIControlStateNormal];
    [clearButton addTarget: self action: @selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat buttonHeight = 50.0f;
    clearButton.frame = CGRectMake (0.0f,
                                    CGRectGetHeight(rootView.frame) - buttonHeight,
                                    CGRectGetWidth(rootView.frame),
                                    buttonHeight);
    clearButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [rootView addSubview: clearButton];
    
    NSArray* segments = [NSArray arrayWithObjects:
                         @"Lines",
                         @"Boxes",
                         @"Triangles", nil];
    UISegmentedControl* drawingStrategySelectionControl = [[UISegmentedControl alloc] initWithItems: segments];
    drawingStrategySelectionControl.frame = CGRectMake (0.0f,
                                                        CGRectGetHeight(rootView.frame) - (2 * buttonHeight),
                                                        CGRectGetWidth(rootView.frame),
                                                        buttonHeight);
    drawingStrategySelectionControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [drawingStrategySelectionControl addTarget: self
                                        action: @selector(drawingStrategySelected:)
                              forControlEvents:UIControlEventValueChanged];
    
    [rootView addSubview: drawingStrategySelectionControl];
    
    // default will be line drawing
    [drawingStrategySelectionControl setSelectedSegmentIndex: 0];

    self.view = rootView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Button Callbacks

- (void) drawingStrategySelected: (id) sender
{
    NSInteger selectedIndex = [sender selectedSegmentIndex];
    
    CVSDrawingStrategy *selectedDrawingStrategy;
    if (selectedIndex == 2)
    {
        selectedDrawingStrategy = [CVSTriangleDrawingStrategy new];
    }
    else if (selectedIndex == 1)
    {
        selectedDrawingStrategy = [CVSBoxDrawingStrategy new];
    }
    else
    {
        selectedDrawingStrategy = [CVSLineDrawingStrategy new];
    }
    [self.drawingView setDrawingStrategy:selectedDrawingStrategy];
}

- (void) clearButtonPressed: (UIButton*) button
{
    [self.drawingView clear];
}

@end
