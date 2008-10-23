// -----------------------------------------------------------------------------------
//  NKDCrimsonDocument.m
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NKDCrimsonDocument.h"

enum { NUDGE_UP, NUDGE_RIGHT, NUDGE_DOWN, NUDGE_LEFT};

@implementation NKDCrimsonDocument
// -----------------------------------------------------------------------------------
- (id)init
// -----------------------------------------------------------------------------------
{
    self = [super init];
    if (self) 
    {
	[self setSettings:[NSMutableDictionary dictionary]];
	[self setShouldCancel:NO];
	//[self performSelector:@selector(selectMovie:) withObject:nil afterDelay:.5];
    }
    return self;
}
// -----------------------------------------------------------------------------------
- (void)awakeFromNib
// -----------------------------------------------------------------------------------
{
     NSConnection		*theConnection = [NSConnection defaultConnection];
    [theConnection setRootObject:self];
    if ([theConnection registerName:@"main"] == NO) 
    {	
        NSLog(@"Error vending main thread");
        // Handle error
    }
    //effectTypePopUp
    [effectTypePopUp removeAllItems];
    [effectTypePopUp addItemsWithTitles:[NKDLaserEffectSettings effectTypes]];
}
// -----------------------------------------------------------------------------------
- (NSString *)windowNibName
// -----------------------------------------------------------------------------------
{
    return @"NKDCrimsonDocument";
}
// -----------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)aNotification
// -----------------------------------------------------------------------------------
{
    if ([aNotification object] == [self window])
	[self close];
}

