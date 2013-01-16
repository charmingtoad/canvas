//
//  UIColor+Extensions.m
//  TouchTest
//
//  Created by Linda Morton on 10/16/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor*) buttonOnColor
{
    return [UIColor colorWithRed:0.5f green:1.0f blue:0.5f alpha:1.0f];
}
+ (UIColor*) buttonOffColor
{
    return [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
}

+ (UIColor*) randomColor
{
    float randomRed     = (arc4random() % 101)/100.0f;
    float randomGreen   = (arc4random() % 101)/100.0f;
    float randomBlue    = (arc4random() % 101)/100.0f;
    
    UIColor* color = [UIColor colorWithRed: randomRed green: randomGreen blue: randomBlue alpha:1.0f];
    
    return color;
}

@end
