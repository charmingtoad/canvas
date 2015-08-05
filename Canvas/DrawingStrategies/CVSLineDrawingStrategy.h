//
//  LineDrawingStrategy.h
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CVSDrawingStrategyProtocol.h"

/** 
 LineDrawingStrategy can be used to draw straight lines from each segment's
 start point to end point.
 */

@interface CVSLineDrawingStrategy : NSObject <CVSDrawingStrategyProtocol>

@end