// -----------------------------------------------------------------------------------
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
// -----------------------------------------------------------------------------------
{
    [super windowControllerDidLoadNib:aController];
    [self performSelector:@selector(selectMovie:) withObject:nil afterDelay:.5];
}
// -----------------------------------------------------------------------------------
- (NSData *)dataRepresentationOfType:(NSString *)aType
// -----------------------------------------------------------------------------------
{
    // Insert code here to write your document from the given data.  You can also 
    // choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    return [NSArchiver archivedDataWithRootObject:self];
}
// -----------------------------------------------------------------------------------
- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
// -----------------------------------------------------------------------------------
{
    // This is a hack so that we can prevent it from loading a 
    // movie if one is selected. If a movie is selected, we want
    // to make a new doc using that as the source movie.

    if ([docType isEqual:@"Movie"])
    {
	[self setMoviePath:fileName];
	[self setFileType:@"Crimson Document"];
	[self setFileName:@"Untitled"];
	[self setLastComponentOfFileName:@"crimson"];
    }
    else
    {
	NKDCrimsonDocument *un = [NSUnarchiver unarchiveObjectWithFile:fileName];
	[self setMoviePath:[un moviePath]];
	[self setSettings:[un settings]];
	[self setCurrentFrame:[un currentFrame]];
    }
    //return [super readFromFile:fileName ofType:docType];
    return YES;
}
// -----------------------------------------------------------------------------------
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
// -----------------------------------------------------------------------------------
{ 
    self = [NSUnarchiver unarchiveObjectWithData:data];
    [self loadSourceMovie];
    return data != nil;
}
#pragma mark -
#pragma mark Accessors & Mutators
#pragma mark -
// -----------------------------------------------------------------------------------
- (NSWindow *)window
// -----------------------------------------------------------------------------------
{
    return [auraColorWell window];
}
// -----------------------------------------------------------------------------------
- (long)currentFrame
// -----------------------------------------------------------------------------------
{
    return currentFrame;
}
// -----------------------------------------------------------------------------------
- (void)setCurrentFrameFromObject:(NSNumber *)newFrame
// -----------------------------------------------------------------------------------
{
    [self setCurrentFrame:[newFrame longValue]];
}
// -----------------------------------------------------------------------------------
- (void)setCurrentFrame:(long)newCurrentFrame
// -----------------------------------------------------------------------------------
{
    currentFrame = newCurrentFrame;
    if (movie != nil)
    {
	[movie goToFrameIndex:currentFrame];
	[frameCountText setStringValue:[NSString stringWithFormat:@"frame %d of %d", [self currentFrame]+1, [movie numberOfFrames]]];
	[keyframeCheckbox setIntValue:[self isCurrentFrameKeyFrame]];
	[self updateKeyframeStatus];
	double cur = [self currentFrame];
	[frameSlider setDoubleValue:cur];
	[docView setNeedsDisplay:YES];
	[docView setRenderedImage:nil];
	[self setKeyframeValues:[self currentSettings]];
	
	
    }
}
// -----------------------------------------------------------------------------------
- (NKDMutableMovie *)movie
// -----------------------------------------------------------------------------------
{
    return movie;
}
// -----------------------------------------------------------------------------------
- (void)setMovie:(NKDMutableMovie *)newMovie
// -----------------------------------------------------------------------------------
{
    [newMovie retain];
    [movie release];
    movie = newMovie;
}
// -----------------------------------------------------------------------------------
- (NSMutableDictionary *)settings
// -----------------------------------------------------------------------------------
{
    if (settings == nil)
	settings = [NSMutableDictionary dictionary];
    return settings;
}
// -----------------------------------------------------------------------------------
- (void)setSettings:(NSMutableDictionary *)newSettings
// -----------------------------------------------------------------------------------
{
    [newSettings retain];
    [settings release];
    settings = newSettings;
}
// -----------------------------------------------------------------------------------
- (NKDLaserEffectSettings *)currentSettings
// -----------------------------------------------------------------------------------
{
    NKDLaserEffectSettings *ret = [settings objectForKey:[NSNumber numberWithLong:[self currentFrame]]];
    if (ret != nil)
	return ret;
    
    // No settings, so try and interpolate
    NSEnumerator *keys = [[[settings allKeys]sortedArrayUsingSelector:@selector(compare:)] objectEnumerator];
    NSNumber *theKey;
    NSNumber *afterKey = [self nextKeyframeNumber];
    NSNumber *beforeKey = [self previousKeyframeNumber];
    
    if (beforeKey == nil || afterKey == nil)
	return nil;
    
    // If we've gotten to here, there are two keys that we must interpolate between.
    NKDLaserEffectSettings *before = [settings objectForKey:beforeKey];
    NKDLaserEffectSettings *after = [settings objectForKey:afterKey];
    
    int steps = [afterKey longValue] - [beforeKey longValue];
    int progress = [self currentFrame] - [beforeKey longValue];
    
    NSColor *intAura = [NSColor colorByInterpolatingColor:[after aura] withColor:[before aura] basedOnProgress:progress outOfPossibleSteps:steps];
    NSColor *intCore = [NSColor colorByInterpolatingColor:[after core] withColor:[before core] basedOnProgress:progress outOfPossibleSteps:steps];
    
    NSPoint intStart = NSMakePoint([before start].x + ((float)progress / (float)steps) * ([after start].x - [before start].x),
				    [before start].y + ((float)progress / (float)steps) * ([after start].y - [before start].y));
    NSPoint intFinish = NSMakePoint([before finish].x + ((float)progress / (float)steps) * ([after finish].x - [before finish].x),
				     [before finish].y + ((float)progress / (float)steps) * ([after finish].y - [before finish].y));

    int intStartWidth = [before startWidth] + ((float)progress / (float)steps) * ([after startWidth] - [before startWidth]);
    int intFinishWidth = [before finishWidth] + ((float)progress / (float)steps) * ([after finishWidth] - [before finishWidth]);
    
    int intStartIsRounded = [before startIsRounded] + ((float)progress / (float)steps) * ([after startIsRounded] - [before startIsRounded]);
    int intFinishIsRounded = [before finishIsRounded] + ((float)progress / (float)steps) * ([after finishIsRounded] - [before finishIsRounded]);
    int intEmitterEffect = [before emitterBulbEffect] + ((float)progress / (float)steps) * ([after emitterBulbEffect] - [before emitterBulbEffect]);
    
    ret = [[[NKDLaserEffectSettings alloc] initWithStartPoint:intStart 
						  finishPoint:intFinish
						    coreColor:intCore 
						    auraColor:intAura 
						   startWidth:intStartWidth
						  finishWidth:intFinishWidth 
					       startIsRounded:intStartIsRounded >= .5
					      finishIsRounded:intFinishIsRounded >= .5
					    emitterBulbEffect:intEmitterEffect >= .5
						andEffectType:[before effectType]] autorelease];
    return ret;
    
}
// -----------------------------------------------------------------------------------
- (NSButton *)keyframeCheckbox
// -----------------------------------------------------------------------------------
{
    return keyframeCheckbox;
}
// -----------------------------------------------------------------------------------
- (NSString *)moviePath
// -----------------------------------------------------------------------------------
{
    return moviePath;
}
// -----------------------------------------------------------------------------------
- (void)setMoviePath:(NSString *)newMoviePath
// -----------------------------------------------------------------------------------
{
    [newMoviePath retain];
    [moviePath release];
    moviePath = newMoviePath;
}
// -----------------------------------------------------------------------------------
- (BOOL)shouldCancel
// -----------------------------------------------------------------------------------
{
    return shouldCancel;
}
// -----------------------------------------------------------------------------------
- (void)setShouldCancel:(BOOL)newShouldCancel
// -----------------------------------------------------------------------------------
{
    shouldCancel = newShouldCancel;
}
// -----------------------------------------------------------------------------------
- (NKDCrimsonMovieFrameView *)docView
// -----------------------------------------------------------------------------------
{
    return docView;
}
// -----------------------------------------------------------------------------------
- (void)setDocView:(NKDCrimsonMovieFrameView *)newDocView
// -----------------------------------------------------------------------------------
{
    [newDocView retain];
    [docView release];
    docView = newDocView;
}


