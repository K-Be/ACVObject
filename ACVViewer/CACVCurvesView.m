//
//  CACVCurvesView.m
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CACVCurvesView.h"

#import <QuartzCore/QuartzCore.h>

#import "CACVObject.h"
#import "CColorCurve.h"

#if TARGET_OS_IPHONE == 0
#import "NSColor+CG.h"
#endif /* TARGET_OS_IPHONE == 0 */

@interface CACVCurvesView ()
@property (readwrite, nonatomic, strong) CAShapeLayer *RGBCurveLayer;
@property (readwrite, nonatomic, strong) CAShapeLayer *redCurveLayer;
@property (readwrite, nonatomic, strong) CAShapeLayer *greenCurveLayer;
@property (readwrite, nonatomic, strong) CAShapeLayer *blueCurveLayer;

- (CAShapeLayer *)layerForCurve:(CColorCurve *)inCurve color:(CGColorRef)inColor phase:(CGFloat)inPhase;
@end

#pragma mark -

@implementation CACVCurvesView

- (id)initWithFrame:(NSRect)inFrame
    {
    if ((self = [super initWithFrame:inFrame]) != NULL)
        {
		self.wantsLayer = YES;
        }
    return(self);
    }

- (void)setACVObject:(CACVObject *)ACVObject
	{
	if (_ACVObject != ACVObject)
		{
		_ACVObject = ACVObject;

		[self.RGBCurveLayer removeFromSuperlayer];
		self.RGBCurveLayer = [self layerForCurve:self.ACVObject.RGBCurve color:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor phase:0.0];
		[self.layer addSublayer:self.RGBCurveLayer];

		[self.redCurveLayer removeFromSuperlayer];
		self.redCurveLayer = [self layerForCurve:self.ACVObject.redCurve color:[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor phase:0.25];
		[self.layer addSublayer:self.redCurveLayer];

		[self.greenCurveLayer removeFromSuperlayer];
		self.greenCurveLayer = [self layerForCurve:self.ACVObject.greenCurve color:[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:1.0].CGColor phase:0.5];
		[self.layer addSublayer:self.greenCurveLayer];

		[self.blueCurveLayer removeFromSuperlayer];
		self.blueCurveLayer = [self layerForCurve:self.ACVObject.blueCurve color:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0].CGColor phase:0.75];
		[self.layer addSublayer:self.blueCurveLayer];
		}
	}

- (CAShapeLayer *)layerForCurve:(CColorCurve *)inCurve color:(CGColorRef)inColor phase:(CGFloat)inPhase
	{
	CAShapeLayer *theCurveLayer = [CAShapeLayer layer];
	theCurveLayer.strokeColor = inColor;
	theCurveLayer.fillColor = NULL;

	for (NSValue *theValue in inCurve.points)
		{
		CGPoint thePoint = [theValue pointValue];
		CAShapeLayer *theControlPointLayer = [CAShapeLayer layer];
		theControlPointLayer.position = thePoint;
		theControlPointLayer.fillColor = inColor;

        CGPathRef thePath = CGPathCreateWithEllipseInRect((CGRect){ -1.5, -1.5, 3, 3 }, NULL);
		theControlPointLayer.path = thePath;
        CFRelease(thePath);
		[theCurveLayer addSublayer:theControlPointLayer];
		}
	CGMutablePathRef thePath = CGPathCreateMutable();
	CGPoint thePoint = [[inCurve.points objectAtIndex:0] pointValue];
	CGPathMoveToPoint(thePath, NULL, thePoint.x, thePoint.y);
	for (NSValue *theValue in inCurve.interpolatedPoints)
		{
		thePoint = [theValue pointValue];
		CGPathAddLineToPoint(thePath, NULL, thePoint.x, thePoint.y);
		}
	theCurveLayer.path = thePath;
    if (inPhase > 0.0)
        {
        theCurveLayer.lineDashPattern = @[ @(2.0), @(4.0)];
        theCurveLayer.lineDashPhase = inPhase * 6.0;
        }

    CFRelease(thePath);
	
	return(theCurveLayer);
	}

@end
