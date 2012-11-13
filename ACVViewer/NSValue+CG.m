//
//  NSValue+CG.m
//  ACVViewer
//
//  Created by Jonathan Wight on 3/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSValue+CG.h"

@implementation NSValue (CG)

+ (NSValue *)valueWithCGPoint:(CGPoint)inPoint
	{
	return([self valueWithPoint:inPoint]);
	}
	
- (CGPoint)CGPointValue
	{
	return([self pointValue]);
	}

@end
