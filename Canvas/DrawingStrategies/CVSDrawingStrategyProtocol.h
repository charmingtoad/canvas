//
//  CVSDrawingStrategyProtocol.h
//  Canvas
//
//  Created by Linda Morton on 8/5/15.
//  Copyright (c) 2015 Linda Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CVSDrawingStrategyProtocol <NSObject>

/**
 Returns the area that the last call to drawSegments affected.
 */
@property (nonatomic, readonly) CGRect lastUpdatedArea;

/**
 Draws undrawnSegments with the provided context.
 */
- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context;

@end
