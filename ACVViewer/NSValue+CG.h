//
//  NSValue+CG.h
//  ACVViewer
//
//  Created by Jonathan Wight on 3/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (CG)

+ (NSValue *)valueWithCGPoint:(CGPoint)inPoint;
- (CGPoint)CGPointValue;

@end
