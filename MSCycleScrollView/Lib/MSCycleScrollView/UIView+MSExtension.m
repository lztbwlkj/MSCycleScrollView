//
//  UIView+MSExtension.m
//  MSCycleScrollView
//
//  Created by TuBo on 2018/12/28.
//  Copyright © 2018 turBur. All rights reserved.
//

#import "UIView+MSExtension.h"

@implementation UIView (MSExtension)
- (CGFloat)ms_height
{
    return self.frame.size.height;
}

- (void)setMs_height:(CGFloat)ms_height
{
    CGRect temp = self.frame;
    temp.size.height = ms_height;
    self.frame = temp;
}

- (CGFloat)ms_width
{
    return self.frame.size.width;
}

- (void)setMs_width:(CGFloat)ms_width
{
    CGRect temp = self.frame;
    temp.size.width = ms_width;
    self.frame = temp;
}


- (CGFloat)ms_y
{
    return self.frame.origin.y;
}

- (void)setMs_y:(CGFloat)ms_y
{
    CGRect temp = self.frame;
    temp.origin.y = ms_y;
    self.frame = temp;
}

- (CGFloat)ms_x
{
    return self.frame.origin.x;
}

- (void)setMs_x:(CGFloat)ms_x
{
    CGRect temp = self.frame;
    temp.origin.x = ms_x;
    self.frame = temp;
}


@end
