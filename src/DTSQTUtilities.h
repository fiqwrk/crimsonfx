/*
	File:		DTSQTUtilities.h

	Contains:	QuickTime functions, header file definitions.

	Written by: 	

	Copyright:	Copyright � 1991-2001 by Apple Computer, Inc., All Rights Reserved.

	Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
				("Apple") in consideration of your agreement to the following terms, and your
				use, installation, modification or redistribution of this Apple software
				constitutes acceptance of these terms.  If you do not agree with these terms,
				please do not use, install, modify or redistribute this Apple software.

				In consideration of your agreement to abide by the following terms, and subject
				to these terms, Apple grants you a personal, non-exclusive license, under Apple�s
				copyrights in this original Apple software (the "Apple Software"), to use,
				reproduce, modify and redistribute the Apple Software, with or without
				modifications, in source and/or binary forms; provided that if you redistribute
				the Apple Software in its entirety and without modifications, you must retain
				this notice and the following text and disclaimers in all such redistributions of
				the Apple Software.  Neither the name, trademarks, service marks or logos of
				Apple Computer, Inc. may be used to endorse or promote products derived from the
				Apple Software without specific prior written permission from Apple.  Except as
				expressly stated in this notice, no other rights or licenses, express or implied,
				are granted by Apple herein, including but not limited to any patent rights that
				may be infringed by your derivative works or by other works in which the Apple
				Software may be incorporated.

				The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
				WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
				WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
				PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
				COMBINATION WITH YOUR PRODUCTS.

				IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
				CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
				GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
				ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
				OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
				(INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
				ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
                
	Change History (most recent first):
                                    11/7/2001	srk			Carbonized
				7/28/1999	Karl Groethe	Updated for Metrowerks Codewarror Pro 2.1
				

*/
// Define that this file should only be parsed once, most dev environments know of pragma once.
#pragma once


// INCLUDES

#import <Quicktime/Quicktime.h>
//#include <FixMath.h>

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif


// Window size constants.
enum eQTUWindowSize {
	kNormalMovieSize = 1L,
	kHalfMovieSize,
	kDoubleMovieSize
};


// Rate constant values, Fwd = forward, Bwd = backwards.
enum eQTUMovieRates {	kNoSpeed = 0x00000000,  kFwdSpeed = 0x00010000,
									    kFwdDoubleSpeed = 0x00020000, kFwdTripleSpeed = 0x00030000,	
									    kFwdQuadSpeed = 0x00040000, kFwdHalfSpeed = 0x00008000, 
									    kFwdQuarterSpeed = 0x00004000, kFwdEightspeed = 0x00002000, 
									    kBwdSpeed = 0xFFFF0000, kBwdDoubleSpeed = 0xFFFE0000, 
									    kBwdHalfSpeed = 0xFFFF8000 };


// Constants used for QTUPrintMoviePICT.
enum eQTUPICTPrinting { kPrintFrame = 1, kPrintPoster };


// MACROS
#if DEBUG
static char gDebugString[256];

#define DebugAssert(condition)																		\
	if (condition)		NULL;																			\
	else 																											\
	{																												\
		sprintf(gDebugString,"File: %s, Line: %d", __FILE__, __LINE__);			\
		DebugStr(c2pstr(gDebugString));															\
	}
#else
#define DebugAssert(condition)		NULL
#endif

#define MBSTARTTIMER() DebugStr("\pStart! `;mc starttime @ticks;g")
#define MBSTOPTIMER()	DebugStr("\pElapsed time in ticks: '; @ticks - starttime")


// ReturnIfError is a simple macro around the frequently written code line doing the same (see below)
#define ReturnIfError(theError)  DebugAssert(theError == noErr);  \
													if(theError != noErr) return theError


// FUNCTION PROTOTYPES



// MOVIE TOOLBOX FUNCTIONS
pascal Boolean 			QTUIsQuickTimeInstalled(void);																						// Check if QT is present.

#if TARGET_CPU_PPC
	pascal Boolean 			QTUIsQuickTimeCFMInstalled(void);																				// Check if QT CFM library is present.
#endif

pascal long 			QTUGetQTVersion(); // Get QT version number.
pascal Boolean 			QTUAreQuickTimeMusicInstrumentsPresent(void);	 // Test if Musical Instrumentscomponent is present.

pascal OSErr			QTUPrerollMovie(Movie theMovie); // Preroll Movies before Playback.

