// -----------------------------------------------------------------------------------
//  NKDMutableMovie.g
// -----------------------------------------------------------------------------------
//  Created on Tue Mar 05 2002 for project: Cheaposcope
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
// This functionality was originally implemented as a category on NSMovie, but I
// realized after the initial design that I needed to keep a reference to the
// movieRefNum for certain editing functions, so changed to a subclass.
// -----------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import <Quicktime/Quicktime.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#define	    DealWithQTError(); if (err){NSLog(@"Quicktime error. Error Code: %d", err);return nil;}
#define	    DealWithQTErrorBool(); if (err){NSLog(@"Quicktime error. Error Code: %d", err);return NO;}
#define	    DealWithQTErrorNoReturnObject(); if (err){NSLog(@"Quicktime error. Error Code: %d", err);return;}

#define     kCharacteristicHasVideoFrameRate    FOUR_CHAR_CODE('vfrr')
#define     kCharacteristicIsAnMpegTrack        FOUR_CHAR_CODE('mpeg')

@interface NKDMutableMovie : NSMovie
{	
    short	movieRefNum;
}
-(NSMovie *)initWithPath: (NSString *)inPath;
-(Track)addVideoTrackOfHeight:(int)inHeight andWidth:(int)inWidth;
-(Track)getFirstVideoTrack;
-(void)insertFrameFromImage:(NSImage *)image
		   usingFPS:(int)desiredFPS;
-(void)insertFrameFromFilmstripData:(NSData *)inFilmStrip
			   usingFPS:(int)desiredFPS;
-(NSImage *)getCurrentFrame;
-(void)goToBeginning;
-(void)goToEnd;
-(void)goToFrameIndex:(int)index;
-(BOOL)stepForward;
-(long)numberOfFrames;
-(TimeValue)currentTime;
-(void)setCurrentTime:(TimeValue)newTime;
-(int)desiredFPS;
-(NSSize)size;
-(void)updateMovieFile;
-(Track)getAudioTrackAtIndex:(int)index;
-(Track)getFirstAudioTrack;
-(void)addAudioTrack:(Track)track;
@end
