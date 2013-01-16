//
//  SquareDrawingStrategy.m
//  TouchTest
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "BoxDrawingStrategy.h"
#import "LineSegment.h"

@implementation BoxDrawingStrategy

- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context
{
    CGRect updateRect = CGRectZero;
    
    lastUpdatedArea = CGRectZero;
    
    float const lineWidth = 2.0f;
    
    CGContextSetLineWidth(context, lineWidth);
    
    for (LineSegment* segment in undrawnSegments)
    {
        CGContextSetFillColorWithColor(context, segment.color.CGColor);
        
        CGRect startRect = CGRectMake (segment.start.x - (lineWidth / 2.0f), segment.start.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        CGRect endRect = CGRectMake (segment.end.x - (lineWidth / 2.0f), segment.end.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        
        if (CGRectEqualToRect(lastUpdatedArea, CGRectZero))
        {
            updateRect = CGRectUnion(startRect, endRect);
            lastUpdatedArea = updateRect;
        }
        else
        {
            updateRect = CGRectUnion(startRect, endRect);
            lastUpdatedArea = CGRectUnion(lastUpdatedArea, updateRect);
        }
        CGContextFillRect(context, updateRect);
    }
}

@end
