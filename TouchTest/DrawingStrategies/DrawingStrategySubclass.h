//
//  DrawingStrategySubclass.h
//  TouchTest
//
//  Created by Linda Morton on 8/4/15.
//  Copyright (c) 2015 Linda Morton. All rights reserved.
//

#import "DrawingStrategy.h"

/**
 "Protected" methods for the DrawingStrategy class.
 Import this class if you are a subclass of DrawingStrategy.
 */
@interface DrawingStrategy ()

/**
 The area that the last call to drawSegments affected.
 */
@property (nonatomic, assign) CGRect lastUpdatedArea;

@end