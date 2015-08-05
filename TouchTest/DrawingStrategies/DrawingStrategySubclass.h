//
//  DrawingStrategySubclass.h
//  TouchTest
//
//  Created by Linda Morton on 8/4/15.
//  Copyright (c) 2015 William O'Neil. All rights reserved.
//

#import "DrawingStrategy.h"

/**
 "Protected" methods for the DrawingStrategy class.
 Import this class if you are a subclass of DrawingStrategy.
 */
@interface DrawingStrategy (DrawingStrategyProtected)

@property (nonatomic, assign) CGRect lastUpdatedArea;

@end