// -----------------------------------------------------------------------------------
//  NKDMutableMovie.m
// -----------------------------------------------------------------------------------
//  Created on Tue Mar 05 2002 for project: Cheaposcope
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------

#import "NKDMutableMovie.h"
#import "NSString+FSSpec.h"


void CopyNSBitmapImageRepToGWorld(NSBitmapImageRep *bitmap, 
                                  GWorldPtr gWorldPtr)
{
    PixMapHandle pixMapHandle;
    Ptr pixBaseAddr, bitMapDataPtr;
    
    // Lock the pixels
    pixMapHandle = GetGWorldPixMap(gWorldPtr);
    LockPixels (pixMapHandle);
    pixBaseAddr = GetPixBaseAddr(pixMapHandle);
    
    bitMapDataPtr = [bitmap bitmapData];
    
    if ((bitMapDataPtr != nil) && (pixBaseAddr != nil))
    {
        int i;
        int pixmapRowBytes = GetPixRowBytes(pixMapHandle);
        NSSize imageSize = [bitmap size];
        for (i=0; i< imageSize.height; i++)
        {
            int j;
            unsigned char *src = bitMapDataPtr + i * [bitmap bytesPerRow];
            unsigned char *dst = pixBaseAddr + i * pixmapRowBytes;
            for ( j=0; j<imageSize.width; ++j )
            {
                *dst++ = 0;
                *dst++ = *src++;
                *dst++ = *src++;
                *dst++ = *src++;
            }
        }
    }
    
    UnlockPixels(pixMapHandle);
}


@implementation NKDMutableMovie
// -----------------------------------------------------------------------------------
+ (NSArray *)movieUnfilteredFileTypes
// -----------------------------------------------------------------------------------
{
    return [[NSArray alloc] initWithObjects:@"mov", @"MOV", @"'MooV'",@"dv", @"'dvc!'", /*@"mpg",@"avi", @"mpeg", @"mp4",*/ nil];
}
// -----------------------------------------------------------------------------------
-(NSMovie *)initWithPath: (NSString *)inPath
// -----------------------------------------------------------------------------------
{
    OSErr		err;
    FSSpec		mySpec;
    Movie 		theMovie = nil;

    err = EnterMovies();
    DealWithQTError();

    // As per several members of the Quicktime-api mailing list, FSGetCatalogInfo
    // barfs on FSRefs that don't point to a file, so we have to write an empty
    // string to this file to make sure it exists.
	if (inPath == nil)
		inPath = @"\tmp\previewrender.mov";
    [@"" writeToFile:inPath atomically:NO];
    mySpec = [inPath fsSpec];

    err = CreateMovieFile(&mySpec, 0, smCurrentScript,
                          createMovieFileDeleteCurFile | createMovieFileDontCreateResFile,
                          &movieRefNum, &theMovie);
    DealWithQTError();
    
    return [super initWithMovie:theMovie];

}
// -----------------------------------------------------------------------------------
-(Track)addVideoTrackOfHeight:(int)inHeight andWidth:(int)inWidth
// -----------------------------------------------------------------------------------
{
    Track	theTrack;
    Media	theMedia;
    OSErr	err;
    short	resID = movieInDataForkResID;

    theTrack = NewMovieTrack([self QTMovie], FixRatio(inWidth, 1), FixRatio(inHeight, 1), kNoVolume);
    err = GetMoviesError();
    NSLog(@"err: %s", err);
    DealWithQTError();

    theMedia = NewTrackMedia(theTrack, VideoMediaType, 600, nil, 0);
    err = GetMoviesError();
    DealWithQTError();

    err = InsertMediaIntoTrack(theTrack, 0, 0, 1, 0x00010000);
    DealWithQTError();

    err = AddMovieResource([self QTMovie], movieRefNum, &resID, nil);
    DealWithQTError();

    return theTrack;
}

