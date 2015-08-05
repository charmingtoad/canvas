//
//  UIColor+Extensions.m
//  Canvas
//
//  Created by Linda Morton on 10/16/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "UIColor+CVSExtensions.h"

@implementation UIColor (CVSExtensions)

+ (UIColor*) cvs_randomColor
{
    float randomRed     = (arc4random() % 101)/100.0f;
    float randomGreen   = (arc4random() % 101)/100.0f;
    float randomBlue    = (arc4random() % 101)/100.0f;
    
    UIColor* color = [UIColor colorWithRed: randomRed green: randomGreen blue: randomBlue alpha:1.0f];
    
    return color;
}

@end
