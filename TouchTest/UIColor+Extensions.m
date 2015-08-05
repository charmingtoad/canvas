//
//  UIColor+Extensions.m
//  TouchTest
//
//  Created by Linda Morton on 10/16/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor*) randomColor
{
    float randomRed     = (arc4random() % 101)/100.0f;
    float randomGreen   = (arc4random() % 101)/100.0f;
    float randomBlue    = (arc4random() % 101)/100.0f;
    
    UIColor* color = [UIColor colorWithRed: randomRed green: randomGreen blue: randomBlue alpha:1.0f];
    
    return color;
}

@end
