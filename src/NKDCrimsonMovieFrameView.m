// -----------------------------------------------------------------------------------
//  NKDCrimsonMovieFrameView.m part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NKDCrimsonMovieFrameView.h"


@implementation NKDCrimsonMovieFrameView
#pragma mark -
#pragma mark NSView Overrides
#pragma mark -
// -----------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame 
// -----------------------------------------------------------------------------------
{
    self = [super initWithFrame:frame];
    if (self) 
    {
	draggingStatus = NOT_DRAGGING;
	rendering = NO;
        // Initialization code here.
    }
    return self;
}
// -----------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect 
// -----------------------------------------------------------------------------------
{
    NSDrawWhiteBezel( [self bounds], rect );
    
    if (rendering)
	return;
    
    if ((renderedImage != nil) && [document currentFrame] == renderedFrameNum)
	[renderedImage compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
    else
    {
	[self setRenderedImage:nil];
	NSImage *curFrame = [self currentPreviewFrame];

	[curFrame compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
    }
    
    /*
    if (rendering)
    {
	[renderedImage compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
	return;
    }

    
    if ((renderedImage != nil) && [document currentFrame] == renderedFrameNum)
	[renderedImage compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
    else
    {
	[self setRenderedImage:nil];
	NSImage *curFrame = [self currentPreviewFrame];
	[curFrame compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
	
    }    */
}
#pragma mark-
#pragma mark Drag &  Drop
#pragma mark -
// ----------------------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)event
// ----------------------------------------------------------------------------------------------
{
    [self setRenderedImage:nil];
    draggingStatus = DRAGGING_NEW;
    
    if (![document isCurrentFrameKeyFrame])
    {
	[[document keyframeCheckbox] setIntValue:1];
	[document toggleKeyFrameStatus:self];
    }
    
    NSPoint p = [event locationInWindow];
    mouseDown = [self convertPoint:p fromView:nil];
    mouseUp = mouseDown;
    [[document currentSettings] setStart:mouseDown];
    [[document currentSettings] setFinish:mouseUp];
    //[self setRenderedImage:nil];
    [self setNeedsDisplay:YES];
}
// ----------------------------------------------------------------------------------------------
- (void)mouseUp:(NSEvent *)event
// ----------------------------------------------------------------------------------------------
{
    NSPoint p = [event locationInWindow];
    mouseUp = [self convertPoint:p fromView:nil];
    [[document currentSettings] setFinish:mouseUp];
    //[self setRenderedImage:nil];
    [self setNeedsDisplay:YES];
    draggingStatus = NOT_DRAGGING;
}
// ----------------------------------------------------------------------------------------------
- (void)mouseDragged:(NSEvent *)event
// ----------------------------------------------------------------------------------------------
{
    NSPoint p = [event locationInWindow];
    mouseUp = [self convertPoint:p fromView:nil];
    [[document currentSettings] setFinish:mouseUp];
    //[self setRenderedImage:nil];
    [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Accessors & Mutators
#pragma mark -
// -----------------------------------------------------------------------------------
- (NSImage *)renderedImage
// -----------------------------------------------------------------------------------
{
    return renderedImage;
}
// -----------------------------------------------------------------------------------
- (void)setRenderedImage:(NSImage *)newRenderedImage
// -----------------------------------------------------------------------------------
{
    [newRenderedImage retain];
    [renderedImage release];
    renderedImage = newRenderedImage;
}
// -----------------------------------------------------------------------------------
- (NKDCrimsonDocument *)document
// -----------------------------------------------------------------------------------
{
    return document;
}
// -----------------------------------------------------------------------------------
- (void)setDocument:(NKDCrimsonDocument *)newDocument
// -----------------------------------------------------------------------------------
{
    [newDocument retain];
    [document release];
    document = newDocument;
}
// -----------------------------------------------------------------------------------
- (NSPoint)mouseDown
// -----------------------------------------------------------------------------------
{
    return mouseDown;
}
// -----------------------------------------------------------------------------------
- (void)setMouseDown:(NSPoint)newMouseDown
// -----------------------------------------------------------------------------------
{
    mouseDown = newMouseDown;
}
// -----------------------------------------------------------------------------------
- (NSPoint)mouseUp
// -----------------------------------------------------------------------------------
{
    return mouseUp;
}
// -----------------------------------------------------------------------------------
- (void)setMouseUp:(NSPoint)newMouseUp
// -----------------------------------------------------------------------------------
{
    mouseUp = newMouseUp;
}
// -----------------------------------------------------------------------------------
- (void)render
// -----------------------------------------------------------------------------------
{
    renderedFrameNum = [document currentFrame];
    [self setRenderedImage:[document currentRenderedFrame]];
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------------
- (NSImage *)currentPreviewFrame
// -----------------------------------------------------------------------------------
{
    NSImage *curFrame = [[document currentFrameImage] retain]; 
    //[curFrame lockFocus];
    //[curFrame compositeToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2) operation:NSCompositeCopy];
    
    //if (! ((mouseDown.x == mouseUp.x) && (mouseDown.y == mouseUp.y)))
    //{
    if (document != nil)
    {
	NSImage *ret = [[document currentSettings] renderPreviewEffectWithImage:curFrame];
	if (ret != nil)
	{
	    [curFrame release];
	    return ret;
	}
	//NSLog(@"document: ", document);
	/*
	if ([document currentSettings] != nil)
	{
	    NSBezierPath *path = nil;
	    path = [NSBezierPath saberPathFromPoint:[self mouseDown] 
					 startWidth:[[document currentSettings] startWidth] 
					    toPoint:[self mouseUp] 
					   endWidth:[[document currentSettings] finishWidth] 
					 roundStart:[[document currentSettings] startIsRounded]
					roundFinish:[[document currentSettings] finishIsRounded]
					  andEmitterBulb:[[document currentSettings] emitterBulbEffect]];
	    
	    [[[document currentSettings] aura] set];
	    [path setLineWidth:2.0];
	    [path stroke];
	    [[[document currentSettings] core] set];
	    [path fill];
	}
	 */
    }
    //[curFrame unlockFocus];
    return [curFrame autorelease];
	
}
// -----------------------------------------------------------------------------------
- (BOOL)rendering
// -----------------------------------------------------------------------------------
{
    return rendering;
}
// -----------------------------------------------------------------------------------
- (void)setRendering:(BOOL)newRendering
// -----------------------------------------------------------------------------------
{
    rendering = newRendering;
}


@end
