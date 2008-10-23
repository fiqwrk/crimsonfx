//
//  NSImage-Filter.m
//  MosaicTester
//
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------

#import "NSImage-Filter.h"


@implementation NSImage(Filter)
// --------------------------------------------------------------------------------------------------------
- (NSImage *)adjustToInputLevelsLow:(int)low andHigh:(int)high
// --------------------------------------------------------------------------------------------------------
{
    int i,x,y;
    
    // Low and High must between 0 and 255 and low must be < high
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
    
    NSData *data = [[NSData alloc] initWithData:[self TIFFRepresentation]];
    NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithData:data];
    //
    int bpp = [imageRep bitsPerPixel] / 8;
    unsigned char *srcData = [imageRep bitmapData];
    unsigned char *destData = [retRep bitmapData];
    
    unsigned char *p1, *p2;
    
    for ( y = 0; y < height; y++ ) 
    {
	for ( x = 0; x < width; x++ ) 
    	{
	    p1 = srcData + bpp * (y * width + x);
	    p2 = destData + bpp * (y * width + x);
	    
	    for (i = 0; i < bpp; i++)
	    {
		unsigned char pix = p1[i];
		if (pix <= low)
		    p2[i] = 0;
		else if (pix >= high)
		    p2[i] = 255;
		else
		    p2[i] = 255/ (high - low);
	    }
	}
    }
    [ret addRepresentation:retRep];
    return [ret autorelease];
}
// --------------------------------------------------------------------------------------------------------
- (NSImage *)grayscaleImage
// --------------------------------------------------------------------------------------------------------
{
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    int x, y;
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
    
    NSBitmapImageRep *retRep = [[[NSBitmapImageRep alloc]initWithBitmapDataPlanes:NULL
								       pixelsWide:width 
								       pixelsHigh:height
								    bitsPerSample:8 
								  samplesPerPixel:1
									 hasAlpha:NO
									 isPlanar:NO
								   colorSpaceName:NSCalibratedWhiteColorSpace
								      bytesPerRow:NULL 
								     bitsPerPixel:NULL] autorelease];
    
    unsigned char *srcData = [imageRep bitmapData];
    unsigned char *destData = [retRep bitmapData];
    unsigned char *p1, *p2;
    int n = [imageRep bitsPerPixel] / 8;
    
    for ( y = 0; y < height; y++ ) {
        for ( x = 0; x < width; x++ ) {
            p1 = srcData + n * (y * width + x);       
	    p2 = destData + y * width + x;
            
            p2[0] = (unsigned char)rint((p1[0] * 0.222) + (p1[1] * 0.707) + (p1[2] * 0.071));
	    
        }
    }
    
    [ret addRepresentation:retRep];
    return [ret autorelease];
}
// --------------------------------------------------------------------------------------------------------
- (NSImage *)fastGaussianBlur: (int)pixels;
// --------------------------------------------------------------------------------------------------------
{
    int sums[5];
    int i, x, y, k;
    
//    int radius = 7;
//    int gauss_fact[7]={1,6,15,20,15,6,1};
    int gauss_sum=0;
    int radius = pixels * 2 + 1;
    int *gauss_fact = malloc(radius * sizeof(int));
    
    // Initialize gauss_fact
    for (i = 0; i < pixels; i++)
    {
	
	gauss_fact[i] = 1 + (5*i);
	gauss_fact[radius - (i + 1)] = 1 + (5 * i);
	gauss_sum += (gauss_fact[i] + gauss_fact[radius - (i + 1)]);
    }
    gauss_fact[(radius - 1)/2] = 1 + (5*pixels);
    gauss_sum += gauss_fact[(radius-1)/2];

    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    
    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
    
    NSData *data = [[NSData alloc] initWithData:[self TIFFRepresentation]];
    NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithData:data];
    NSBitmapImageRep *finalRep = [[NSBitmapImageRep alloc] initWithData:data];
    int bpp = [imageRep bitsPerPixel] / 8;
    
    unsigned char *srcData = [imageRep bitmapData];
    unsigned char *destData = [retRep bitmapData];
    unsigned char *finalData = [finalRep bitmapData];
    
    unsigned char *p1, *p2, *p3;
    
    
    
    
    for ( y = 0; y < height; y++ ) 
    {
        for ( x = 0; x < width; x++ ) 
	{
	    p1 = srcData + bpp * (y * width + x); 
	    p2 = destData + bpp * (y * width + x);
	    
	    for (i=0; i < 5; i++)
		sums[i] = 0;
	    
	    for(k=0;k<radius;k++)
	    {
		if ((y-((radius-1)>>1)+k) < height)
		    p1 = srcData + bpp * ( (y-((radius-1)>>1)+k) * width + x); 
		else
		    p1 = srcData + bpp * (y * width + x);
		
		for (i = 0; i < bpp; i++)
		    sums[i] += p1[i]*gauss_fact[k];

	    }
	    for (i=0; i < bpp; i++)
		p2[i] = sums[i]/gauss_sum;

        }
    }
    
    for ( y = 0; y < height; y++ ) 
    {
        for ( x = 0; x < width; x++ ) 
	{
	    p2 = destData + bpp * (y * width + x);
	    p3 = finalData + bpp * (y * width + x);
	    
	    
	    for (i=0; i < 5; i++)
		sums[i] = 0;
	    
	    for(k=0;k<radius;k++)
	    {
		if ((x -((radius-1)>>1)+k) < width)
		    p1 = srcData + bpp * ( y * width + (x -((radius-1)>>1)+k)); 
		else
		    p1 = srcData + bpp * (y * width + x);
		
		for (i = 0; i < bpp; i++)
		    sums[i] += p2[i]*gauss_fact[k];

	    }
	    for (i=0; i < bpp; i++)
		p3[i] = sums[i]/gauss_sum;
        }
    }
    
    
    [ret addRepresentation:finalRep];
    return [ret autorelease];
}
// This is supposed to be an edge detection algorithm, but it's functioning more as a posterize algorithm
// Not sure why...
// --------------------------------------------------------------------------------------------------------
//- (NSImage *)edgeDetect: (int)threshold
// --------------------------------------------------------------------------------------------------------
//{
//
//    int i, x, y;
//    
//    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
//    int width = [imageRep pixelsWide];
//    int height = [imageRep pixelsHigh];
//    
//    NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
//    
//    NSData *data = [[NSData alloc] initWithData:[self TIFFRepresentation]];
//    NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithData:data];
//
//    int bpp = [imageRep bitsPerPixel] / 8;
//    unsigned char *srcData = [imageRep bitmapData];
//    unsigned char *destData = [retRep bitmapData];
//    
//    unsigned char *p1, *p2;
//    
//    for ( y = 0; y < height; y++ ) 
//    {
//        for ( x = 0; x < width; x++ ) 
//	{
//	    int sums[5];
//	    int sums1[5];
//	    int sums2[5];
//	    int sqrts1 = 0.0;
//	    int sqrts2 = 0.0;
//		
//	    for (i = 0; i < 5; i++)
//	    {
//		sums[i] = 0.0;
//		sums1[i] = 0.0;
//		sums2[i] = 0.0;
//	    }
//	    
//	    p2 = destData + bpp * (y * width + x);
//	    for (i = 0; i < bpp; i++)
//	    {
//		p1 = srcData + bpp * (y * width + x); 
//		sums[i] = p1[i];
//		p1 = srcData + bpp * ((y+1) * width + x); 
//		sums2[i] = p1[i];
//		p1 = srcData + bpp * (y * width + (x+1)); 
//		
//		if((sqrt((r-r1)*(r-r1)+(g-g1)*(g-g1)+(b-b1)*(b-b1))>=bb)||
//		   (sqrt((r-r2)*(r-r2)+(g-g2)*(g-g2)+(b-b2)*(b-b2))>=bb)){
//		sqrts1 += (sums[i] - sums1[i]) * (sums[i] - sums1[i]);
//		sqrts2 += (sums[i] - sums2[i]) * (sums[i] - sums2[i]);
//	    }
//	    NSLog(@"test1: %f", sqrts1);
//	    NSLog(@"test2: %f", sqrts2);
//
//	    float test1 = sqrt(sqrts1);
//	    float test2 = sqrt(sqrts2);
//	    
//	   	    
//	    int thisPixel = ( (sqrt(sqrts1) >= threshold) || (sqrt(sqrts2) >= threshold)) ? 0 : 255;
//	    for (i = 0; i < bpp; i++)
//		p2[i] = thisPixel;
//	
//		
//	}
//    }
//    [ret addRepresentation:retRep];
//    return [ret autorelease];
//}

@end
