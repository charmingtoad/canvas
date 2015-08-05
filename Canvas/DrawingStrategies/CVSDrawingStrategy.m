//
//  DrawingStrategy.m
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSDrawingStrategy.h"
#import "DrawingStrategySubclass.h"

@implementation CVSDrawingStrategy

@synthesize lastUpdatedArea;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.lastUpdatedArea = CGRectZero;
    }
    return self;
}

- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context
{
    [NSException raise: @"DrawingStrategy is an abstract class."
                format: @"You must implement drawSegments:inContext: in a concrete subclass before you can use it!"];
}

@end
