//
//  NSColor+CG.m
//  ACVViewer
//
//  Created by Jonathan Wight on 7/2/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSColor+CG.h"

#import <objc/runtime.h>

@implementation NSColor (CG)

- (CGColorRef)CGColor
    {
    CGColorRef theColor = CGColorCreateGenericRGB(self.redComponent, self.greenComponent, self.blueComponent, self.alphaComponent);

    const void *kKey;
    objc_setAssociatedObject(self, &kKey, (__bridge_transfer id)theColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return(theColor);
    }

@end