#pragma mark -
#pragma mark Virtual Accessors & Mutators
#pragma mark -
// -----------------------------------------------------------------------------------
- (BOOL)isCurrentFrameKeyFrame
// -----------------------------------------------------------------------------------
{
    return [settings objectForKey:[NSNumber numberWithInt:[self currentFrame]]] != nil;
}
// -----------------------------------------------------------------------------------
- (NSImage *)currentFrameImage
// -----------------------------------------------------------------------------------
{
    [movie goToFrameIndex:currentFrame];
    return [movie getCurrentFrame];
}
#pragma mark -
#pragma mark IB Actions
#pragma mark -
// -----------------------------------------------------------------------------------
- (IBAction)toggleKeyFrameStatus:(id)sender
// -----------------------------------------------------------------------------------
{
    // First, deal with controls
    [self updateKeyframeStatus];
    [[self window] setDocumentEdited:YES];
    
    NSNumber *start = [NSNumber numberWithLong:[self currentFrame]];
    
    // We're making it a keyframe
    if ([keyframeCheckbox intValue] == 1)
    {
	NKDLaserEffectSettings *newSet = [[self currentSettings] retain];
	if (newSet == nil)
	{
	    NSNumber *before = [self previousKeyframeNumber];
	    NSNumber *after = [self nextKeyframeNumber];
	    
	    if (before == nil && after == nil)
		newSet = [[NKDLaserEffectSettings alloc] initWithStartPoint:NSMakePoint(50, 50)
								finishPoint:NSMakePoint(100, 100) 
								  coreColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]
								  auraColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0] 
								 startWidth:10 
								finishWidth:10 
							     startIsRounded:YES 
							    finishIsRounded:YES
						       andEmitterBulbEffect:NO];
	    else
	    {
		newSet = (before == nil) ? [[settings objectForKey:after] copy] : [[settings objectForKey:before] copy]; 
		[newSet retain];
	    }
	}
	[settings setObject:newSet forKey:start];
	[self setKeyframeValues:newSet];
	[newSet release];
	
    }
    // We're removing a keyframe
    else
    {
	NKDLaserEffectSettings *delSet = [[settings objectForKey:start] retain];
	[settings removeObjectForKey:start];
	[delSet release];
    }
}
// -----------------------------------------------------------------------------------
- (IBAction)nudgeStart:(id)sender
// -----------------------------------------------------------------------------------
{
    [[self window] setDocumentEdited:YES];
    NSButton *senderButton = sender;
    
    NSNumber *frameNum = [NSNumber numberWithLong:[self currentFrame]];
    NKDLaserEffectSettings *curSet = [settings objectForKey:frameNum];
    
    if ([curSet start].x < 0 && [curSet start].y < 0)
	return;
    
    switch ([senderButton tag])
    {
	case NUDGE_UP:
	    [curSet setStart:NSMakePoint([curSet start].x, [curSet start].y+1)];
	    break;
	case NUDGE_RIGHT:
	    [curSet setStart:NSMakePoint([curSet start].x+1, [curSet start].y)];
	    break;
	case NUDGE_DOWN: 
	    [curSet setStart:NSMakePoint([curSet start].x, [curSet start].y-1)];
	    break;
	case NUDGE_LEFT:
	    [curSet setStart:NSMakePoint([curSet start].x-1, [curSet start].y)];
	    break;
    }
    [docView setNeedsDisplay:YES];
    
}
// -----------------------------------------------------------------------------------
- (IBAction)nudgeFinish:(id)sender
// -----------------------------------------------------------------------------------
{
    [[self window] setDocumentEdited:YES];
    NSButton *senderButton = sender;
    
    NSNumber *frameNum = [NSNumber numberWithLong:[self currentFrame]];
    NKDLaserEffectSettings *curSet = [settings objectForKey:frameNum];
    
    if ([curSet finish].x < 0 && [curSet finish].y < 0)
	return;
    
    switch ([senderButton tag])
    {
	case NUDGE_UP:
	    [curSet setFinish:NSMakePoint([curSet finish].x, [curSet finish].y+1)];
	    break;
	case NUDGE_RIGHT:
	    [curSet setFinish:NSMakePoint([curSet finish].x+1, [curSet finish].y)];
	    break;
	case NUDGE_DOWN: 
	    [curSet setFinish:NSMakePoint([curSet finish].x, [curSet finish].y-1)];
	    break;
	case NUDGE_LEFT:
	    [curSet setFinish:NSMakePoint([curSet finish].x-1, [curSet finish].y)];
	    break;
    }
    [docView setNeedsDisplay:YES];
    [docView setRenderedImage:nil];
    
}
// -----------------------------------------------------------------------------------
- (IBAction)stepForward:(id)sender
// -----------------------------------------------------------------------------------
{
    if (currentFrame != [movie numberOfFrames]-1)
    {
	[self setCurrentFrame:[self currentFrame]+1];
	//currentFrame++;
	//[movie stepForward];
    }
}
// -----------------------------------------------------------------------------------
- (IBAction)stepBack:(id)sender
// -----------------------------------------------------------------------------------
{
    long cur = [self currentFrame];
    if (cur != 0)
	[self setCurrentFrame:cur-1];
}
// -----------------------------------------------------------------------------------
- (IBAction)changeFrameBasedOnSlider:(id)sender
// -----------------------------------------------------------------------------------
{
    NSNumber *num = [NSNumber numberWithDouble:[frameSlider doubleValue]];
    [self setCurrentFrame:[num longValue]];
}
// -----------------------------------------------------------------------------------
- (IBAction)stepToEnd:(id)sender
// -----------------------------------------------------------------------------------
{
    [self setCurrentFrame:[movie numberOfFrames]-1];
}
// -----------------------------------------------------------------------------------
- (IBAction)stepToBeginning:(id)sender
// -----------------------------------------------------------------------------------
{
    [self setCurrentFrame:0];
}
// -----------------------------------------------------------------------------------
- (IBAction)nextKeyframe:(id)sender
// -----------------------------------------------------------------------------------
{
    NSNumber *nxt = [self nextKeyframeNumber];
    if (nxt != nil)
	[self setCurrentFrame:[nxt intValue]];
}
// -----------------------------------------------------------------------------------
- (IBAction)previousKeyframe:(id)sender
// -----------------------------------------------------------------------------------
{
    NSNumber *prv = [self previousKeyframeNumber];
    if (prv != nil)
	[self setCurrentFrame:[prv intValue]];
}
// -----------------------------------------------------------------------------------
- (IBAction)takeKeyFrameValuesfrom:(id)sender
// -----------------------------------------------------------------------------------
{
    [[self window] setDocumentEdited:YES];
    NSNumber *frameNum = [NSNumber numberWithLong:[self currentFrame]];
    NKDLaserEffectSettings *frameSet = [settings objectForKey:frameNum];
    if ([sender isMemberOfClass:[NSColorWell class]])
    {
	[frameSet setAura:[auraColorWell color]];
	[frameSet setCore:[coreColorWell color]];
    }
    else if ([sender isMemberOfClass:[NSTextField class]])
    {
	[frameSet setStartWidth:[startWidthTF intValue]];
	[frameSet setFinishWidth:[endWidthTF intValue]];
    }
    else if ([sender isMemberOfClass:[NSButton class]])
    {
	[frameSet setFinishIsRounded:[endRoundedCheckbox intValue]];
	[frameSet setStartIsRounded:[startRoundedCheckbox intValue]];
	[frameSet setEmitterBulbEffect:[emitterBulbCheckbox intValue]];
    }
    else if ([sender isMemberOfClass:[NSSlider class]])
    {
	[frameSet setStartWidth:[startWidthSlider intValue]];
	[frameSet setFinishWidth:[endWidthSlider intValue]];
    }
    
    [self setKeyframeValues:frameSet];
    [docView setNeedsDisplay:YES];
    [docView setRenderedImage:nil];
    //[frameSet setStartWidth:startWidth]
}
// -----------------------------------------------------------------------------------
- (IBAction)previewFrame:(id)sender
// -----------------------------------------------------------------------------------
{
    [docView render];
}
// -----------------------------------------------------------------------------------
- (IBAction)renderMovie:(id)sender
// -----------------------------------------------------------------------------------
{
    NSButton *senderButton = sender;
    
    [NSApp beginSheet:progressPanel
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(renderMovieDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
    
    long framesInt = [[self movie] numberOfFrames];
    double frames = [[NSNumber numberWithLong:framesInt] doubleValue];
    [progressIndicator setMinValue:0];
    [progressIndicator setDoubleValue:0];
    [progressIndicator setMaxValue:frames];
    

    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithInt:[self currentFrame]] forKey:@"currentFrame"];
    [info setObject:[self movie] forKey:@"movie"];
    //BOOL preview = [[info objectForKey:@"preview"] intValue];
    
    // render movie has tag 0
    // preview movie has tag 1
    [info setObject:[NSNumber numberWithBool:([senderButton tag] == 1) ? YES : NO] forKey:@"preview"];
    [progressText setStringValue:[NSString stringWithFormat:@"Rendering 1 of %d frames.", framesInt]];
    
    
    if ([senderButton tag] == 0)
    {
	NSSavePanel *sp;
	int runResult;
	sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"mov"];
	runResult = [sp runModal];
	if (runResult == NSOKButton)
	{
	    [info setObject:[sp filename] forKey:@"outputname"];
	}
	else return;
    }
    
    [NSThread detachNewThreadSelector:@selector(renderMovieThread:) toTarget:self withObject:info];

}
// -----------------------------------------------------------------------------------
- (IBAction)cancelButtonPresed:(id)sender
// -----------------------------------------------------------------------------------
{
    [self setShouldCancel:YES];
    //[panel orderOut:sender];
    //[NSApp endSheet:panel returnCode:0];
}
// -----------------------------------------------------------------------------------
- (IBAction)effectTypeChanged:(id)sender
// -----------------------------------------------------------------------------------
{
    NSString *req = [[effectTypePopUp selectedItem] title];
    [[self currentSettings] setEffectType:req];
    [docView setNeedsDisplay:YES];
    [docView setRenderedImage:nil];
}
#pragma mark -
#pragma mark Modal Dialogs
#pragma mark -
// -----------------------------------------------------------------------------------
- (void)selectMovie:(id)dummy
// -----------------------------------------------------------------------------------
{
    
    
//    if ([self fileName] != nil)
//	[self readFromFile:[self fileName] ofType:@"Crimson Document"];
    if ([self moviePath] == nil)
    {
	[[self window] setDocumentEdited:YES];
	NSBeginAlertSheet(@"Select Source Movie",@"Okay",
			  nil,
			  nil,
			  [self window],
			  self,
			  nil,
			  @selector(selectMovieDialogDidEnd:returnCode:contextInfo:),
			  nil,
			  @"Please select the source Quicktime movie file to edit");
    }
    else
    {
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:[self moviePath]])
	{
	    NSBeginAlertSheet(@"Source movie not found",@"Okay",
			      nil,
			      nil,
			      [self window],
			      self,
			      nil,
			      @selector(selectMovieDialogDidEnd:returnCode:contextInfo:),
			      nil,
			      @"The original movie could not be found at its original location. Please select the source movie for this document.");
	}
	else
	    [self loadSourceMovie];
    }
}
// -----------------------------------------------------------------------------------
- (void)selectMovieDialogDidEnd:(NSWindow *)sheet 
		     returnCode:(int)returnCode
		    contextInfo:(void *)contextInfo
