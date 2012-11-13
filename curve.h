//
//  curve.h
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#ifndef __ACVViewer__curve__
#define __ACVViewer__curve__

extern void EnumeratePointsInCurve(NSArray *inPoints, void (^inBlock)(CGPoint));
extern NSArray *PointsInCurve(NSArray *inPoints);

#endif /* defined(__ACVViewer__curve__) */