// -----------------------------------------------------------------------------------
-(Track)getFirstVideoTrack
// -----------------------------------------------------------------------------------
{
    Track 	videoTrack = nil;
    long 	trackCount, count;
    OSType 	mediaType, manuf;
    Str255 	creator;

    trackCount = GetMovieTrackCount((Movie)[self QTMovie]);


    for (count = 1; count <= trackCount; count++)
    {
        videoTrack = GetMovieIndTrack((Movie)[self QTMovie], count);

        GetMediaHandlerDescription(GetTrackMedia(videoTrack), &mediaType, creator, &manuf);

        if (mediaType == 'vide')
            break;
        else
            videoTrack = nil;
    }
    return videoTrack;
}
// -----------------------------------------------------------------------------------
-(void)insertFrameFromImage:(NSImage *)image
		   usingFPS:(int)desiredFPS
// -----------------------------------------------------------------------------------
{   
    Rect			movieRect = {0,0,0,0};
    NSImageRep			*rep;
    OSErr			err;
    Media			theMedia;
    Track			theTrack;
    
    
    GWorldPtr 			theGWorld = nil;
    long 			maxCompressedSize;
    Handle 			compressedData = nil;
    Ptr 			compressedDataPtr;
    ImageDescriptionHandle 	imageDesc = nil;
    CGrafPtr 			oldPort;
    GDHandle 			oldGDeviceH;
    int				row,col;
    
    PixMapHandle 		pixMapHandle;
    Ptr 			pixBaseAddr;
    int 			pixmapRowBytes=0;
    TimeValue		 	sampleDuration = 1;
    short			resID = movieInDataForkResID;
    
    static int lastWidth;
    static int lastHeight;
    
    NSArray *array = [image representations];
    int count = [array count];
    NSBitmapImageRep *imageRep = nil;
    int i;
    
    for (i = 0; i < count; i++)
    {
	NSImageRep *tempImage = [array objectAtIndex:i];
	if ([tempImage isMemberOfClass: [NSBitmapImageRep class]])
	{
	    imageRep = (NSBitmapImageRep*)tempImage;
	    [imageRep retain];
	    break;
	}
    }
    if (imageRep == nil)
	imageRep = [[NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]] retain];
    
    rep = [[[self getCurrentFrame] representations] objectAtIndex:0];
    
    if ([rep pixelsHigh] > 0)
	lastHeight = [rep pixelsHigh];
    if ([rep pixelsWide] > 0)
	lastWidth = [rep pixelsWide];
    
    movieRect.bottom = [rep pixelsHigh];
    movieRect.right = [rep pixelsWide];
    
    if (movieRect.bottom <= 0)
	movieRect.bottom = lastHeight;
    if (movieRect.right <= 0)
	movieRect.right = lastWidth;
    
    err = NewGWorld(&theGWorld, 32, &movieRect, nil, nil, (GWorldFlags)0);
    
    DealWithQTErrorNoReturnObject();
    
    CopyNSBitmapImageRepToGWorld(imageRep, theGWorld);
    
    theTrack = [self getFirstVideoTrack];
    theMedia = GetTrackMedia(theTrack);
    
    err = BeginMediaEdits(theMedia);
    DealWithQTErrorNoReturnObject();
    
    LockPixels(GetGWorldPixMap(theGWorld));
    
    err = GetMaxCompressionSize(GetGWorldPixMap(theGWorld), &movieRect, 32, codecLosslessQuality,
                                kRawCodecType, (CompressorComponent)anyCodec,  &maxCompressedSize);
    
    DealWithQTErrorNoReturnObject();
    
    compressedData = NewHandle(maxCompressedSize);
    MoveHHi(compressedData );
    HLock(compressedData );
    compressedDataPtr = *compressedData;
    imageDesc = (ImageDescriptionHandle)NewHandle(4);
    GetGWorld(&oldPort, &oldGDeviceH);
    SetGWorld(theGWorld, nil);
    
    pixMapHandle = GetGWorldPixMap(theGWorld);
    
    err = CompressImage(GetGWorldPixMap(theGWorld), &movieRect, codecLosslessQuality,
                        kRawCodecType, imageDesc,  compressedDataPtr);
    DealWithQTErrorNoReturnObject();
    
    
    err = AddMediaSample(theMedia, compressedData, 0, (**imageDesc).dataSize,
                         (long)(600/desiredFPS), (SampleDescriptionHandle)imageDesc, 1, 0, &sampleDuration);
    
    DealWithQTErrorNoReturnObject();
    
    err = (InsertMediaIntoTrack(theTrack, GetTrackDuration(theTrack), sampleDuration,
                                (long)(600/desiredFPS), 0x00010000))
        DealWithQTErrorNoReturnObject();
    
    UnlockPixels (GetGWorldPixMap(theGWorld));
    SetGWorld (oldPort, oldGDeviceH);
    if (imageDesc)
        DisposeHandle((Handle)imageDesc);
    
    if (compressedData)
        DisposeHandle(compressedData);
    
    if (theGWorld)
        DisposeGWorld (theGWorld);
    
    err = EndMediaEdits(theMedia);
    DealWithQTErrorNoReturnObject();
    
    [self updateMovieFile];
    
    [imageRep release];

    
}
// -----------------------------------------------------------------------------------
-(void)updateMovieFile
// -----------------------------------------------------------------------------------
{
    OSErr			err;
    short			resID = movieInDataForkResID;
    
    err = UpdateMovieResource([self QTMovie], movieRefNum, resID, nil);
    DealWithQTErrorNoReturnObject();
}
// -----------------------------------------------------------------------------------
-(void)insertFrameFromFilmstripData:(NSData *)inFilmStrip 
			   usingFPS:(int)desiredFPS
