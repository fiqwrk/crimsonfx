// -----------------------------------------------------------------------------------
//  NSImage-Mosaic.m
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on Wed May 01 2002.
//  Copyright (c) 2002 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import "NSImage-Mosaic.h"

@implementation NSImage(Mosaic)
// -----------------------------------------------------------------------------------
-(NSImage *)mosaicRect:(NSRect)rect withSize:(int)tileSize
// -----------------------------------------------------------------------------------
{
    NSBitmapImageRep *mosaicImage;
    NSImage *image;
    NSData *data;
    unsigned char * imageBuffer;
    int currRow=0, currCol=0, tileRow=0, tileCol=0, i;
    
    int pixelCount = 0;
    int rowBytes = 0;
    int bytesPerPixel = 0;
    int curPos = 0;

    NSMutableData * channelAvgs;
    int * chanAvg;
    
    if (tileSize < 2)
    {
	NSLog(@"Tiles can't be smaller than 2x2 pixels");
	return self;
    }
    data = [[NSData alloc] initWithData:[self TIFFRepresentation]];
    mosaicImage = [[NSBitmapImageRep alloc] initWithData:data];
    imageBuffer = [mosaicImage bitmapData];
    image = [[NSImage alloc] initWithSize:[self size]];
    rowBytes=[mosaicImage bytesPerRow];
    bytesPerPixel = rowBytes / [self size].width;
    channelAvgs = [[NSMutableData dataWithLength:bytesPerPixel * sizeof(int)] retain];
    chanAvg = [channelAvgs mutableBytes];
    
    
    for (currRow = rect.origin.y; currRow < (rect.size.height + rect.origin.y); currRow += tileSize)
    //for (currRow = rect.size.height + rect.origin.y; currRow > rect.origin.y; currRow -= tileSize)
    {
	for (currCol = rect.origin.x; currCol < (rect.size.width + rect.origin.x); currCol += tileSize)
	{
	    pixelCount = 0;
	    for (tileRow = 0; tileRow < tileSize; tileRow++)
	    {
		for (tileCol = 0; tileCol < tileSize; tileCol++)
		{
		    curPos = ((currRow + tileRow) * rowBytes) + ((currCol + tileCol) * bytesPerPixel);
		    pixelCount++;
		    for (i = 0; i < bytesPerPixel; i++)
		    {
			chanAvg[i] += imageBuffer[curPos + i];
		    }
		}
	    }
	 
	    for (i = 0; i < bytesPerPixel; i++)
		chanAvg[i] /= pixelCount;

	    for (tileRow = 0; tileRow < tileSize; tileRow++)
	    {
		// Stay within defined rect
		if ((currRow + tileRow) >= (rect.origin.y + rect.size.height) )
		    break;
		
		for (tileCol = 0; tileCol < tileSize; tileCol++)
		{
		    curPos = ((currRow + tileRow) * rowBytes) + ((currCol + tileCol) * bytesPerPixel);

		    if ((currCol + tileCol) >= (rect.origin.x + rect.size.width) )
			break;

		    for (i = 0; i < bytesPerPixel; i++)
			imageBuffer[curPos + i] = chanAvg[i];
		}
	    }

	    // Reset channel averages to 0
	    for (i=0; i < bytesPerPixel; i++)
		chanAvg[i] = 0;
	}
    }
    [channelAvgs release];
    [image addRepresentation:mosaicImage];
    [mosaicImage release];
    return [image autorelease];
}
// -----------------------------------------------------------------------------------
-(NSImage *)mosaicRects:(NSArray *)rects andTileSize:(int)tileSize
// -----------------------------------------------------------------------------------
{
    int i;
    NSImage *image = [[self copy] autorelease];

    for (i = 0; i < [rects count]; i++)
	image = [image mosaicRect:[[rects objectAtIndex:i] rectValue] withSize:tileSize];

    return image;
}
@end