// -----------------------------------------------------------------------------------
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel beginSheetForDirectory:nil
			     file:nil
			    types:[NKDMutableMovie movieUnfilteredFileTypes]
		   modalForWindow:[self window]
		    modalDelegate:self
		   didEndSelector:@selector(openMovieDialogDidEnd:returnCode:contextInfo:)
		      contextInfo:nil];
}
// -----------------------------------------------------------------------------------
- (void)openMovieDialogDidEnd:(NSOpenPanel *)panel 
		   returnCode:(int)returnCode 
		  contextInfo:(void *)contextInfo
// -----------------------------------------------------------------------------------
{
    if (returnCode == NSOKButton)
    {
	[self setMoviePath:[panel filename]];
	[self loadSourceMovie];
    }
    else
	[self close];
    
}
// -----------------------------------------------------------------------------------
- (void)loadSourceMovie
// -----------------------------------------------------------------------------------
{

    NKDMutableMovie *mov =  [[NKDMutableMovie alloc] initWithURL: [NSURL fileURLWithPath:[self moviePath]] byReference:NO];
    [self setMovie:mov];
    [mov release];
    
    
    NSSize movieSize = [[self movie] size];
    
    // Can't work with small movies
    if (movieSize.width < 320 || movieSize.height < 240)
    {
	[self setMovie:nil];
	NSBeginAlertSheet(@"Can't use that movie",@"Okay",
			  nil,
			  nil,
			  [self window],
			  self,
			  nil,
			  @selector(selectMovieDialogDidEnd:returnCode:contextInfo:),
			  nil,
			  @"Sorry. Crimson FX does not work with movies smaller than 320x240 pixels.");
	return;
    }
    
    [self setCurrentFrame:0];
    int widthChange = 716 - movieSize.width;
    int heightChange = 476 - movieSize.height;
    NSRect curRect = [[self window] frame];
    curRect.size.width -= widthChange;
    curRect.size.height -= heightChange;
    
    [[self window] setFrame:curRect display:YES animate:YES];
    
    double max = [movie numberOfFrames]-1;
    [frameSlider setMaxValue:max];
    double cur = [self currentFrame];
    [frameSlider setDoubleValue:cur];
    
    [docView setDocument:self];
    [docView setNeedsDisplay:YES];
    
}
#pragma mark -
// -----------------------------------------------------------------------------------
- (void)updateKeyframeStatus
// -----------------------------------------------------------------------------------
{
    [auraColorWell setEnabled:[keyframeCheckbox intValue]];
    [coreColorWell setEnabled:[keyframeCheckbox intValue]];
    [startNudgeUp setEnabled:[keyframeCheckbox intValue]];
    [startNudgeRight setEnabled:[keyframeCheckbox intValue]];
    [startNudgeDown setEnabled:[keyframeCheckbox intValue]];
    [startNudgeLeft setEnabled:[keyframeCheckbox intValue]];
    [startWidthTF setEnabled:[keyframeCheckbox intValue]];
    [startWidthSlider setEnabled:[keyframeCheckbox intValue]];
    [startRoundedCheckbox setEnabled:[keyframeCheckbox intValue]];
    [endNudgeUp setEnabled:[keyframeCheckbox intValue]];
    [endNudgeRight setEnabled:[keyframeCheckbox intValue]];
    [endNudgeDown setEnabled:[keyframeCheckbox intValue]];
    [endNudgeLeft setEnabled:[keyframeCheckbox intValue]];
    [endWidthTF setEnabled:[keyframeCheckbox intValue]];
    [endWidthSlider setEnabled:[keyframeCheckbox intValue]];
    [endRoundedCheckbox setEnabled:[keyframeCheckbox intValue]]; 
    [emitterBulbCheckbox setEnabled:[keyframeCheckbox intValue]];
    
    [effectTypePopUp setEnabled:[keyframeCheckbox intValue]];
    
    [docView setNeedsDisplay:YES];
    [docView setRenderedImage:nil];
}
// -----------------------------------------------------------------------------------
- (void)setKeyframeValues:(NKDLaserEffectSettings *)frameSet
// -----------------------------------------------------------------------------------
{
    if (frameSet != nil)
    {
	[auraColorWell setColor:[frameSet aura]];
	[coreColorWell setColor:[frameSet core]];
	[startWidthTF setIntValue:[frameSet startWidth]];
	[startWidthSlider setIntValue:[frameSet startWidth]];
	[startRoundedCheckbox setIntValue:[frameSet startIsRounded]];
	[endWidthTF setIntValue:[frameSet finishWidth]];
	[endWidthSlider setIntValue:[frameSet finishWidth]];
	[endRoundedCheckbox setIntValue:[frameSet finishIsRounded]];
	[emitterBulbCheckbox setIntValue:[frameSet emitterBulbEffect]];
	
	[effectTypePopUp setStringValue:[frameSet effectType]];
    }
}
// -----------------------------------------------------------------------------------
- (NSNumber *)nextKeyframeNumber
// -----------------------------------------------------------------------------------
{
    NSEnumerator *keys = [[[settings allKeys]sortedArrayUsingSelector:@selector(compare:)] objectEnumerator];
    NSNumber *curKey;
    while (curKey = [keys nextObject]) 
    {
	if ([curKey intValue] > [self currentFrame])
	    return curKey;
    }
    return nil;
}
// -----------------------------------------------------------------------------------
- (NSNumber *)previousKeyframeNumber
// -----------------------------------------------------------------------------------
{
    NSEnumerator *keys = [[[settings allKeys]sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
    NSNumber *curKey;
    while (curKey = [keys nextObject]) 
    {
	if ([curKey intValue] < [self currentFrame])
	    return curKey;	
    }
    return nil;
}
// -----------------------------------------------------------------------------------
- (void)launchMovieAt:(NSString *)filename
// -----------------------------------------------------------------------------------
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/open"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"-a", @"/Applications/QuickTime Player.app", filename, nil];
    [task setArguments: arguments];

    [task launch];

}
#pragma mark -
#pragma mark NSObject Overrides
#pragma mark -
// -----------------------------------------------------------------------------------
-(NSString *)description
// -----------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"NKDCrimsonDocument: \n\tFilename %@", [self moviePath]];
}
// -----------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)coder
// -----------------------------------------------------------------------------------
{

    self = 	[super init];
    [coder decodeValueOfObjCType:@encode(long) at:&currentFrame];
    //[coder decodeValueOfObjCType:@encode(long) at:&currentFrame];
    [self setMoviePath:[coder decodeObject]];
    [self setSettings:[coder decodeObject]];
    
    // Do we need to load the movie, or will that happen automatically??
    
    return self;
}
//----------------------------------------------------------------------
- (void) encodeWithCoder: (NSCoder *)coder
//----------------------------------------------------------------------
{
    // We only encode the path, not the actual movie
    //[super encodeWithCoder: coder];
    [coder encodeValueOfObjCType:@encode(long) at:&currentFrame];
    [coder encodeObject:[self moviePath]];
    [coder encodeObject:[self settings]];
    
}
// -----------------------------------------------------------------------------------
-(void)dealloc
// -----------------------------------------------------------------------------------
{
    [moviePath release];
    [settings release];
    [super dealloc];
}
#pragma mark -
#pragma mark Threaded Methods
#pragma mark -
// -----------------------------------------------------------------------------------
- (void)renderMovieDidEnd: (NSWindow *)sheet
               returnCode:(int)returnCode
              contextInfo:(NSDictionary *)info
