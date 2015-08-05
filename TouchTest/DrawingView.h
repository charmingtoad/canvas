//
//  DrawingView.h
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawingStrategy;

@interface DrawingView : UIView
{
    UIButton* clearButton;
    UISegmentedControl* drawingStrategySelectionControl;
    
    NSMutableArray* undrawnSegments;
    
    DrawingStrategy* drawingStrategy;
}

@end
