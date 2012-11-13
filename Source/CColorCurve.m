//
//	CColorCurve.m
//	ACVObject
//
//	Created by Jonathan Wight on 3/22/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

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
