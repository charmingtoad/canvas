//
//  DrawingStrategy.h
//  TouchTest
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawingStrategy : NSObject
{
    @protected
    CGRect lastUpdatedArea;
}

/** Returns the area that the last call to drawSegments affected.
 */
@property (nonatomic, readonly) CGRect lastUpdatedArea;

/** Draws undrawnSegments with the provided context. 
 */
- (void) drawSegments: (NSArray*) undrawnSegments inContext: (CGContextRef) context;

@end
