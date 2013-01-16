//
//  DrawingView.h
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <map>

@class DrawingStrategy;

using namespace std;

@interface DrawingView : UIView
{
    UIButton* clearButton;
    UISegmentedControl* drawingStrategySelectionControl;
    
    map<UITouch*,UIColor*>colorForTouch;
    NSMutableArray* undrawnSegments;
    
    CGContextRef cacheContext;
    
    DrawingStrategy* drawingStrategy;
}

@end