pascal Boolean 			QTUFileFilter(ParmBlkPtr theParamBlock);
pascal Movie 			QTUGetMovie(FSSpec *theFSSpec, short *theRefNum, short *theResID);						// Return a Movie from a file with the movie.
pascal OSErr 			QTUSimpleGetMovie(Movie *theMovie);																		// Simpler version of querying for a movie and return it.
pascal OSErr 			QTUSaveMovie(Movie theMovie);																					// Save the movie (standard dialog box).
pascal OSErr			QTUFlattenMovieFile(Movie theMovie, FSSpec *theFile);												// Takes a movie and a file and flattens the movie into the file.
pascal OSErr			QTUPrintMoviePICT(Movie theMovie, short x, short y, long PICTUsed);   						// Print the movie poster.
pascal OSErr			QTUCalculateMovieMemorySize(Movie theMovie, long *theSize);									// Return the size of the movie in memory.
pascal OSErr			QTULoadWholeMovieToRAM(Movie theMovie);																// Load the whole movie to RAM.
pascal OSErr			QTUPlayMovieSound(Movie theMovie);																			// Play the movie sound track using the snd resource.
pascal OSErr			QTUDrawVideoFrameAtTime(Movie theMovie, TimeValue atTime);									// Draw a movie frame at specified time.
pascal OSErr 			QTUScrollToNextVideoSample(Movie theMovie, TimeValue fromTimePoint, TimeValue toTimePoint);					// Do a visible scroll from one video frame to another.

pascal OSErr 			QTUGetStartPointOfFirstVideoSample(Movie theMovie,TimeValue *startPoint);				// Get time value of first sample in the movie.

// TRACK & MEDIA
pascal Boolean 			QTUMediaTypeInTrack(Movie theMovie, OSType theMediaType);									// Check if a Media type is present in a track of a movie.
pascal OSErr			QTUGetTrackRect(Track theTrack, Rect *theRect);														// Get the track rect of a possible video track
pascal short 			QTUGetVideoMediaPixelDepth(Media theMedia, short index);											// Get the pixel depth of a video media.
pascal long				QTUCountMediaSamples(Movie theMovie, OSType theMediaType);									// Count frames in a movie based on defined media.
pascal TimeValue  		QTUGetDurationOfFirstMovieSample(Movie theMovie, OSType theMediaType)	;				// Get duration of first sample in the track
pascal OSErr 			QTUCountMaxSoundRate(Movie theMovie,long *theMaxSoundRate);								// Return max sound rate from a sound track in a movie.
pascal long 				QTUGetMovieFrameCount(Movie theMovie, long theFrameRate);										// Return frames based on frame rate and movie.
pascal OSErr 			QTUCopySoundTracks(Movie theSrcMovie, Movie theDestMovie);									// Copy sound tracks from source movie to destination movie


// IMAGE COMPRESSION MANAGER
Boolean 				QTUHasCodecLossLessQuality(CodecType theCodec, short thePixelDepth);						// Test if a codec has lossless spatial compression.


// MOVIE CONTROLLER FUNCTIONS
pascal OSErr 			QTUPlayMovieWithMC(MovieController mc);																	// Play the movie using the movie controllers.
pascal OSErr  			QTUDoIgnoreMCDrags(MovieController  mc);																	// ignore Drag-and-Drop functionality.
pascal Boolean			QTUPointInMC(MovieController mc, WindowRef theWindow, Point where);					// Check if a point is inside the movie controller rect.
pascal OSErr 			QTUSelectAllMovie(MovieController mc);																		// Select the whole time frame from a movie with the mc.
pascal Boolean 			QTUResizeMCActionFilter(MovieController mc, short action, void *params, long refCon);
pascal OSErr 			QTUResizeMCWindow(MovieController mc, WindowPtr theWindow, long theMovieSize,  Rect originalSize);

pascal OSErr			QTUMCSetMovieRate(MovieController mc, long theRate);												// Set movie rate using movie controller.


// SEQUENCE GRABBER FUNCTIONS
pascal SeqGrabComponent QTUCreateSequenceGrabber(WindowPtr theWindow);												// Create a sequence grabber instance.
pascal OSErr 			QTUCreateSGGrabChannels(SeqGrabComponent s, const Rect *theBounds, 
											long theUsage, SGChannel *theVideoChannel, SGChannel *theSoundChannel); 		// Create sequence grabber channels.
pascal Boolean 			QTUDoesVDIGReceiveVideo(SeqGrabComponent s);													// Do we have live incoming video?
pascal OSErr 			QTUChangeSGWindowSize(SeqGrabComponent s,SGChannel videoChannel, 				// Change the window size of Sequence Grabber window
											WindowPtr theWindow, long width, long height);

// COMPONENT FUNCTIONS
pascal Component 		QTUDoGetComponent(OSType theComponentType, OSType theSpecificComponent);
pascal Boolean 			QTUHasComponentType(OSType theComponentType, OSType theSpecificComponent);


#ifdef __cplusplus
}
#endif