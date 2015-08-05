//
//  SquareDrawingStrategy.h
//  TouchTest
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "DrawingStrategy.h"

/** 
 BoxDrawingStrategy draws a rectangle for each line segment where the
 line segment's start point becomes the upper left corner of the box and
 the line segment's end point becomes the lower right corner of the box.
 (In short, long lines translate to large boxes.)
 */

@interface BoxDrawingStrategy : DrawingStrategy

@end
