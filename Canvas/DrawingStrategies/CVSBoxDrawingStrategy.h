//
//  SquareDrawingStrategy.h
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSDrawingStrategyProtocol.h"

/** 
 BoxDrawingStrategy draws a rectangle for each line segment where the
 line segment's start point becomes the upper left corner of the box and
 the line segment's end point becomes the lower right corner of the box.
 (In short, long lines translate to large boxes.)
 */

@interface CVSBoxDrawingStrategy : NSObject <CVSDrawingStrategyProtocol>

@end
