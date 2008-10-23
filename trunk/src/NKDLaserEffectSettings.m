// -----------------------------------------------------------------------------------
//  NKDLaserEffectSettings.m part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NKDLaserEffectSettings.h"


@implementation NKDLaserEffectSettings
#pragma mark -
#pragma mark Class Methods
#pragma mark -
// -----------------------------------------------------------------------------------
+(NSArray *)effectTypes
// -----------------------------------------------------------------------------------
{
    static NSArray *effectTypes;
    
    if (effectTypes == nil)
	effectTypes = [[NSArray arrayWithObjects:K_EFFECT_LASER, K_EFFECT_BLUR_RECT, K_COLOR_EMBOSS_RECT,K_HORIZONTAL_SHIFT_RECT, K_LAPLACIAN_RECT, nil] retain];
    
    return effectTypes;
}
#pragma mark -
#pragma mark Initializers
#pragma mark -
// -----------------------------------------------------------------------------------
- (id)initWithStartPoint: (NSPoint)inStart
	     finishPoint: (NSPoint)inFinish
	       coreColor: (NSColor *)inCore
	       auraColor: (NSColor *)inAura
	      startWidth: (int)inStartWidth
	     finishWidth: (int)inFinishWidth
	  startIsRounded: (BOOL)inStartRounded
         finishIsRounded: (BOOL)inFinishRounded
       emitterBulbEffect: (BOOL)inEmitterBulb
	   andEffectType: (NSString *)inType
// -----------------------------------------------------------------------------------
{
    if (self = [super init])
    {
	[self setEffectType:inType];
        [self setStart:inStart];
	[self setFinish:inFinish];
	[self setCore:inCore];
	[self setAura:inAura];
	[self setStartWidth:inStartWidth];
	[self setFinishWidth:inFinishWidth];
	[self setStartIsRounded:inStartRounded];
	[self setFinishIsRounded:inFinishRounded];
	[self setEmitterBulbEffect:inEmitterBulb];
    }
    return self;   
}
// -----------------------------------------------------------------------------------
- (id)initWithStartPoint: (NSPoint)inStart
	     finishPoint: (NSPoint)inFinish
	       coreColor: (NSColor *)inCore
	       auraColor: (NSColor *)inAura
	      startWidth: (int)inStartWidth
	     finishWidth: (int)inFinishWidth
	  startIsRounded: (BOOL)inStartRounded
         finishIsRounded: (BOOL)inFinishRounded
    andEmitterBulbEffect: (BOOL)inEmitterBulb
