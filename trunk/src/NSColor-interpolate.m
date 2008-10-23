// -----------------------------------------------------------------------------------
//  NSColor-interpolate.m part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/31/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NSColor-interpolate.h"

@implementation NSColor(interpolate)
// -----------------------------------------------------------------------------------
+(NSColor *) colorByInterpolatingColor: (NSColor *)color1
			     withColor: (NSColor *)color2
		       basedOnProgress: (int)progress
		    outOfPossibleSteps: (int)steps
// -----------------------------------------------------------------------------------
{
    float red1 = [color1 redComponent];
    float green1 = [color1 greenComponent];
    float blue1 = [color1 blueComponent];
    float alpha1 = [color1 alphaComponent];
    
    float red2 = [color2 redComponent];
    float green2 = [color2 greenComponent];
    float blue2 = [color2 blueComponent];
    float alpha2 = [color2 alphaComponent];
    
    float newRed = red2 + ((float)progress / (float)steps) * (red1 - red2);
    float newGreen = green2 + ((float)progress / (float)steps) * (green1 - green2);
    float newBlue = blue2 + ((float)progress / (float)steps) * (blue1 - blue2);
    float newAlpha = alpha2 + ((float)progress / (float)steps) * (alpha1 - alpha2);
    
    return [NSColor colorWithCalibratedRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}
@end
