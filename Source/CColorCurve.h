//
//  CColorCurve.h
//  ACVViewer
//
//  Created by Jonathan Wight on 3/22/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CColorCurve : NSObject <NSCoding>

@property (readonly, nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSArray *points; // Input points
@property (readonly, nonatomic, strong) NSArray *interpolatedPoints;
@property (readonly, nonatomic, strong) NSData *LUT; // Lookup table of bytes
@property (readonly, nonatomic, assign) BOOL identity;

- (id)initWithName:(NSString *)inName points:(NSArray *)inPoints masterCurve:(CColorCurve *)inMasterCurve;
- (CGImageRef)CGImage;

@end