// -----------------------------------------------------------------------------------
{
    return [self initWithStartPoint: inStart
			finishPoint: inFinish
			  coreColor: inCore
			  auraColor: inAura
			 startWidth: inStartWidth
			finishWidth: inFinishWidth
		     startIsRounded: inStartRounded
		    finishIsRounded: inFinishRounded
		  emitterBulbEffect: inEmitterBulb
		      andEffectType: K_EFFECT_LASER];
}
#pragma mark -
#pragma mark Accessors & Mutators
#pragma mark -
// -----------------------------------------------------------------------------------
- (NSPoint)start
// -----------------------------------------------------------------------------------
{
    return start;
}
// -----------------------------------------------------------------------------------
- (void)setStart:(NSPoint)newStart
// -----------------------------------------------------------------------------------
{
    start = newStart;
}
// -----------------------------------------------------------------------------------
- (NSPoint)finish
// -----------------------------------------------------------------------------------
{
    return finish;
}
// -----------------------------------------------------------------------------------
- (void)setFinish:(NSPoint)newFinish
// -----------------------------------------------------------------------------------
{
    finish = newFinish;
}
// -----------------------------------------------------------------------------------
- (NSColor *)core
// -----------------------------------------------------------------------------------
{
    return core;
}
// -----------------------------------------------------------------------------------
- (void)setCore:(NSColor *)newCore
// -----------------------------------------------------------------------------------
{
    [newCore retain];
    [core release];
    core = newCore;
}
// -----------------------------------------------------------------------------------
- (NSColor *)aura
// -----------------------------------------------------------------------------------
{
    return aura;
}
// -----------------------------------------------------------------------------------
- (void)setAura:(NSColor *)newAura
// -----------------------------------------------------------------------------------
{
    [newAura retain];
    [aura release];
    aura = newAura;
}
// -----------------------------------------------------------------------------------
- (int)startWidth
// -----------------------------------------------------------------------------------
{
    return startWidth;
}
// -----------------------------------------------------------------------------------
- (void)setStartWidth:(int)newStartWidth
// -----------------------------------------------------------------------------------
{
    startWidth = newStartWidth;
}
// -----------------------------------------------------------------------------------
- (int)finishWidth
// -----------------------------------------------------------------------------------
{
    return finishWidth;
}
// -----------------------------------------------------------------------------------
- (void)setFinishWidth:(int)newFinishWidth
// -----------------------------------------------------------------------------------
{
    finishWidth = newFinishWidth;
}
// -----------------------------------------------------------------------------------
- (BOOL)startIsRounded
// -----------------------------------------------------------------------------------
{
    return startIsRounded;
}
// -----------------------------------------------------------------------------------
- (void)setStartIsRounded:(BOOL)newStartIsRounded
// -----------------------------------------------------------------------------------
{
    startIsRounded = newStartIsRounded;
}
// -----------------------------------------------------------------------------------
- (BOOL)finishIsRounded
// -----------------------------------------------------------------------------------
{
    return finishIsRounded;
}
// -----------------------------------------------------------------------------------
- (void)setFinishIsRounded:(BOOL)newFinishIsRounded
// -----------------------------------------------------------------------------------
{
    finishIsRounded = newFinishIsRounded;
}
// -----------------------------------------------------------------------------------
- (BOOL)emitterBulbEffect
// -----------------------------------------------------------------------------------
{
    return emitterBulbEffect;
}
// -----------------------------------------------------------------------------------
- (void)setEmitterBulbEffect:(BOOL)newEmitterBulbEffect
// -----------------------------------------------------------------------------------
{
    emitterBulbEffect = newEmitterBulbEffect;
}
// -----------------------------------------------------------------------------------
- (NSString *)effectType
// -----------------------------------------------------------------------------------
{
    return effectType;
}
// -----------------------------------------------------------------------------------
- (void)setEffectType:(NSString *)newEffectType
// -----------------------------------------------------------------------------------
{
    [newEffectType retain];
    [effectType release];
    effectType = newEffectType;
}
#pragma mark -
#pragma mark - Rendering
#pragma mark -
//----------------------------------------------------------------------
- (NSImage *)renderPreviewEffectWithImage:(NSImage *)inImage
//----------------------------------------------------------------------
{
    if ([[self effectType]isEqual:K_EFFECT_LASER])
    {
	[inImage retain];
	NSImage *ret = [inImage copy];
	[ret lockFocus];
	  
	NSBezierPath *path = [NSBezierPath saberPathFromPoint:[self start] 
						   startWidth:[self startWidth] 
						      toPoint:[self finish]
						     endWidth:[self finishWidth] 
						   roundStart:[self startIsRounded]
						  roundFinish:[self finishIsRounded]
					       andEmitterBulb:[self emitterBulbEffect]];
	
	[[self aura] set];
	[path setLineWidth:2.0];
	[path stroke];
	[[self core] set];
	[path fill];

	[ret unlockFocus];
	[inImage release];
	return [ret autorelease];
    }
     if ([[self effectType]isEqual:K_EFFECT_MOSAIC])
     {
	 [inImage retain];
	 NSImage *ret = [inImage copy];
	 NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect([self start].x, [self start].y, [self finish].x - [self start].x, [self finish].y - [self start].y)];
	 
	 [ret lockFocus];
	 [[NSColor whiteColor] set];
	 [path setLineWidth:2.0];
	 [path stroke];
	 [ret unlockFocus];
	 [inImage release];
	 return [ret autorelease];
	 
     }
    else if ([[self effectType] isEqual:K_EFFECT_BLUR_RECT] || [[self effectType] isEqual:K_COLOR_EMBOSS_RECT] || [[self effectType] isEqual:K_HORIZONTAL_SHIFT_RECT] || [[self effectType] isEqual:K_LAPLACIAN_RECT])
    {
	[inImage retain];
	NSImage *ret = [inImage copy];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect([self start].x, [self start].y, [self finish].x - [self start].x, [self finish].y - [self start].y)];
	
	[ret lockFocus];
	[[NSColor whiteColor] set];
	[path setLineWidth:2.0];
	[path stroke];
	[ret unlockFocus];
	[inImage release];
	return [ret autorelease];
    }
    return inImage;
}
//----------------------------------------------------------------------
- (NSImage *)renderEffectWithImage:(NSImage *)inImage
//----------------------------------------------------------------------
{
      
    if ([[self effectType]isEqual:K_EFFECT_LASER])
    {
	NSImage *image = [[NSImage alloc] initWithSize:[inImage size]];
	[image lockFocus];
	[inImage dissolveToPoint:NSMakePoint(0,0) fraction:1.0];
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:NSMakeRect(0,0,[inImage size].width,[inImage size].height)]; 
	
	
	
	NSBezierPath *corePath = [[NSBezierPath saberPathFromPoint:[self start] 
							startWidth:[self startWidth] 
							   toPoint:[self finish] 
							  endWidth:[self finishWidth] 
							roundStart:[self startIsRounded] 
						       roundFinish:[self finishIsRounded]
						    andEmitterBulb:[self emitterBulbEffect]] retain];
	NSBezierPath *tightAuraPath = [[NSBezierPath saberPathFromPoint:[self start] 
							     startWidth:[self startWidth]*1.25 
								toPoint:NSMakePoint([self finish].x+1, [self finish].y+1) 
							       endWidth:[self finishWidth]*1.25
							     roundStart:[self startIsRounded] 
							    roundFinish:[self finishIsRounded]
							 andEmitterBulb:[self emitterBulbEffect]] retain];
	NSBezierPath *looseAuraPath = [[NSBezierPath saberPathFromPoint:[self start] 
							     startWidth:[self startWidth]*2.75
								toPoint:NSMakePoint([self finish].x+2, [self finish].y+2) 
							       endWidth:[self finishWidth]*2.75
							     roundStart:[self startIsRounded] 
							    roundFinish:[self finishIsRounded]
							 andEmitterBulb:[self emitterBulbEffect]] retain];
	
	NKDConvolutionKernel *blurMore = [[NKDConvolutionKernel blurMore] retain];
	NKDConvolutionKernel *blur = [[NKDConvolutionKernel blur] retain];
	
	float r,g,b,a;
	
	[[self aura] getRed:&r green:&g blue:&b alpha:&a];
	
	[[NSColor colorWithCalibratedRed:r/3.25 green:(g/3.25) blue:b/3.25 alpha:1.0] set];
	[looseAuraPath fill];
	[image unlockFocus];
	NSImage *tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	
	[image lockFocus];
	
	[[NSColor colorWithCalibratedRed:r/2.25 green:(g/2.25) blue:(b/2.25) alpha:1.0] set];
	[looseAuraPath fill];
	[image unlockFocus];
	tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	[image lockFocus];
	tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	
	[[NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0] set];
	[tightAuraPath fill];
	[image unlockFocus];
	tmpImage = [[blurMore filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	[image lockFocus];
	
	[[self core] set];
	[corePath fill];
	[image unlockFocus];
	tmpImage = [[blur filterUsingVImage:image] retain];
	if (tmpImage != nil)
	{
	    [image release];
	    image = tmpImage;
	}
	
	NSImage *dst = [[NSImage alloc] initWithSize:[inImage size]];
	[dst lockFocus];
	[inImage dissolveToPoint:NSMakePoint(0,0) fraction:1.0];
	[image compositeToPoint:NSMakePoint(0,0) operation:NSCompositePlusLighter];
	[dst unlockFocus];
	
	[corePath release];
	[tightAuraPath release];
	[looseAuraPath release];
	[blurMore release];
	[blur release];
	[image release];
	return [dst autorelease];
    }
    else if ([[self effectType] isEqual:K_EFFECT_MOSAIC])
    {

	NSImage *image = [[NSImage alloc] initWithSize:[inImage size]];
	[image lockFocus];
	[inImage dissolveToPoint:NSMakePoint(0,0) fraction:1.0];
	
	float tx = 0.0, ty = 0.0;
	float w = 0.0, h = 0.0;
	
	tx = ([self start].x < [self finish].x) ? [self start].x : [self finish].x;
	ty = ([self start].y < [self finish].y) ? [self start].y : [self finish].y;
	
	w = ([self start].x < [self finish].x) ? [self finish].x - [self start].x : [self start].x - [self finish].x;
	h = ([self start].y < [self finish].y) ? [self finish].y - [self start].y : [self start].y - [self finish].y;
	
	NSImage *mos = [[image mosaicRect:NSMakeRect(0,0,[inImage size].width, [inImage size].height) withSize:[self startWidth]] retain];
	
	NSRect rect = NSMakeRect(tx, ty, w, h);
	[mos drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0];
	[image unlockFocus];
	[mos release];
	return [image autorelease];
	//NSRect rect = NSMakeRect(tx, ty, w, h);
    
	
	//return [image mosaicRect:[image withSize:[self startWidth]];
    }
    else if ([[self effectType] isEqual:K_EFFECT_BLUR_RECT] || [[self effectType] isEqual:K_COLOR_EMBOSS_RECT] || [[self effectType] isEqual:K_HORIZONTAL_SHIFT_RECT] || [[self effectType] isEqual:K_LAPLACIAN_RECT])
    {
	NSImage *image = [[NSImage alloc] initWithSize:[inImage size]];
	[image lockFocus];
	[inImage dissolveToPoint:NSMakePoint(0,0) fraction:1.0];

	float tx = 0.0, ty = 0.0;
	float w = 0.0, h = 0.0;
	
	tx = ([self start].x < [self finish].x) ? [self start].x : [self finish].x;
	ty = ([self start].y < [self finish].y) ? [self start].y : [self finish].y;
	
	w = ([self start].x < [self finish].x) ? [self finish].x - [self start].x : [self start].x - [self finish].x;
	h = ([self start].y < [self finish].y) ? [self finish].y - [self start].y : [self start].y - [self finish].y;
	    
	
	
	NKDConvolutionKernel *k = nil;
	
	if ([[self effectType] isEqual:K_EFFECT_BLUR_RECT])
	    k = [[NKDConvolutionKernel blurCrazy] retain];
	else if ([[self effectType] isEqual:K_COLOR_EMBOSS_RECT])
	    k = [[NKDConvolutionKernel colorEmbossFilter] retain];
	else if ([[self effectType] isEqual:K_HORIZONTAL_SHIFT_RECT])
	    k = [[NKDConvolutionKernel horizontalShiftFilter] retain];
	else if ([[self effectType] isEqual:K_LAPLACIAN_RECT])
	    k = [[NKDConvolutionKernel laplacianFilter] retain];
	    
	NSImage *blur = [[k filterUsingVImage:inImage] retain];
	[k release];
	
	NSRect rect = NSMakeRect(tx, ty, w, h);
	[blur drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0];
	[image unlockFocus];
	[blur release];
	return [image autorelease];
	
    }
    return inImage;
}
#pragma mark -
#pragma mark NSObject Overrides
#pragma mark -
// -----------------------------------------------------------------------------------
-(NSString *)description
// -----------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"Effect Type: %@: \n\tfrom (%f, %f) to (%f, %f)\n\tcore color: %@\n\taura color: %@\n\tstart width: %d\n\tend width: %d", [self effectType], [self start].x, [self start].y, [self finish].x, [self finish].y, [self core], [self aura], [self startWidth], [self finishWidth]];

}
// -----------------------------------------------------------------------------------
- (BOOL)isEqual:(id)anObject
// -----------------------------------------------------------------------------------
{
    NKDLaserEffectSettings *compare;    
    compare = anObject;
    
    return  [self start].x == [compare start].x &&
	    [self start].y == [compare start].y &&
	    [self finish].x == [compare finish].x &&
	    [self finish].y == [compare finish].y &&
	    [[self core] isEqual:[compare core]] &&
	    [[self aura] isEqual:[compare aura]] &&
	    [self startWidth] == [compare startWidth] &&
	    [self finishWidth] == [compare finishWidth] &&
	    [self startIsRounded] == [compare startIsRounded] &&
	    [self finishIsRounded] == [compare finishIsRounded] &&
	    [self emitterBulbEffect] == [compare emitterBulbEffect] &&
	    [[self effectType] isEqual:[compare effectType]];
}
// -----------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone
// -----------------------------------------------------------------------------------
{

    NKDLaserEffectSettings *ret = [[[self class] alloc] initWithStartPoint:[self start] 
							       finishPoint:[self finish] 
								 coreColor:[[self core] copy] 
								 auraColor:[[self aura] copy] 
								startWidth:[self startWidth] 
							       finishWidth:[self finishWidth]
							    startIsRounded:[self startIsRounded] 
							   finishIsRounded:[self finishIsRounded]
						         emitterBulbEffect:[self emitterBulbEffect]
							     andEffectType:[self effectType]];
    
    return ret;
}
// -----------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)coder
// -----------------------------------------------------------------------------------
{
    
    
    // Since we subclass NSObject, this call to super
    // init is not necessary, but it's good form to
    // include it, as it is possible that someday
    // NSObject's -init method will do something
    // -----------------------------------------------
    self = 	[super init];
    
    [self setStart:[coder decodePoint]];
    [self setFinish:[coder decodePoint]];
    [self setCore:[coder decodeObject]];
    [self setAura:[coder decodeObject]];
    [coder decodeValueOfObjCType:@encode(int) at:&startWidth];
    [coder decodeValueOfObjCType:@encode(int) at:&finishWidth];
    [coder decodeValueOfObjCType:@encode(BOOL) at:&startIsRounded];
    [coder decodeValueOfObjCType:@encode(BOOL) at:&finishIsRounded];
    [coder decodeValueOfObjCType:@encode(BOOL) at:&emitterBulbEffect];
    
    [self setEffectType:[coder decodeObject]];
    
    return self;
}

//----------------------------------------------------------------------
- (void) encodeWithCoder: (NSCoder *)coder
//----------------------------------------------------------------------
{
    [coder encodePoint:[self start]];
    [coder encodePoint:[self finish]];
    [coder encodeObject:[self core]];
    [coder encodeObject:[self aura]];
    [coder encodeValueOfObjCType:@encode(int) at:&startWidth];
    [coder encodeValueOfObjCType:@encode(int) at:&finishWidth];
    [coder encodeValueOfObjCType:@encode(BOOL) at:&startIsRounded];
    [coder encodeValueOfObjCType:@encode(BOOL) at:&finishIsRounded];
    [coder encodeValueOfObjCType:@encode(BOOL) at:&emitterBulbEffect];
    
    [coder encodeObject:[self effectType]];
    
}
// -----------------------------------------------------------------------------------
-(void)dealloc
// -----------------------------------------------------------------------------------
{
    [core release];
    [aura release];
    [effectType release];

    [super dealloc];
}

@end