// -----------------------------------------------------------------------------------
{
    [docView setRendering:NO];
    [docView setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------------
- (void)incrementProgress
// -----------------------------------------------------------------------------------
{
    [progressIndicator incrementBy:1.0];
    [progressText setStringValue:[NSString stringWithFormat:@"Rendering %d of %d frames.", [[NSNumber numberWithDouble:[progressIndicator doubleValue]] intValue], [[NSNumber numberWithDouble:[progressIndicator maxValue]] intValue]]];
}
// -----------------------------------------------------------------------------------
- (void)setProgressTextFromThread:(NSString *)inText
// -----------------------------------------------------------------------------------
{
    [progressText setStringValue:inText];
}
// -----------------------------------------------------------------------------------
- (void)renderMovieThread:(NSDictionary *)info
// -----------------------------------------------------------------------------------
{
    NSConnection		*theConnection;
    id 				theProxy;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NKDMutableMovie *tMovie = [info objectForKey:@"movie"];
    int restoreFrame = [[info objectForKey:@"currentFrame"] intValue];
    BOOL preview = [[info objectForKey:@"preview"] intValue];
    NSString *outputname = [info objectForKey:@"outputname"];
    
    
    theConnection = [NSConnection connectionWithRegisteredName:@"main" host:nil];    
    theProxy = [[theConnection rootProxy] retain];
    [theProxy setProtocolForProxy:@protocol(CrimsonThreadWatchProtocol)];
    [[theProxy docView] setRendering:YES];
    int i;
    NSCalendarDate *now = [NSCalendarDate date];
    
    //NSString *tmpPath = [NSString stringWithFormat:@"/tmp/crimsonrender%@.mov", [now descriptionWithCalendarFormat:@"%H%M%S"]];
    // Create a new movie
    NKDMutableMovie *theMovie = [[NKDMutableMovie alloc] initWithPath:outputname];
    //NSLog(@"theMovie: %@", theMovie);
    [theMovie addVideoTrackOfHeight:[[self movie] size].height andWidth:[[self movie] size].width];
    
    // store current frame
    int originalFrame = [theProxy currentFrame];
    [theProxy setCurrentFrame:0];
    NSImage *thisFrame = nil;
    int fps = [tMovie desiredFPS];
    
    BOOL wasCancelled = NO;
    for (i=0; i<[tMovie numberOfFrames] ; i++)
    {
	if ([theProxy shouldCancel])
	{
	    i = [tMovie numberOfFrames];
	    wasCancelled = YES;
	}
	else
	{
	    NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
	    thisFrame = (preview) ? [[self currentPreviewFrame] retain] : [[self currentRenderedFrame] retain];
	    
	    //NSLog(@"fps: %i", header.framesPerSec);
	    [theMovie insertFrameFromImage:thisFrame usingFPS:fps];
	    [theProxy incrementProgress];
	    [thisFrame release];
	    [theProxy stepForward:self];
	    [pool2 release];
	}
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:.01]];
    }
    if (!wasCancelled)
    {
	
	// TODO: This isn't working... dunno why
//	OSErr err;
//	err = QTUCopySoundTracks([tMovie QTMovie], [theMovie QTMovie]);
//	if (err != noErr)
//	    NSLog(@"QTUCopySoundTracks Error: %d", err);
//	[tMovie updateMovieFile];

	Track track = [tMovie getFirstAudioTrack];
	[theMovie addAudioTrack:track];
	
	if (!preview)
	{
	    [theProxy setProgressTextFromThread:@"compressing..."];
	    //NSError *error;
	    //QTMovie *movie = [QTMovie movieWithFile:tmpPath error:&error];
	    
	    
	    //SetFirstRecompressState(true);
	    // FSSpec		mySpec =  [tmpPath fsSpec];
	    //[@"" writeToFile:outputname atomically:NO];
	    //FSSpec		outputSpec = [outputname fsSpec];
	    //int anErr =  RecompressMovieFile(&mySpec, &outputSpec);
	    //if (anErr != noErr)
		    //NSLog(@"Error recompressing movie: %d", anErr);
	    //[[NSFileManager defaultManager] removeFileAtPath:tmpPath handler:nil];
	    [self performSelectorOnMainThread:@selector(launchMovieAt:) withObject:outputname waitUntilDone:NO];
	
	}
	else
	    [self performSelectorOnMainThread:@selector(launchMovieAt:) withObject:outputname waitUntilDone:NO];
	
	[self performSelectorOnMainThread:@selector(setCurrentFrameFromObject:) withObject:[NSNumber numberWithInt:originalFrame] waitUntilDone:NO];
	
	//[self setCurrentFrame:originalFrame];
    }
    [progressPanel orderOut:self];
    [NSApp endSheet:progressPanel returnCode:0];
    [theProxy release];
    [pool release];
}
// -----------------------------------------------------------------------------------
- (NSImage *)currentRenderedFrame
// -----------------------------------------------------------------------------------
{   
    NKDLaserEffectSettings *set = [self currentSettings];
    
    // just return the original frame if there's no effect visible in the frame
    if ([set start].x < 0 && [set start].y < 0 && [set finish].x < 0 && [set finish].y < 0)
	return [self currentFrameImage];
    
    NSImage *curFrameImg = [[self currentFrameImage] retain];
    
    NSImage *dst = [set renderEffectWithImage:curFrameImg];
    [curFrameImg release];
    return dst;
    
}
// -----------------------------------------------------------------------------------
- (NSImage *)currentPreviewFrame
// -----------------------------------------------------------------------------------
{
    NKDLaserEffectSettings *set = [self currentSettings];
    NSImage *curFrame = [[self currentFrameImage] retain]; 
    NSImage *ret = [set renderPreviewEffectWithImage:curFrame];
    [curFrame release];
    return [ret autorelease];
}
@end
