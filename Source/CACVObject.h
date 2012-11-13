//
//  CACVObject.h
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CColorCurve;

@interface CACVObject : NSObject <NSCoding>

@property (readonly, nonatomic, strong) NSURL *URL;
@property (readonly, nonatomic, strong) CColorCurve *RGBCurve;
@property (readonly, nonatomic, strong) CColorCurve *redCurve;
@property (readonly, nonatomic, strong) CColorCurve *greenCurve;
@property (readonly, nonatomic, strong) CColorCurve *blueCurve;

- (id)initWithURL:(NSURL *)inURL;

@end
