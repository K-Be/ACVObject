//
//  curve.cpp
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

//#include "curve.h"

#if TARGET_OS_IPHONE || TARGET_OS_EMBEDDED
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIGeometry.h>
#else
#import <CoreServices/CoreServices.h>
#import "NSValue+CG.h"
#endif

#include <vector>

const std::vector <double> secondDerivative(const std::vector <CGPoint> P);
const std::vector <CGPoint> curve(const std::vector <CGPoint> points);

const std::vector <double> secondDerivative(const std::vector <CGPoint> P)
	{
	std::vector <CGPoint>::size_type n = P.size();

	// build the tridiagonal system
	// (assume 0 boundary conditions: y2[0]=y2[-1]=0)
	double matrix[n][3];
	double result[n];

    for (int N = 0; N != n; ++N)
        {
        matrix[N][0] = matrix[N][1] = matrix[N][2] = 0.0;
        result[N] = 0.0;
        }

	matrix[0][1]=1;
	for(std::vector <CGPoint>::size_type i=1; i < n-1; i++)
		{
		matrix[i][0] = (double)(P[i].x-P[i-1].x)/6;
		matrix[i][1] = (double)(P[i+1].x-P[i-1].x)/3;
		matrix[i][2] = (double)(P[i+1].x-P[i].x)/6;
        //
		result[i] = (double)(P[i+1].y-P[i].y)/(P[i+1].x-P[i].x) - (double)(P[i].y-P[i-1].y)/(P[i].x-P[i-1].x);
		}
	matrix[n-1][1]=1;

	// solving pass1 (up->down)
	for(std::vector <CGPoint>::size_type i=1; i < n; i++)
		{
		const double k = matrix[i][0] / matrix[i-1][1];
		matrix[i][1] -= k * matrix[i-1][2];
		matrix[i][0] = 0;
        //
		result[i] -= k*result[i-1];
		}

	// solving pass2 (down->up)
	for(int i = (int)n-2; i >= 0; i--)
        {
		const double k = matrix[i][2]/matrix[i+1][1];
		matrix[i][1] -= k*matrix[i+1][0];
		matrix[i][2] = 0;
        //
		result[i] -= k*result[i+1];
        }

	// return second derivative value for each point P
	std::vector <double> y2(n);
	for(std::vector <CGPoint>::size_type i=0;i<n;i++)
		{
		y2[i] = result[i] / matrix[i][1];
		}
	return y2;
	}

const std::vector <CGPoint> curve(const std::vector <CGPoint> points)
	{
	std::vector <CGPoint> theOutputPoints;
	std::vector <double> sd = secondDerivative(points);

	for(std::vector <CGPoint>::size_type i = 0; i < points.size()-1; i++)
		{
		CGPoint cur   = points[i];
		CGPoint next  = points[i+1];

		for(int x=cur.x;x<next.x;x++)
			{
			const double t = (double)(x-cur.x)/(next.x-cur.x);
			const double a = 1 - t;
			const double b = t;
			const double h = next.x-cur.x;

			const double y = a * cur.y + b * next.y + (h * h/6) * ( (a * a * a - a) * sd[i]+ (b * b * b - b) * sd[i+1] );

			CGPoint p;
			p.x = x;
			p.y = y;

			theOutputPoints.push_back(p);
			}
		}

	return(theOutputPoints);
	}

extern "C" void EnumeratePointsInCurve(NSArray *inPoints, void (^inBlock)(CGPoint));

void EnumeratePointsInCurve(NSArray *inPoints, void (^inBlock)(CGPoint))
	{
	std::vector <CGPoint> thePoints;

	for (id obj in inPoints)
		{
		CGPoint thePoint = [obj CGPointValue];
		thePoints.push_back(thePoint);
		}

	thePoints = curve(thePoints);
	
	for (std::vector <CGPoint>::iterator it = thePoints.begin() ; it < thePoints.end(); it++ )
		{
		CGPoint thePoint = *it;
		inBlock(thePoint);
		}

	
	inBlock([[inPoints lastObject] CGPointValue]);
	}

extern "C" NSArray *PointsInCurve(NSArray *inPoints);

NSArray *PointsInCurve(NSArray *inPoints)
	{
	std::vector <CGPoint> thePoints;

	for (id obj in inPoints)
		{
		CGPoint thePoint = [obj CGPointValue];
		thePoints.push_back(thePoint);
		}

	std::vector <CGPoint> theOutputPoints = curve(thePoints);

	NSMutableArray *theResult = [NSMutableArray array];
	
	for (std::vector <CGPoint>::iterator it = theOutputPoints.begin() ; it < theOutputPoints.end(); it++ )
		{
		CGPoint thePoint = *it;
		[theResult addObject:[NSValue valueWithCGPoint:thePoint]];
		}

	[theResult addObject:[inPoints lastObject]];

	return(theResult);
	}

