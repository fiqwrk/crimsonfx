// -----------------------------------------------------------------------------------
//  NSColor-interpolate.h part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/31/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import <Cocoa/Cocoa.h>

@interface NSColor(interpolate) 
+(NSColor *) colorByInterpolatingColor: (NSColor *)color1
			     withColor: (NSColor *)color2
		       basedOnProgress: (int)progress
		    outOfPossibleSteps: (int)steps;
@end