// -----------------------------------------------------------------------------------
{
    Rect			movieRect = {0,0,0,0};
    NSImageRep			*rep;
    OSErr			err;
    Media			theMedia;
    Track			theTrack;
    
    
    GWorldPtr 			theGWorld = nil;
    long 			maxCompressedSize;
    Handle 			compressedData = nil;
    Ptr 			compressedDataPtr;
    ImageDescriptionHandle 	imageDesc = nil;
    CGrafPtr 			oldPort;
    GDHandle 			oldGDeviceH;
    int				row,col;
    
    PixMapHandle 		pixMapHandle;
    Ptr 			pixBaseAddr;
    unsigned char *		frameData;
    int 			pixmapRowBytes=0;
    TimeValue		 	sampleDuration = 1;
    short			resID = movieInDataForkResID;
    
    static int lastWidth;
    static int lastHeight;
    
    rep = [[[self getCurrentFrame] representations] objectAtIndex:0];
    
    if ([rep pixelsHigh] > 0)
	lastHeight = [rep pixelsHigh];
    if ([rep pixelsWide] > 0)
	lastWidth = [rep pixelsWide];
    
    movieRect.bottom = [rep pixelsHigh];
    movieRect.right = [rep pixelsWide];
    
    if (movieRect.bottom <= 0)
	movieRect.bottom = lastHeight;
    if (movieRect.right <= 0)
	movieRect.right = lastWidth;
    
    err = NewGWorld(&theGWorld, 32, &movieRect, nil, nil, (GWorldFlags)0);
    
    DealWithQTErrorNoReturnObject();
    
    theTrack = [self getFirstVideoTrack];
    theMedia = GetTrackMedia(theTrack);
    
    err = BeginMediaEdits(theMedia);
    DealWithQTErrorNoReturnObject();
    
    LockPixels(GetGWorldPixMap(theGWorld));
    
    err = GetMaxCompressionSize(GetGWorldPixMap(theGWorld), &movieRect, 32, codecLosslessQuality,
                                kRawCodecType, (CompressorComponent)anyCodec,  &maxCompressedSize);
    
    DealWithQTErrorNoReturnObject();
    
    compressedData = NewHandle(maxCompressedSize);
    MoveHHi(compressedData );
    HLock(compressedData );
    compressedDataPtr = *compressedData;
    imageDesc = (ImageDescriptionHandle)NewHandle(4);
    GetGWorld(&oldPort, &oldGDeviceH);
    SetGWorld(theGWorld, nil);
    
    pixMapHandle = GetGWorldPixMap(theGWorld);
    LockPixels(pixMapHandle);
    pixBaseAddr = GetPixBaseAddr(pixMapHandle);
    pixmapRowBytes = GetPixRowBytes(pixMapHandle);
    
    frameData = [inFilmStrip bytes];
    
    // We need to copy the read data into the GWorld, but
    // GWorld uses a pixel order of ARGB, while the
    // filmstrip uses RGBA, so we need to tweak the byte order
    for (row=0; row< movieRect.bottom; row++)
    {
        unsigned char *src = frameData + row * (movieRect.right * 4);
        unsigned char *dst = pixBaseAddr + row * pixmapRowBytes;
        for (col = 0; col < movieRect.right; col++)
        {
            *dst++ = *(src+3);
            *dst++ = *src;
            *dst++ = *(src+1);
            *dst++ = *(src+2);
            src+=4;
        }
    }
    
    UnlockPixels(pixMapHandle);
    err = CompressImage(GetGWorldPixMap(theGWorld), &movieRect, codecLosslessQuality,
                        kRawCodecType, imageDesc,  compressedDataPtr);
    DealWithQTErrorNoReturnObject();
    
    
    err = AddMediaSample(theMedia, compressedData, 0, (**imageDesc).dataSize,
                         (long)(600/desiredFPS), (SampleDescriptionHandle)imageDesc, 1, 0, &sampleDuration);
    
    DealWithQTErrorNoReturnObject();
    
    err = (InsertMediaIntoTrack(theTrack, GetTrackDuration(theTrack), sampleDuration,
                                (long)(600/desiredFPS), 0x00010000))
        DealWithQTErrorNoReturnObject();
    
    UnlockPixels (GetGWorldPixMap(theGWorld));
    SetGWorld (oldPort, oldGDeviceH);
    if (imageDesc)
        DisposeHandle((Handle)imageDesc);
    
    if (compressedData)
        DisposeHandle(compressedData);
    
    if (theGWorld)
        DisposeGWorld (theGWorld);
    
    err = EndMediaEdits(theMedia);
    DealWithQTErrorNoReturnObject();
    
    [self updateMovieFile];
    
}
// -----------------------------------------------------------------------------------
// Returns an NSImage that contains the picture data of the current frame.
// -----------------------------------------------------------------------------------
-(NSImage *)getCurrentFrame
// -----------------------------------------------------------------------------------
{
    Movie	movie = [self QTMovie];
    PicHandle	pic;

    
    pic = GetMoviePict(movie, GetMovieTime(movie, nil));
    NSImage *ret = [[NSImage alloc] initWithData:[NSData dataWithBytes: *pic length:GetHandleSize((Handle)pic)]];
    KillPicture(pic);
    return [ret autorelease];
    
}
// -----------------------------------------------------------------------------------
-(BOOL)stepForward
// -----------------------------------------------------------------------------------
{
    TimeValue 	interestingTime;
    Track 	videoTrack;
    short	myFlags;
    OSType      myTypes[1];
    OSErr	err = noErr;
    TimeValue    myCurrTime;
    TimeValue    myNextTime;
    
    
    myTypes[0] = VisualMediaCharacteristic;
    myFlags = nextTimeStep; 
    
    myCurrTime = GetMovieTime([self QTMovie], NULL);
    
    
    GetMovieNextInterestingTime([self QTMovie], myFlags, 1, myTypes, myCurrTime, fixed1, &myNextTime, NULL);
    err = GetMoviesError();
    
    DealWithQTErrorBool();
    
    if ((myNextTime < 0) || (myNextTime > GetMovieDuration([self QTMovie])))
	return NO;
    
    SetMovieTimeValue([self QTMovie], myNextTime);
    err = GetMoviesError();
    DealWithQTErrorBool();
    
    UpdateMovie([self QTMovie]);
    err = GetMoviesError();
    DealWithQTErrorBool();
    
    MoviesTask([self QTMovie], 0L);
    err = GetMoviesError();
    DealWithQTErrorBool();
    
    return YES;
}
// -----------------------------------------------------------------------------------
-(void)goToBeginning
// -----------------------------------------------------------------------------------
{
    GoToBeginningOfMovie((Movie)[self QTMovie]);
    /*
     short      myFlags;
     OSType      myTypes[1];
     
     *theTime = kBogusStartingTime;              // a bogus starting time
     if (theMovie == NULL)
     return(invalidMovie);
     
     myFlags = nextTimeMediaSample + nextTimeEdgeOK;      // we want the first sample in the movie
     myTypes[0] = VisualMediaCharacteristic;          // we want video samples
     
     GetMovieNextInterestingTime(theMovie, myFlags, 1, myTypes, (TimeValue)0, fixed1, theTime, NULL);
     */
}
// -----------------------------------------------------------------------------------
-(void)goToEnd
// -----------------------------------------------------------------------------------
{
    GoToEndOfMovie((Movie)[self QTMovie]);
}
// -----------------------------------------------------------------------------------
-(void)goToFrameIndex:(int)index
// -----------------------------------------------------------------------------------
{
    int i;
    
    if (index >= 0 && index < [self numberOfFrames])
    {
	[self goToBeginning];
	for (i=0; i < index; i++)
	    [self stepForward];
    }
}
// -----------------------------------------------------------------------------------
-(long)numberOfFrames
// -----------------------------------------------------------------------------------
{
    //return GetMediaSampleCount(GetTrackMedia(GetMovieIndTrack([self QTMovie], 1)));

    //v3.0
    //NSLog(@"Media Sample Count: %i", GetMediaSampleCount(GetTrackMedia(GetMovieIndTrack([self QTMovie], 1))));
    /*
    long 	numFrames = 0;
    short 	flags = nextTimeMediaSample + nextTimeEdgeOK;
    TimeValue	aDuration = 0;
    TimeValue	theTime = 0;
    OSType	theMediaType = VideoMediaType;
    
    GetMovieNextInterestingTime([self QTMovie], flags, 1, &theMediaType, theTime, 0, &theTime, &aDuration);
    if(theTime == -1) return numFrames;
    
    flags = nextTimeMediaSample; // Don't include the  nudge after the first interesting time.
    
    while(theTime != -1)  // When the returned time equals -1, then there were no more interesting times.
    {
	numFrames++;
	GetMovieNextInterestingTime([self QTMovie], flags, 1, &theMediaType, theTime, 0, &theTime, &aDuration);
    }
    
    return numFrames;
     */
    
    
    
    //v2.0
    /*
    long        frameCount = 0;
    TimeValue   curMovieTime, current;
    
    current = [self currentTime];
    
    Movie theMovie = [self QTMovie];
    if (theMovie == NULL)
        return -1;
    
    // due to a bug in QuickTime 6 we
    // must task the movie first
    MoviesTask( theMovie, 0 );
    
    curMovieTime = 0;
    while( curMovieTime >= 0 ) 
    {
        GetMovieNextInterestingTime( 
				     theMovie, 
				     nextTimeStep,
				     0, NULL,
				     curMovieTime,
				     fixed1,
				     &curMovieTime,
				     NULL );
        frameCount++;
    }
    
    frameCount--; // there's an extra time step at the end of the movie

    [self setCurrentTime:current];
    return frameCount;
     */
    
    //v1.0
    
    TimeValue	current;
    int		count = 1;

    // Store the current so we can restore it
    current = [self currentTime];
    [self goToBeginning];
    while ( [self stepForward])
        count ++;

    [self setCurrentTime:current];
    return count;
     
}
// -----------------------------------------------------------------------------------
-(TimeValue)currentTime
// -----------------------------------------------------------------------------------
{
    return GetMovieTime((Movie)[self QTMovie], nil);
}
// -----------------------------------------------------------------------------------
-(void)setCurrentTime:(TimeValue)newTime
// -----------------------------------------------------------------------------------
{
    SetMovieTimeValue((Movie)[self QTMovie], newTime);
}
// -----------------------------------------------------------------------------------
- (NSSize)size
// -----------------------------------------------------------------------------------
{
    Movie movie;
    Rect movieRect;
    
    movie = [self QTMovie];
    GetMovieNaturalBoundsRect(movie, &movieRect);
    
    return NSMakeSize(movieRect.right - movieRect.left, movieRect.bottom - movieRect.top);
}
// -----------------------------------------------------------------------------------
-(int)desiredFPS
// -----------------------------------------------------------------------------------
{
    /*
    long 	len,scale;
    Track 	videoTrack = nil;
    long 	trackCount, count;
    Str255 	creator;
    OSType 	mediaType, manuf;

    trackCount = GetMovieTrackCount((Movie)[self QTMovie]);

    for (count = 1; count <= trackCount; count++)
    {
        videoTrack = GetMovieIndTrack((Movie)[self QTMovie], count);

        GetMediaHandlerDescription(GetTrackMedia(videoTrack), &mediaType, creator, &manuf);

        if (mediaType == 'vide')
            break;
        else
            videoTrack = nil;
    }
    if (!videoTrack)
        return -1;

    len = GetTrackDuration(videoTrack);
    scale = GetMediaTimeScale(GetTrackMedia(videoTrack));
    
    return (int) ([self numberOfFrames] / (float)((float)len/(float)scale));
     */
    MediaHandler mpegMediaHandler = nil;
    Track        theTrack = nil;
    Media        myMedia = nil;
    OSErr        err = noErr;
    Boolean      isMpeg = false;
    
    short	fps = 0;
    
    theTrack = GetMovieIndTrackType([self QTMovie],
                                    1,
                                    kCharacteristicHasVideoFrameRate,
                                    movieTrackCharacteristic);
    err = GetMoviesError();
    DealWithQTError();
    
    myMedia = GetTrackMedia(theTrack);
    err = GetMoviesError();
    DealWithQTError();
    
    mpegMediaHandler = GetMediaHandler(myMedia);
    err = GetMoviesError();
    DealWithQTError();
    
    err = MediaHasCharacteristic(mpegMediaHandler,
                                 kCharacteristicIsAnMpegTrack,
                                 &isMpeg);
    if ((err == noErr) && isMpeg)
    {
        MHInfoEncodedFrameRateRecord encodedFrameRate;
        Size encodedFrameRateSize = sizeof(encodedFrameRate);
	
	/* due to a bug in QuickTime, we must task the movie
	    first before obtaining our frame rate value */
        MoviesTask([self QTMovie], 0 );
        
        err = MediaGetPublicInfo(mpegMediaHandler,
                                 kMHInfoEncodedFrameRate,
                                 &encodedFrameRate,
                                 &encodedFrameRateSize);
        if (err == noErr)
        {                
            Fixed staticFrameRate = 0;
	    
            staticFrameRate = encodedFrameRate.encodedFrameRate;
            fps = FixRound(staticFrameRate);
        }
    }
    else /* were dealing with non-MPEG media, so use the "old" method */
    {
        long sampleCount = 0;
        
        sampleCount = GetMediaSampleCount(myMedia);
        err = GetMoviesError();
        DealWithQTError();
        
        if (sampleCount)
        {
            TimeValue duration;
            TimeValue timeScale;
            Fixed staticFrameRate = 0;
            double frameRate;
            
	    /* find the media duration */
            duration = GetMediaDuration(myMedia);
            err = GetMoviesError();
            DealWithQTError();
            
	    /* get the media time scale */
            timeScale = GetMediaTimeScale(myMedia);
            err = GetMoviesError();
            DealWithQTError();
            
	    /* calculate the frame rate:
		frame rate = (sample count * media time scale) / media duration 
		*/
            frameRate = sampleCount*(double)timeScale/(double)duration;
            staticFrameRate = X2Fix(frameRate);
	    /* we'll round this value for simplicity - you could
		parse the value to also obtain the fractional
		portion as well. */
            fps = FixRound(staticFrameRate);
        }
    }
    return fps;
}
// -----------------------------------------------------------------------------------
-(Track)getFirstAudioTrack
// -----------------------------------------------------------------------------------
{
    return [self getAudioTrackAtIndex:1];
}
// -----------------------------------------------------------------------------------
-(Track)getAudioTrackAtIndex:(int)index
// -----------------------------------------------------------------------------------
{
    return GetMovieIndTrackType ([self QTMovie], index, AudioMediaCharacteristic, movieTrackCharacteristic);
    return GetMovieIndTrack([self QTMovie], index);
}
// -----------------------------------------------------------------------------------
-(void)addAudioTrack:(Track)track
// -----------------------------------------------------------------------------------
{
    Track newTrack = NewMovieTrack([self QTMovie], 0, 0, GetTrackVolume(track));
    Media media = NewTrackMedia(newTrack, SoundMediaType, GetMediaTimeScale(GetTrackMedia(track)), NULL, (OSType)0);
    BeginMediaEdits(media);
    InsertTrackSegment(track, newTrack, GetTrackOffset(track), GetTrackDuration(track), 0);
    EndMediaEdits(media);
    CopyTrackSettings(track, newTrack);
    [self updateMovieFile];
}
// -----------------------------------------------------------------------------------
-(void)dealloc
// -----------------------------------------------------------------------------------
{
    if (movieRefNum)
        CloseMovieFile(movieRefNum);

    [super dealloc];

}
@end
