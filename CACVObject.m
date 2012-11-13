//
//  CACVObject.m
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

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
