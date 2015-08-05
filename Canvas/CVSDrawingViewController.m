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
    
    CGFloat buttonBottomMargin = 12.0f;
    CGSize buttonSize = CGSizeMake(48.0f, 43.0f);
    NSInteger buttonCount = 5;
    CGFloat buttonViewWidth = buttonSize.width * buttonCount;
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(rootView.frame) - buttonViewWidth) / 2.0f,
                                                                 CGRectGetHeight(rootView.frame) - buttonSize.height - buttonBottomMargin,
                                                                 buttonViewWidth,
                                                                 buttonSize.height)];
    buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [rootView addSubview:buttonView];
    
    UIButton *lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lineButton setImage:[UIImage imageNamed:@"line-button"] forState:UIControlStateNormal];
    [lineButton addTarget:self action:@selector(lineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *boxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [boxButton setImage:[UIImage imageNamed:@"box-button"] forState:UIControlStateNormal];
    [boxButton addTarget:self action:@selector(boxButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rayButton setImage:[UIImage imageNamed:@"ray-button"] forState:UIControlStateNormal];
    [rayButton addTarget:self action:@selector(rayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clear-button"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"share-button"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *buttons = @[lineButton, boxButton, rayButton, clearButton, shareButton];
    CGFloat buttonLeft = 0.0f;
    for (UIButton *button in buttons)
    {
        button.frame = CGRectMake(buttonLeft, 0.0f, buttonSize.width, buttonSize.height);
        [buttonView addSubview:button];
        buttonLeft = CGRectGetMaxX(button.frame);
    }
    
    self.view = rootView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Button Callbacks

- (void)lineButtonTapped:(UIButton *)lineButton
{
    [self.drawingView setDrawingStrategy:[CVSLineDrawingStrategy new]];
}

- (void)boxButtonTapped:(UIButton *)boxButton
{
    [self.drawingView setDrawingStrategy:[CVSBoxDrawingStrategy new]];
}

- (void)rayButtonTapped:(UIButton *)rayButton
{
    [self.drawingView setDrawingStrategy:[CVSTriangleDrawingStrategy new]];
}

- (void)clearButtonTapped:(UIButton *)clearButton
{
    [self.drawingView clear];
}

- (void)shareButtonTapped:(UIButton *)shareButton
{
    UIImage *drawnImage = [self.drawingView image];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"I drew this for you!", drawnImage] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void) clearButtonPressed: (UIButton*) button
{
    [self.drawingView clear];
}

@end
