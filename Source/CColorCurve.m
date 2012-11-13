//
//  CColorCurve.m
//  ACVViewer
//
//  Created by Jonathan Wight on 3/22/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CColorCurve.h"
#import "curve.h"

#if TARGET_OS_IPHONE || TARGET_OS_EMBEDDED
#import <UIKit/UIGeometry.h>
#else
#import "NSValue+CG.h"
#endif

#define lerp(t, a, b) ( a + t * (b - a) )

@interface CColorCurve ()
@property (readwrite, nonatomic, strong) CColorCurve *masterCurve;
@property (readonly, nonatomic, assign) CGImageRef image;
@end

#pragma mark -

@implementation CColorCurve

@synthesize name = _name;
@synthesize points = _points;
@synthesize interpolatedPoints = _interpolatedPoints;
@synthesize LUT = _LUT;
@synthesize masterCurve = _masterCurve;
@synthesize identity = _identity;
@synthesize image = _image;

- (id)initWithName:(NSString *)inName points:(NSArray *)inPoints masterCurve:(CColorCurve *)inMasterCurve;
    {
    if ((self = [super init]) != NULL)
        {
		_name = inName;
        _points = inPoints;
		_masterCurve = inMasterCurve;
        }
    return(self);
    }

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [self init]) != NULL)
        {
		_name = [inCoder decodeObjectForKey:@"name"];
		_points = [inCoder decodeObjectForKey:@"points"];
		_masterCurve = [inCoder decodeObjectForKey:@"masterCurve"];
        }
    return(self);
    }

- (void)encodeWithCoder:(NSCoder *)aCoder
	{
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.points forKey:@"points"];
	[aCoder encodeObject:self.masterCurve forKey:@"masterCurve"];
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (%@)", [super description], self.name]);
    }


- (NSArray *)interpolatedPoints
	{
	if (_interpolatedPoints == NULL)
		{
		_interpolatedPoints = PointsInCurve(self.points);
		}
	return(_interpolatedPoints);
	}

- (NSData *)LUT
	{
	if (_LUT == NULL)
		{
		UInt8 theBuffer[256] = {};

		CGPoint theCurrentPoint = {
			.x = 0.0,
			.y = [[self.points objectAtIndex:0] CGPointValue].y,
			};

		for (NSValue *theValue in self.interpolatedPoints)
			{
			CGPoint theNewPoint = [theValue CGPointValue];
			
			for (CGFloat X = theCurrentPoint.x; X <= theNewPoint.x; ++X)
				{
				CGFloat V = lerp((X - theCurrentPoint.x) / (theNewPoint.x - theCurrentPoint.x), theCurrentPoint.y, theNewPoint.y);
				theBuffer[(int)X] = round(V);
				}
			
			theBuffer[(int)round(theNewPoint.x)] = round(theNewPoint.y);
			
			theCurrentPoint = theNewPoint;
			}

		for (CGFloat X = theCurrentPoint.x; X < 256; ++X)
			{
			CGFloat V = lerp((X - theCurrentPoint.x) / (256 - theCurrentPoint.x), theCurrentPoint.y, theCurrentPoint.y);
			theBuffer[(int)X] = round(V);
			}
			
		BOOL theIdentityFlag = YES;

		if (self.masterCurve)
			{
			const UInt8 *theMasterBuffer = [self.masterCurve.LUT bytes];
			
			UInt8 theConvertedBuffer[256];
			
			for (int N = 0; N != 256; ++N)
				{
				theConvertedBuffer[N] = theMasterBuffer[theBuffer[N]];
				if (theIdentityFlag == YES)
					{
					if (theConvertedBuffer[N] != N)
						{
						theIdentityFlag = NO;
						}
					}
				}
			_LUT = [NSData dataWithBytes:theConvertedBuffer length:256];
			}
		else
			{
			_LUT = [NSData dataWithBytes:theBuffer length:256];

			for (int N = 0; N != 256; ++N)
				{
				if (theIdentityFlag == YES)
					{
					if (theBuffer[N] != N)
						{
						theIdentityFlag = NO;
						}
					}
				}
			}

		_identity = theIdentityFlag;
		}
	return(_LUT);
	}
	
- (CGImageRef)CGImage
	{
    if (_image == NULL)
        {
        NSData *theLUT = self.LUT;

        const UInt8 *theBuffer = [theLUT bytes];
        
        CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceGray();
        
        CGContextRef theContext = CGBitmapContextCreateWithData((void *)theBuffer, 256, 1, 8, 256, theColorSpace, kCGImageAlphaNone, NULL, NULL);
        
        CGColorSpaceRelease(theColorSpace);
        
        _image = CGBitmapContextCreateImage(theContext);

        CGContextRelease(theContext);
        }
    return(_image);
	}

@end
