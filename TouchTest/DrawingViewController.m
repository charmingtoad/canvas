//
//  DrawingViewController.m
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "DrawingViewController.h"
#import "DrawingView.h"
#import "LineDrawingStrategy.h"
#import "BoxDrawingStrategy.h"
#import "TriangleDrawingStrategy.h"

@interface DrawingViewController ()

@property (nonatomic, strong) DrawingView *drawingView;

@end

@implementation DrawingViewController

- (void)loadView
{
    UIView *rootView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    rootView.backgroundColor = [UIColor whiteColor];
    
    self.drawingView = [[DrawingView alloc] initWithFrame:rootView.bounds];
    
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
                         @"Trianges", nil];
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
    
    DrawingStrategy *selectedDrawingStrategy;
    if (selectedIndex == 2)
    {
        selectedDrawingStrategy = [TriangleDrawingStrategy new];
    }
    else if (selectedIndex == 1)
    {
        selectedDrawingStrategy = [BoxDrawingStrategy new];
    }
    else
    {
        selectedDrawingStrategy = [LineDrawingStrategy new];
    }
    [self.drawingView setDrawingStrategy:selectedDrawingStrategy];
}

- (void) clearButtonPressed: (UIButton*) button
{
    [self.drawingView clear];
}

@end
