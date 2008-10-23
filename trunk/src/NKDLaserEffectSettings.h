// -----------------------------------------------------------------------------------
//  NKDLaserEffectSettings.h part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import <Cocoa/Cocoa.h>
#import "NKDConvolutionKernel.h"
#import "NSImage-Mosaic.h"
//#import "NSBezierPath-Saber.h"


/*!
@header NKDLaserEffectSettings.h
@discussion This class encapsulates the settings for the effects of a single keyframe.
*/


#define K_EFFECT_LASER @"Laser"
#define K_EFFECT_BLUR_RECT @"Blur (Rectangle)"
#define K_EFFECT_MOSAIC @"Mosaic"
#define K_COLOR_EMBOSS_RECT @"Emboss (Rectangle)"
#define K_HORIZONTAL_SHIFT_RECT @"Horizontal Shift (Rectangle)"
#define K_LAPLACIAN_RECT @"Laplacian (Rectangle)"
/*

#define K_EFFECT_BLUR_RECT @"Blur (Rectangle)"
#define K_EFFECT_BLUR_MORE @"Blur More"
#define K_EFFECT_SHARPEN @"Sharpen"
#define K_EFFECT_LIGHTNING @"Lightning"
 */

@interface NKDLaserEffectSettings : NSObject 
{
    NSPoint		    start;
    NSPoint		    finish;
    NSColor		    *core;
    NSColor		    *aura;
    int			    startWidth;
    int			    finishWidth;
    BOOL		    startIsRounded;
    BOOL		    finishIsRounded;
    BOOL		    emitterBulbEffect;
    
    // ---------------------------------------
    NSString *		    effectType;

}

+(NSArray *)effectTypes;
- (id)initWithStartPoint: (NSPoint)inStart
	     finishPoint: (NSPoint)inFinish
	       coreColor: (NSColor *)inCore
	       auraColor: (NSColor *)inAura
	      startWidth: (int)inStartWidth
	     finishWidth: (int)inFinishWidth
	  startIsRounded: (BOOL)inStartRounded
         finishIsRounded: (BOOL)inFinishRounded
       emitterBulbEffect: (BOOL)inEmitterBulb
	   andEffectType: (NSString *)inType;
- (id)initWithStartPoint: (NSPoint)inStart
	     finishPoint: (NSPoint)inFinish
	       coreColor: (NSColor *)inCore
	       auraColor: (NSColor *)inAura
	      startWidth: (int)inStartWidth
	     finishWidth: (int)inFinishWidth
	  startIsRounded: (BOOL)inStartRounded
         finishIsRounded: (BOOL)inFinishRounded
    andEmitterBulbEffect: (BOOL)inEmitterBulb;
- (NSPoint)start;
- (void)setStart:(NSPoint)newStart;
- (NSPoint)finish;
- (void)setFinish:(NSPoint)newFinish;
- (NSColor *)core;
- (void)setCore:(NSColor *)newCore;
- (NSColor *)aura;
- (void)setAura:(NSColor *)newAura;
- (int)startWidth;
- (void)setStartWidth:(int)newStartWidth;
- (int)finishWidth;
- (void)setFinishWidth:(int)newFinishWidth;
- (BOOL)startIsRounded;
- (void)setStartIsRounded:(BOOL)newStartIsRounded;
- (BOOL)finishIsRounded;
- (void)setFinishIsRounded:(BOOL)newFinishIsRounded;
- (BOOL)emitterBulbEffect;
- (void)setEmitterBulbEffect:(BOOL)newEmitterBulbEffect;
- (NSString *)effectType;
- (void)setEffectType:(NSString *)newEffectType;

- (NSImage *)renderEffectWithImage:(NSImage *)image;
- (NSImage *)renderPreviewEffectWithImage:(NSImage *)inImage;
@end
