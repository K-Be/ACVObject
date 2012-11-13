//
//  NSImage+CGImage.m
//  GLFilter_OSX
//
//  Created by Jonathan Wight on 2/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSImage+CGImage.h"

@implementation NSImage (CGImage)

+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage;
    {
	NSBitmapImageRep *theBitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
	NSImage *theImage = [[NSImage alloc] initWithSize:(NSSize){ CGImageGetWidth(cgImage), CGImageGetHeight(cgImage) }];
	[theImage addRepresentation:theBitmapImageRep];
	return(theImage);
    }

- (CGImageRef)CGImage
	{
	NSArray *theBitmapImageReps = [self.representations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [NSBitmapImageRep class]]];
	NSBitmapImageRep *theBitmapImageRep = [theBitmapImageReps lastObject];
	if (theBitmapImageRep == NULL)
		{
		[self lockFocus];
		theBitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:(CGRect){ .size = self.size }];
		[self unlockFocus];
		}
	
	
	return(theBitmapImageRep.CGImage);
	}

@end
