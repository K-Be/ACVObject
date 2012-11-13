//
//	CACVObject.m
//	ACVObject
//
//	Created by Jonathan Wight on 3/20/12.
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

#import "CACVObject.h"
#import "CDataScanner.h"
#import "CColorCurve.h"

#if TARGET_OS_IPHONE || TARGET_OS_EMBEDDED
#import <UIKit/UIGeometry.h>
#else
#import "NSValue+CG.h"
#endif

@interface CACVObject ()
- (BOOL)read:(NSError **)outError;
@end

#pragma mark -

@implementation CACVObject

@synthesize URL = _URL;
@synthesize RGBCurve = _RGBCurve;
@synthesize redCurve = _redCurve;
@synthesize greenCurve = _greenCurve;
@synthesize blueCurve = _blueCurve;

- (id)initWithURL:(NSURL *)inURL;
    {
    if ((self = [super init]) != NULL)
        {
		_URL = inURL;
		
		if ([self read:NULL] == NO)
			{
			self = NULL;
			return(self);
			}
        }
    return self;
    }
	
- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [self init]) != NULL)
        {
		_URL = [inCoder decodeObjectForKey:@"URL"];
		_RGBCurve = [inCoder decodeObjectForKey:@"RGBCurve"];
		_redCurve = [inCoder decodeObjectForKey:@"redCurve"];
		_greenCurve = [inCoder decodeObjectForKey:@"greenCurve"];
		_blueCurve = [inCoder decodeObjectForKey:@"blueCurve"];
        }
    return(self);
    }

- (void)encodeWithCoder:(NSCoder *)aCoder
	{
	[aCoder encodeObject:self.URL forKey:@"URL"];
	[aCoder encodeObject:self.RGBCurve forKey:@"RGBCurve"];
	[aCoder encodeObject:self.redCurve forKey:@"redCurve"];
	[aCoder encodeObject:self.greenCurve forKey:@"greenCurve"];
	[aCoder encodeObject:self.blueCurve forKey:@"blueCurve"];
	}

- (BOOL)read:(NSError **)outError
	{
	NSData *theData = [NSData dataWithContentsOfURL:self.URL];
	CDataScanner *theScanner = [[CDataScanner alloc] initWithData:theData];
	theScanner.endianness = DataScannerEndianness_Big;

	short theVersion = 0;
	if ([theScanner scanIntoShort:&theVersion] == NO)
		{
		return(NO);
		}
	
	short theCountOfCurves = 0;
	if ([theScanner scanIntoShort:&theCountOfCurves] == NO)
		{
		return(NO);
		}
	
	NSMutableArray *theCurves = [NSMutableArray array];
	
	for (short theCurveIndex = 0; theCurveIndex != theCountOfCurves; ++theCurveIndex)
		{
		short theCountOfPoints = 0;
		if ([theScanner scanIntoShort:&theCountOfPoints] == NO)
			{
			return(NO);
			}

		NSMutableArray *thePoints = [NSMutableArray array];
		for (int thePointIndex = 0; thePointIndex != theCountOfPoints; ++thePointIndex)
			{
			short theOutput = 0;
			if ([theScanner scanIntoShort:&theOutput] == NO)
				{
				return(NO);
				}
			short theInput = 0;
			if ([theScanner scanIntoShort:&theInput] == NO)
				{
				return(NO);
				}
				
			CGPoint thePoint = { theInput, theOutput };
			[thePoints addObject:[NSValue valueWithCGPoint:thePoint]];
			}
			
		[theCurves addObject:thePoints];
		}
		
	_RGBCurve = [[CColorCurve alloc] initWithName:@"RGB" points:[theCurves objectAtIndex:0] masterCurve:NULL];
	_redCurve = [[CColorCurve alloc] initWithName:@"red" points:[theCurves objectAtIndex:1] masterCurve:_RGBCurve];
	_greenCurve = [[CColorCurve alloc] initWithName:@"green" points:[theCurves objectAtIndex:2] masterCurve:_RGBCurve];
	_blueCurve = [[CColorCurve alloc] initWithName:@"blue" points:[theCurves objectAtIndex:3] masterCurve:_RGBCurve];
	
	return(YES);
	}

@end
