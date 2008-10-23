//
//  NSBezierPath-Saber.m
//  SaberTest2
//
//  Created by Jeff LaMarche on 12/6/04.
//  Copyright 2004 Naked Software.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NSBezierPath-Saber.h"
#define radians2degrees(a) a*(180/3.14159265)
#define degrees2radians(a) a*(3.14159265/180)

float distanceBetweenTwoPoints(NSPoint pt1, NSPoint pt2)
{
    //sqrt( ((x2-x1) * (x2-x1)) + ((y2-y1) * (y2-y1)) )
    return sqrt ( ((pt2.x - pt1.x) * (pt2.x - pt1.x)) + ((pt2.y - pt1.y) * (pt2.y - pt1.y)) );
}
// Returns degree, in angles, of a vector defined by two points
// Angle is assuming that 0° is a line from (0,0) to (-1,0)
float angleFromTwoPoints(NSPoint pt1, NSPoint pt2)
{
    float radians = atan( (pt1.y-pt2.y) / (pt1.x-pt2.x));
    float degrees = radians2degrees(radians);
    if ( (pt1.x-pt2.x) < 0)
	if (degrees < 180)
	    degrees += 180;
	else degrees -=180;
    return degrees;
}

@implementation NSBezierPath(saber)
// ----------------------------------------------------------------------------------------------
+ (NSBezierPath *)saberPathFromPoint:(NSPoint)start
			  startWidth:(float)startWidth
			     toPoint:(NSPoint)finish
			    endWidth:(float)endWidth
			  roundStart:(BOOL)roundStart
			 roundFinish:(BOOL)roundFinish
		      andEmitterBulb:(BOOL)bulb
// ----------------------------------------------------------------------------------------------
{
    float length = distanceBetweenTwoPoints(start, finish);
    float angle = angleFromTwoPoints(start, finish);
    
    // Now, we'll draw our rectangle at the origin into the negative Y space, then transform it to where it belongs
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0, startWidth/2)];
    [path lineToPoint:NSMakePoint(-length, endWidth/2)];
    
    if (roundFinish)
	[path curveToPoint:NSMakePoint(-length, -(endWidth/2)) controlPoint1:NSMakePoint(-(length + endWidth), endWidth/2) controlPoint2:NSMakePoint(-(length + endWidth), -(endWidth/2))];
    else
	[path lineToPoint:NSMakePoint(-length, -(endWidth/2))];
    
    [path lineToPoint:NSMakePoint(0, -(startWidth/2))];
    
    if (roundStart)
	[path curveToPoint:NSMakePoint(0, startWidth/2) controlPoint1:NSMakePoint(startWidth, -(startWidth/2)) controlPoint2:NSMakePoint(startWidth, startWidth/2)];
    else
	[path lineToPoint:NSMakePoint(0, startWidth/2)];
    
    if (bulb)
    {
	if (roundStart)
	    [path appendBezierPathWithOvalInRect:NSMakeRect(-startWidth, -startWidth*.75, startWidth*1.5, startWidth*1.5)];
	else
	    [path appendBezierPathWithOvalInRect:NSMakeRect(-startWidth*1.2, -startWidth*.75, startWidth*1.5, startWidth*1.5)];
    }
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:start.x yBy:start.y];
    [transform rotateByDegrees:angle];
    
    return [transform transformBezierPath:path];
}
@end
