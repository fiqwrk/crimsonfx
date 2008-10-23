// -----------------------------------------------------------------------------------
//  NKDCrimsonAppDelegate.m
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#include "NKDCrimsonAppDelegate.h"

@implementation NKDCrimsonAppDelegate
// -----------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
// -----------------------------------------------------------------------------------
{
//    NSDate *now = [NSDate date];
//    NSDate *exp = [NSDate dateWithNaturalLanguageString:@"04/16/2005"];
//    
//    if ([now compare:exp] == NSOrderedDescending)
//    {
//	NSRunAlertPanel(@"Expired!",@"I'm sorry, this beta version of Crimson FX has expired",@"Okay",nil,nil);
//	[NSApp terminate:nil];
//    }
}
// -----------------------------------------------------------------------------------
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
// -----------------------------------------------------------------------------------
{
    return NO;
}
// -----------------------------------------------------------------------------------
- (void)applicationWillTerminate:(NSNotification *)aNotification
// -----------------------------------------------------------------------------------
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *tmpFiles = [fm directoryContentsAtPath:@"/tmp/"];
    NSEnumerator *e = [tmpFiles objectEnumerator];
    
    NSString * object;

    while (object = [e nextObject]) 
    {
	if ([object length] > 13)
	{
	    if ([[object substringToIndex:13] isEqual:@"crimsonrender"])
		[fm removeFileAtPath:[NSString stringWithFormat:@"/tmp/%@", object] handler:nil];
	}
	
    }
}
@end
