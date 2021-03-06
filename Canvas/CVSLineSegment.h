//
//  LineSegment.h
//  Canvas
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVSLineSegment : NSObject

@property (nonatomic, strong) UIColor* color;
@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;

@end