//
//  DrawingView.h
//  Canvas
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVSDrawingStrategy;

/**
 A canvas that draws touches to the screen. Visual representation
 of a touch depends on the current drawingStrategy.
 */
@interface CVSDrawingView : UIView

/**
 Determines the way touches on the canvas are drawn.
 */
@property (nonatomic, strong) CVSDrawingStrategy *drawingStrategy;

/**
 Removes all the drawings on the canvas.
 */
- (void)clear;

@end
