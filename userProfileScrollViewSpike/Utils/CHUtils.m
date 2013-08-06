//
//  CHUtils.m
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/31/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import "CHUtils.h"

@implementation CHUtils


+(UIColor *) randomColor{
    CGFloat hue = ( arc4random() % 360 / 360.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 100 / 100.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 100 / 100.0 ) + 0.5;  //  0.5 to 1.0, away from black
    CGFloat alpha = (arc4random() % 10 / 10.0) + 0.3; // 0.5 to 1.0, away from clear
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    return color;
}

+(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
