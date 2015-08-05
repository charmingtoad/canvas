//
//  LineDrawingStrategy.m
//  TouchTest
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "DrawingStrategySubclass.h"
#import "LineDrawingStrategy.h"
#import "LineSegment.h"

@implementation LineDrawingStrategy

- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context
{
    self.lastUpdatedArea = CGRectZero;
    
    float const lineWidth = 2.0f;
    
    CGContextSetLineWidth(context, lineWidth);
    
    for (LineSegment* segment in undrawnSegments)
    {
        if (!CGPointEqualToPoint(segment.start, segment.end))
        {
            CGContextSetStrokeColorWithColor(context, segment.color.CGColor);
            CGContextMoveToPoint(context, segment.start.x, segment.start.y);
            CGContextAddLineToPoint(context, segment.end.x, segment.end.y);
            CGContextStrokePath (context);
        }
        else
        {
            CGContextSetFillColorWithColor(context, segment.color.CGColor);
            CGContextFillRect(context, CGRectMake(segment.start.x - (lineWidth / 2.0f), segment.start.y - (lineWidth / 2.0f), lineWidth, lineWidth));
        }
        
        CGRect startRect = CGRectMake (segment.start.x - (lineWidth / 2.0f), segment.start.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        CGRect endRect = CGRectMake (segment.end.x - (lineWidth / 2.0f), segment.end.y - (lineWidth / 2.0f), lineWidth, lineWidth);
        
        if (CGRectEqualToRect(self.lastUpdatedArea, CGRectZero))
        {
            self.lastUpdatedArea = CGRectUnion(startRect, endRect);
        }
        else
        {
            CGRect unionRect = CGRectUnion(startRect, endRect);
            self.lastUpdatedArea = CGRectUnion(self.lastUpdatedArea, unionRect);
        }
    }
}

@end
