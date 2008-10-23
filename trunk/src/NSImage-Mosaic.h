// -----------------------------------------------------------------------------------
//  NSImage-Mosaic.h
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on Wed May 01 2002.
//  Copyright (c) 2002 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/*!
@header NSImage-Mosaic.h

This is a category on NSImage that provides two instance methods for creating new images based on an existing image that is an exact copy of the existing image EXCEPT that one or more rectanglar sections are converted to a "COPS"-style square-tile mosaic.
 */

/*!
@category NSImage(Mosaic)
@discussion This is a category on NSImage that provides two instance methods for creatin an exact copy of the existing image EXCEPT that one or more rectanglar sections are converted to a "COPS"-style square-tile mosaic. This version works with images that have any number of channels, but applies the mosaic to any channel found, including alpha channels.
 */
@interface NSImage(Mosaic)

/*!
@method mosaicRect:withTileSize:
@abstract Creates new image based on this image, except with the area in a defined NSRect blurred with a square-tile mosaic. <B>NOTE:</B> Mosaic is applied to all channels, including alpha channels.
@param rect An NSRect defining the area to be distorted.
@param tileSize The size (in pixels) of one side of a mosaic tile
@result Autoreleased NSImage that is a copy of this image except with defined rect blurred out using a mosaic. If the section could not be processed for any reason (e.g. an invalid tileSize), then this method simply returns a reference to self, so you should compare the returned value against the original image to see to see if they are the same if you plan on making any modifications to the converted image. If you do not, you could end up accidentally making unintended changes to the original image.
 */
-(NSImage *)mosaicRect:(NSRect)rect withSize:(int)tileSize;

/*!
@method mosaicRects:andTileSize
@abstract Creates image based on this image, except with the area in multiple rectangles turned into a square-tile mosaic. <B>NOTE:</B> Mosaic is applied to all channels, including alpha channels.
@param rects An NSArray with all of the NSRects to be converted, stored using NSValue objects
@param tileSize The size (in pixels) of one side of a mosaic tile
@result Autoreleased NSImage that is a copy of this image except with defined rects blurred out using a mosaic. If none of the sections could be processed for some reason (e.g. an invalid tileSize), then this method simply returns a reference to self, so you should compare the returned value against the original image to see if they are the same if you plan on making any modifications to the converted image. If you do not, you could end up accidentally making unintended changes to the original image.
 */
-(NSImage *)mosaicRects:(NSArray *)rects andTileSize:(int)tileSize;
@end
