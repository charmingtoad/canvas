//
//  LineSegment.h
//  TouchTest
//
//  Created by Linda Morton on 10/15/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineSegment : NSObject

@property (nonatomic, strong) UIColor* color;
@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;

@end