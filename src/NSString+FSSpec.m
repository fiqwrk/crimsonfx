// -----------------------------------------------------------------------------------
// NSString+FSSpec.m
// ©2002 by Jeff LaMarche, all rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NSString+FSSpec.h"

@implementation NSString(FSSpec)
// Returns the FSSpec represented by a file located at the location stored in this string
-(FSSpec)fsSpec
{
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)self, kCFURLPOSIXPathStyle, false);
    FSRef ref;
    FSSpec spec;
    OSErr err = noErr;

    CFURLGetFSRef(url, &ref);
    err = FSGetCatalogInfo(&ref, kFSCatInfoNone, NULL, NULL, &spec, NULL);
    if(err != noErr)
        NSLog(@"error %d occured when getting the FSSpec", err);

    CFRelease(url);
    return spec;
}

@end
