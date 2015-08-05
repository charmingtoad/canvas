//
//  AppDelegate.h
//  Canvas
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVSDrawingViewController;

@interface CVSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CVSDrawingViewController *viewController;

@end
