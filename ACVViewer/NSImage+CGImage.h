//
//  NSImage+CGImage.h
//  GLFilter_OSX
//
//  Created by Jonathan Wight on 2/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (CGImage)

+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage;

- (CGImageRef)CGImage;

@end
