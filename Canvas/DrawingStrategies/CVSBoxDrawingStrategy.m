//
//  SquareDrawingStrategy.m
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSBoxDrawingStrategy.h"
#import "DrawingStrategySubclass.h"
#import "CVSLineSegment.h"

@implementation CVSBoxDrawingStrategy

- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context
{
    CGRect updateRect = CGRectZero;
    
    self.lastUpdatedArea = CGRectZero;
    
    float const lineWidth = 2.0f * [UIScreen mainScreen].scale;
    
    CGContextSetLineWidth(context, lineWidth);
    
    for (CVSLineSegment* segment in undrawnSegments)
    {
        CGContextSetFillColorWithColor(context, segment.color.CGColor);
        
        CGRect startRect = CGRectMake (segment.start.x - (lineWidth / 2.0f), segment.start.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        CGRect endRect = CGRectMake (segment.end.x - (lineWidth / 2.0f), segment.end.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        
        if (CGRectEqualToRect(self.lastUpdatedArea, CGRectZero))
        {
            updateRect = CGRectUnion(startRect, endRect);
            self.lastUpdatedArea = updateRect;
        }
        else
        {
            updateRect = CGRectUnion(startRect, endRect);
            self.lastUpdatedArea = CGRectUnion(self.lastUpdatedArea, updateRect);
        }
        CGContextFillRect(context, updateRect);
    }
}

@end
