// -----------------------------------------------------------------------------------
//  NKDCrimsonMovieFrameView.h part of Crimson
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import <Cocoa/Cocoa.h>
#import "NSBezierPath-Saber.h"
#import "NKDConvolutionKernel.h"
@class NKDCrimsonDocument;  // Can't include NKDCrimsonDocument.h - recursive includes

enum {NOT_DRAGGING, DRAGGING_START, DRAGGING_FINISH, DRAGGING_WHOLE, DRAGGING_NEW};

@interface NKDCrimsonMovieFrameView : NSView 
{
    NSImage		*renderedImage;
    int			renderedFrameNum;
    
    NKDCrimsonDocument	*document;
    
    NSPoint		mouseDown;
    NSPoint		mouseUp;
    BOOL		rendering;
    
    @private
	int		draggingStatus;
}
- (NSImage *)renderedImage;
- (void)setRenderedImage:(NSImage *)newRenderedImage;
- (NKDCrimsonDocument *)document;
- (void)setDocument:(NKDCrimsonDocument *)newDocument;
- (NSPoint)mouseDown;
- (void)setMouseDown:(NSPoint)newMouseDown;
- (NSPoint)mouseUp;
- (void)setMouseUp:(NSPoint)newMouseUp;
- (void)render;
- (NSImage *)currentPreviewFrame;
- (BOOL)rendering;
- (void)setRendering:(BOOL)newRendering;

@end
