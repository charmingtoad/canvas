
//  TriangleDrawingStrategy.m
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSTriangleDrawingStrategy.h"
#import "CVSLineSegment.h"

@interface CVSTriangleDrawingStrategy ()

@property (nonatomic, readwrite) CGRect lastUpdatedArea;

- (CGPoint) getPointProjectedFrom: (CGPoint) start atAngle: (float) radians forLength: (float) length;
- (float) getRadiansFromLineWithStart: (CGPoint) start end: (CGPoint) end;
- (float) lengthOfLineFromPoint: (CGPoint) point1 toPoint: (CGPoint) point2;

@end

@implementation CVSTriangleDrawingStrategy

- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context
{
    self.lastUpdatedArea = CGRectZero;
    
    float const lineWidth = 2.0f * [UIScreen mainScreen].scale;
    float const angleVariance = (M_PI / 10.0f);
    
    CGContextSetLineWidth(context, lineWidth);
    
    for (CVSLineSegment* segment in undrawnSegments)
    {
        float radians = -atan2(segment.end.y - segment.start.y, segment.start.x - segment.end.x);
        
        float distance = ([self lengthOfLineFromPoint:segment.start toPoint:segment.end] + 1) * 10.0f;
        CGContextSetFillColorWithColor(context, segment.color.CGColor);
        
        CGContextMoveToPoint(context, segment.start.x, segment.start.y);
        
        CGPoint point1 = [self getPointProjectedFrom:segment.start atAngle:radians - angleVariance forLength:distance];
        CGPoint point2 = [self getPointProjectedFrom:segment.start atAngle:radians + angleVariance forLength:distance];
        CGContextAddLineToPoint(context, point1.x, point1.y);
        CGContextAddLineToPoint(context, point2.x, point2.y);
        
        if (CGRectEqualToRect(self.lastUpdatedArea, CGRectZero))
        {
            self.lastUpdatedArea = CGContextGetPathBoundingBox(context);
        }
        else
        {
            CGRect unionRect = CGContextGetPathBoundingBox(context);
            self.lastUpdatedArea = CGRectUnion(self.lastUpdatedArea, unionRect);
        }
        CGContextFillPath(context);
    }
}

- (float) lengthOfLineFromPoint: (CGPoint) point1 toPoint: (CGPoint) point2
{
    if (CGPointEqualToPoint(point1, point2))
        return 0;
    else
        return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
}

- (float) getRadiansFromLineWithStart: (CGPoint) start end: (CGPoint) end
{
    CGPoint adjustedEndPoint = CGPointMake (end.x - start.x, end.y - start.y);
    
    float radians = atan(adjustedEndPoint.x/adjustedEndPoint.y);
    
    return radians;
}

- (CGPoint) getPointProjectedFrom: (CGPoint) start atAngle: (float) radians forLength: (float) length
{
    float x = length * cos(radians);
    float y = length * sin(radians);
    
    float adjustedRadians = radians;
    
    while (adjustedRadians < 0)
    {
        adjustedRadians += (2 * M_PI);
    }
    
    while (adjustedRadians > (2 * M_PI))
    {
        adjustedRadians -= (2 * M_PI);
    }
    return CGPointMake(x + start.x, y + start.y);
}

@end
