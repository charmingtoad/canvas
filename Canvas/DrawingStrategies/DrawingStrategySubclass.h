//
//  DrawingStrategySubclass.h
//  Canvas
//
//  Created by Linda Morton on 8/4/15.
//  Copyright (c) 2015 Linda Morton. All rights reserved.
//

#import "CVSDrawingStrategy.h"

/**
 "Protected" methods for the DrawingStrategy class.
 Import this class if you are a subclass of DrawingStrategy.
 */
@interface CVSDrawingStrategy ()

/**
 The area that the last call to drawSegments affected.
 */
@property (nonatomic, assign) CGRect lastUpdatedArea;

@end