//
//  NKDConvolutionKernel.m

// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------

#import "NKDConvolutionKernel.h"


@implementation NKDConvolutionKernel
// ----------------------------------------------------------------------------------------------
+ (id)gaussianBlur
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:5];
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = 1;
	k[1] = 4;
	k[2] = 7;
	k[3] = 4;
	k[4] = 1;
	
	k[5] = 4;
	k[6] = 16;
	k[7] = 26;
	k[8] = 16;
	k[9] = 4;
	
	k[10] = 7;
	k[11] = 26;
	k[12] = 41;
	k[13] = 26;
	k[14] = 7;
	
	k[15] = 4;
	k[16] = 16;
	k[17] = 26;
	k[18] = 16;
	k[19] = 4;
	
	k[20] = 1;
	k[21] = 4;
	k[22] = 7;
	k[23] = 4;
	k[24] = 1;
	
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+(id)colorEmbossFilter
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:3];
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = 1;
	k[1] = 0;
	k[2] = 1;
	
	k[3] = 0;
	k[4] = 0;
	k[5] = 0;
	
	k[6] = 1;
	k[7] = 0;
	k[8] = -2;
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+ (id)softenFilter:(short)amount
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:3];
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = amount;
	k[1] = amount;
	k[2] = amount;
	
	k[3] = amount;
	k[4] = 0;
	k[5] = amount;
	
	k[6] = amount;
	k[7] = amount;
	k[8] = amount;
    }
    [filter calculateSum];
    return [filter autorelease];
    
}
// ----------------------------------------------------------------------------------------------
+ (id)outlineFilter
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:7];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	// Convert these to shorthand 
	k[0] = 1;
	k[1] = 1;
	k[2] = 1;
	k[3] = 1;
	k[4] = 1;
	k[5] = 1;
	k[6] = 1;
	
	k[7] = 1;
	k[8] = 0;
	k[9] = 0;
	k[10] = 0;
	k[11] = 0;
	k[12] = 0;
	k[13] = 1;
	
	k[14] = 1;
	k[15] = 0;
	k[16] = 0;
	k[17] = 0;
	k[18] = 0;
	k[19] = 0;
	k[20] = 1;
	
	k[21] = 1;
	k[22] = 0;
	k[23] = 0;
	k[24] = -23;
	k[25] = 0;
	k[26] = 0;
	k[27] = 1;
	
	k[28] = 1;
	k[29] = 0;
	k[30] = 0;
	k[31] = 0;
	k[32] = 0;
	k[33] = 0;
	k[34] = 1;
	
	k[35] = 1;
	k[36] = 0;
	k[37] = 0;
	k[38] = 0;
	k[39] = 0;
	k[40] = 0;
	k[41] = 1;
	
	k[42] = 1;
	k[43] = 1;
	k[44] = 1;
	k[45] = 1;
	k[46] = 1;
	k[47] = 1;
	k[48] = 1;
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+ (id)embossFilter
// ----------------------------------------------------------------------------------------------
{
    /*
     embossFilter = [[4,3,2,0,0],[3,2,1,0,0],[2,1,18,-1,-2],[0,0,-1,-2,-3],[0,0,-2,-3,-4]]
     */
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:5];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = 4;
	k[1] = 3;
	k[2] = 2;
	k[3] = 0;
	k[4] = 0;
	
	k[5] = 3;
	k[6] = 2;
	k[7] = 1;
	k[8] = 0;
	k[9] = 0;
	
	k[10] = 2;
	k[11] = 1;
	k[12] = 18;
	k[13] = -1;
	k[14] = -2;
	
	k[15] = 0;
	k[16] = 0;
	k[17] = -1;
	k[18] = -2;
	k[19] = -3;
	
	k[20] = 0;
	k[21] = 0;
	k[22] = -2;
	k[23] = -3;
	k[24] = -4;
	
	
	
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+ (id)laplacianFilter
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:3];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = -1;
	k[1] = -1;
	k[2] = -1;
	
	k[3] = -1;
	k[4] = 8;
	k[5] = -1;
	
	k[6] = -1;
	k[7] = -1;
	k[8] = -1;
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+ (id)laplacianOfGaussianFilter
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:5];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	
	k[0] = 0;
	k[1] = 0;
	k[2] = 1;
	k[3] = 0;
	k[4] = 0;
	
	k[5] = 0;
	k[6] = 1;
	k[7] = 2;
	k[8] = 1;
	k[9] = 0;
	
	k[10] = 1;
	k[11] = 2;
	k[12] = -16;
	k[13] = 2;
	k[14] = 1;
	
	k[15] = 0;
	k[16] = 1;
	k[17] = 2;
	k[18] = 1;
	k[19] = 0;
	
	k[20] = 0;
	k[21] = 0;
	k[22] = 1;
	k[23] = 0;
	k[24] = 0;
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
+ (id)horizontalShiftFilter
// ----------------------------------------------------------------------------------------------
{
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:3];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = 0;
	k[1] = 0;
	k[2] = 0;
	
	k[3] = -1;
	k[4] = 1;
	k[5] = 0;
	
	k[6] = 0;
	k[7] = 0;
	k[8] = 0;
    }
    [filter calculateSum];
    return [filter autorelease];
    
}
// ----------------------------------------------------------------------------------------------
+ (id)blur
// ----------------------------------------------------------------------------------------------
{
    return [NKDConvolutionKernel blurFilterOfSize:3];
}
// ----------------------------------------------------------------------------------------------
+ (id)blurMore
// ----------------------------------------------------------------------------------------------
{
    return [NKDConvolutionKernel blurFilterOfSize:7];
}
// ----------------------------------------------------------------------------------------------
+ (id)blurCrazy
// ----------------------------------------------------------------------------------------------
{
    return [NKDConvolutionKernel blurFilterOfSize:11];
}
// Due to limitations caused by using single-byte datatypes, an 11 by 11 blue is about the largest
// that will work correctly.
// ----------------------------------------------------------------------------------------------
+ (id)blurFilterOfSize:(short)inDim
// ----------------------------------------------------------------------------------------------
{
    short i;
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:inDim];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	for (i=0; i < [filter dimension] * [filter dimension]; i++)
	    k[i] = 1;
    }
    [filter calculateSum];
    return [filter autorelease];
    
}
// ----------------------------------------------------------------------------------------------
+ (id)sharpenFilter
// ----------------------------------------------------------------------------------------------
{
    return [NKDConvolutionKernel highPassSharpeningFilter:9];
}
// ----------------------------------------------------------------------------------------------
+ (id)sharpenMoreFilter
// ----------------------------------------------------------------------------------------------
{
     return [NKDConvolutionKernel highPassSharpeningFilter:7];
}
// ----------------------------------------------------------------------------------------------
+ (id)sharpenCrazyFilter
// ----------------------------------------------------------------------------------------------
{
     return [NKDConvolutionKernel highPassSharpeningFilter:5];
}
// In general, this method probably shouldn't be used directly. 
// Amount of 5 is super sharp, 9 is somewhat sharp, smaller than 5 is bad, larger than 11 will produce too small a difference to matter
// ----------------------------------------------------------------------------------------------
+ (id)highPassSharpeningFilter:(short)amount
// ----------------------------------------------------------------------------------------------
{
    int i;
    if (amount > 255)
	amount = 255;
    if (amount < 0)
	amount = 0;
    
    id filter = [[NKDConvolutionKernel alloc] initWithDimension:3];
    
    if (filter != nil)
    {
	short *k = [filter kernel];
	k[0] = 0;
	k[1] = -1;
	k[2] = 0;
	
	k[3] = -1;
	k[4] = amount;
	k[5] = -1;
	
	k[6] = 0;
	k[7] = -1;
	k[8] = 0;
    }
    [filter calculateSum];
    return [filter autorelease];
}
// ----------------------------------------------------------------------------------------------
- (id)initWithDimension:(int)inDim
// ----------------------------------------------------------------------------------------------
{
    if (self = [super init])
    {
	// Must be odd dimension
	if (inDim%2==0)
	    return nil;
	
	[self setDimension:inDim];
	[self allocateKernelMemory];
	
    }
    return self;
}
#pragma mark -
// ----------------------------------------------------------------------------------------------
- (int)dimension
// ----------------------------------------------------------------------------------------------
{
    return dimension;
}
// ----------------------------------------------------------------------------------------------
- (void)setDimension:(int)newDimension
// ----------------------------------------------------------------------------------------------
{
    dimension = newDimension;
}
// ----------------------------------------------------------------------------------------------
- (short *)kernel
// ----------------------------------------------------------------------------------------------
{
    return kernel;
}
// ----------------------------------------------------------------------------------------------
- (void)setKernel:(short *)newKernel
// ----------------------------------------------------------------------------------------------
{
    if (kernel != nil)
	free(kernel);
    kernel = newKernel;
}
// ----------------------------------------------------------------------------------------------
- (short)sum
// ----------------------------------------------------------------------------------------------
{
    return sum;
}
// ----------------------------------------------------------------------------------------------
- (void)setSum:(short)newSum
// ----------------------------------------------------------------------------------------------
{
    sum = newSum;
}
#pragma mark -
// ----------------------------------------------------------------------------------------------
- (void)allocateKernelMemory
// ----------------------------------------------------------------------------------------------
{
    short *p = malloc( ([self dimension] * sizeof(short)) * ([self dimension] * sizeof(short)));
    [self setKernel:p];
}
// ----------------------------------------------------------------------------------------------
- (void)calculateSum
// ----------------------------------------------------------------------------------------------
{
    short i;
    short ret = 0;
    short *k = [self kernel];
    for (i=0; i < [self dimension] * [self dimension]; i++)
	ret += k[i];
    [self setSum:ret];
}
#pragma mark -
// ----------------------------------------------------------------------------------------------
- (NSImage *)filterUsingVImage: (NSImage *)image
// ----------------------------------------------------------------------------------------------
{  
    int i; 
    NSArray *array = [image representations];
    int count = [array count];
    NSBitmapImageRep *input = nil;
    for (i = 0; i < count; i++)
    {
	NSImageRep *tempImage = [array objectAtIndex:i];
	if ([tempImage isMemberOfClass: [NSBitmapImageRep class]])
	{
	    input = (NSBitmapImageRep*)tempImage;
	    break;
	}
    }
    if (input == nil)
	input = [[NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]] retain];
    
    
    NSSize		size = [ input size ];
    int 		inBytesPerRow = [ input bytesPerRow ];
    int			bitsPerChannel = [ input bitsPerPixel ];
    int			data_size;
    unsigned char 	*targetIn, *targetOut, *src;
    int			j, k, loopCount;
    void		*origIn, *origOut;
    
    BOOL hasAlpha = [ input hasAlpha ];
    
    int bufferCount = 1;
    int channelCount = [input samplesPerPixel];
    int height = size.height;
    int width = size.width;
    int bytesPerRow = width * 4 * sizeof( uint8_t);
    
    //Prevent bytesPerRow from becomming a power of 2
    if( 0 == ( bytesPerRow & (bytesPerRow - 1 ) ) )
        bytesPerRow += 128;
    
    data_size = height * bytesPerRow;
    
    targetIn = origIn = malloc( data_size );
    targetOut = origOut = malloc( data_size );
    loopCount = channelCount;
    
    if( [ input isPlanar ] || channelCount == 1 )
    {
        unsigned char	*inData[5];
	
        if( bitsPerChannel != 8 )
	{
	    free(origIn);
	    free(origOut);
            return nil;
	}
        [input getBitmapDataPlanes: inData];
        
        //Init the alpha channel
        if( [ input hasAlpha ] )
        {
            src = inData[ channelCount - 1 ];
            for( j = 0; j < height; j++ )
            {
                for( i = 0; i < width; i++ )
                {
                    targetIn[0] = targetOut[0] = src[i];
                    targetIn += 4;
                    targetOut += 4;
                }
                src = (uint8_t*)((char*) src + inBytesPerRow);
            }
            
            loopCount--;
        }
        else
        {
            for( j = 0; j < height; j++ )
            {
                for( i = 0; i < width; i++ )
                {
                    targetIn[0] = targetOut[0] = 0xFF;
                    targetIn += 4;
                    targetOut += 4;
                }
            }            
        }
	
        targetIn = origIn + 1;
        targetOut = origOut + 1;
        
        for( i = 0; i < loopCount; i++ )
        {
            uint8_t *dest1 = targetIn;
            uint8_t *dest2 = targetOut;
            
            src = inData[ i ];
            
            for( j = 0; j < height; j++ )
            {
                for( k = 0; k < width; k++ )
                {
                    dest1[0] = dest2[0] = src[k];
                    dest1 += 4;
                    dest2 += 4;
                }
		
                src = (uint8_t*)((char*) src + inBytesPerRow);
            }
            targetIn++;
            targetOut++;
        }
    }
    else
    {
        unsigned char *data = [ input bitmapData ];
        
        if( hasAlpha )
        {
            src = data;
            for( j = 0; j < height; j++ )
            {
                uint8_t *localSrc = src;
                for( i = 0; i < width; i++ )
                {
                    targetIn[0] = targetOut[0] = localSrc[0];
                    targetIn += 4;
                    targetOut += 4;
                    localSrc += channelCount;
                }
                src = (uint8_t*)((char*) src + inBytesPerRow);
            }
            
            loopCount--;
            data++;
        }
        else
        {
            for( j = 0; j < height; j++ )
            {
                for( i = 0; i < width; i++ )
                {
                    targetIn[0] = targetOut[0] = 0xFF;
                    targetIn += 4;
                    targetOut += 4;
                }
            }            
        }
	
        bitsPerChannel /= channelCount;
        targetIn = origIn + 1;
        targetOut = origOut + 1;
        
        if( loopCount > 3 )
            loopCount = 3;
        
        for( i = 0; i < loopCount; i++ )
        {
            uint8_t *dest1 = targetIn;
            uint8_t *dest2 = targetOut;
            
            src = data;
            
            for( j = 0; j < height; j++ )
            {
                uint8_t *localSrc = src; 
                uint8_t *localDest1 = dest1;
                uint8_t *localDest2 = dest2;
                
                for( k = 0; k < width; k++ )
                {
                    localDest1[0] = localDest2[0] = localSrc[0];
                    localDest1 += 4;
                    localDest2 += 4;
                    localSrc += channelCount;
                }
		
                src = (uint8_t*)((char*) src + inBytesPerRow);
                dest1 = (uint8_t*)((char*) dest1 + bytesPerRow );
                dest2 = (uint8_t*)((char*) dest2 + bytesPerRow );
            }
            targetIn++;
            targetOut++;
            data++;
        }
    }    
    
    
    unsigned char	    edgeFill[4] = { 0, 0, 0, 0 };
    vImage_Error	    err;
    vImage_Buffer	    srcBuffer = { origIn, height, width, bytesPerRow };
    vImage_Buffer	    dest = { origOut, height, width, bytesPerRow };
    
    
    err = vImageConvolve_ARGB8888(	&srcBuffer, 
                                        &dest,	
                                        NULL,
                                        0,	
                                        0,	
                                        [self kernel],	 
                                        [self dimension], 	
                                        [self dimension],	
                                        [self sum],	
                                        edgeFill,
                                        kvImageCopyInPlace
					);
    
    /*
     vImage_Error vImageConvolve_ARGB8888 ( 
					    const vImage_Buffer *src, 
					    const vImage_Buffer *dest, 
					    void *tempBuffer, 
					    unsigned int srcOffsetToROI_X, 
					    unsigned int srcOffsetToROI_Y,  
					    short *kernel, 
					    unsigned int kernel_height, 
					    unsigned int kernel_width, 
					    int divisor, 
					    Pixel_8888 backgroundColor, 
					    vImage_Flags flags 
					    );
     
     */

    NSBitmapImageRep *result = [input copy];
    
    
    int 		outBytesPerRow = [ result bytesPerRow ];
    int 		writeChannelCount = channelCount;
    int 		the_height = size.height;
    int 		the_width = size.width;
    int 		samplesPerPixel = [result samplesPerPixel ];
    
    if( height < the_height )
        the_height = height;
    
    if( width < the_width )
        the_width = width;
    
    if( hasAlpha == YES )
        writeChannelCount--;
    
    if( [ result isPlanar ] || channelCount == 1 )
    {
        unsigned char	*outData[5];
	
        [result getBitmapDataPlanes: outData ];
        
        for( i = 0; i < writeChannelCount; i++ )
        {
            int index = (i + 1) & 3; //rotate alpha to last
            unsigned char *src = origOut + index;
            unsigned char *dest = outData[i];
            int j, k;
	    
            if( i == samplesPerPixel - 1 && [ result hasAlpha ] )
                src = origOut;
            
	    
            for( j = 0; j < the_height; j++ )
            {
                dest = (uint8_t*)( (char*) outData[i] + j * outBytesPerRow );
                for( k = 0; k < the_width; k++ )
                    dest[k] = src[ k * 4 ];
                src += 4 * the_width;
            }
        }
    }
    else
    {
        unsigned char *data = [result bitmapData];
        unsigned char *src = origOut;
        int i = 0;
        int j,k;
        unsigned char *target;
        
        if( [result hasAlpha] )
        {
            target = data;
	    
            for( j = 0; j < the_height; j++ )
            {
                for( k = 0; k < the_width; k++ )
                    target[ samplesPerPixel * k ] = src[ 4 * k ];
		
                target = (uint8_t*)((char*) target + outBytesPerRow );
                src += 4 * the_width;
            }
	    
            i++;
            data++;
        }
	
        src = origOut + 1;
        
        for( ; i < writeChannelCount; i++ )
        {
            uint8_t *localSrc = src;
            target = data;
            
            for( j = 0; j < the_height; j++ )
            {
                for( k = 0; k < the_width; k++ )
                    target[ samplesPerPixel * k ] = localSrc[ k * 4 ];
                
                target = (uint8_t*)((char*) target + outBytesPerRow );
                localSrc = (uint8_t*) ((char*) localSrc + bytesPerRow );
            }
            
            src++;
            data++;
        }
    }
    
    NSImage *ret = [[NSImage alloc] initWithSize:size];
    [ret addRepresentation:result];
    [result release];
    free(origIn);
    free(origOut);
    return [ret autorelease];
}

// ----------------------------------------------------------------------------------------------
- (NSImage *)filter:(NSImage *)image
// ----------------------------------------------------------------------------------------------
{
    
    int i,ix,iy,kx,ky;	    // Generic loop, image-x, image-y, kernel-x, kernel-y

    NSArray *array = [image representations];
    int count = [array count];
    NSBitmapImageRep *imageRep = nil;
    for (i = 0; i < count; i++)
    {
	NSImageRep *tempImage = [array objectAtIndex:i];
	if ([tempImage isMemberOfClass: [NSBitmapImageRep class]])
	{
	    imageRep = (NSBitmapImageRep*)tempImage;
	    break;
	}
    }
    if (imageRep == nil)
	imageRep = [[NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]] retain];

    
    int width = [imageRep pixelsWide];
    int height = [imageRep pixelsHigh];
    int rowbytes = [imageRep bytesPerRow];
    
  
    
     NSImage *ret = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
     
     NSMutableData *data = [[NSData alloc] initWithData:[image TIFFRepresentation]];
     NSBitmapImageRep *retRep = [[NSBitmapImageRep alloc] initWithData:data];


    int bpp = [imageRep bitsPerPixel] / 8;
    unsigned char *srcData = [imageRep bitmapData];
    unsigned char *destData = [retRep bitmapData];
    
    unsigned char *p1, *p2;
    short *k = [self kernel];
    
    // Loop through the image raster
    for ( iy = 0; iy < height; iy++ ) 
    {
	srcData = [imageRep bitmapData];
	destData = [retRep bitmapData];
	
        for ( ix = 0; ix < width; ix++ ) 
	{
	    // Create an initialize array to hold sums for each channel
	    int sums[bpp];
	    for (i=0; i < bpp; i++)
		sums[i] = 0;
	    
	    // Find pointer to destination pixel data
	    p2 = destData + bpp * (iy * width + ix);
	    
	    // Loop through the kernel matrix
	    for (ky = 0; ky < [self dimension]; ky++)
	    {
		for (kx = 0; kx < [self dimension]; kx++)
		{
		    // Find image pixel corresponding to kernel element
		    int ly = iy + ( ky - (([self dimension]-1)/2));
		    int lx = ix + (kx - (([self dimension]-1)/2));
		    
		    
		    // Boundaries checking (edge row repeat)
		    if (ly < 0)
			ly = 0;
		    if (lx < 0)
			lx = 0;
		    if (ly >= height)
			ly = height-1;
		    if (lx >= width)
			lx = width-1;
		    
		    // Find pointer to pixel correponding to current kernel element
		    p1 = srcData + bpp * (ly * width + lx);

		    // Loop through channels of pixel
		    //sums[i] += p1[i]*gauss_fact[k];
		    for (i=0; i < bpp; i++)
			sums[i] += p1[i]*k[ky*[self dimension] + kx];

		}
	    } // End kernel loops
	
	    // Loop through channel sums
	    for (i=0; i < bpp; i++)
	    {
		int tmp;
		
		if ([self sum] != 0)
		    tmp = sums[i] / [self sum];
		else
		    tmp = sums[i];
		
		if (tmp > 255)
		   tmp = 255;
		if (tmp < 0)
		    tmp = 0;
		
		p2[i] = tmp;

	    }
	}
    } // End image loops
    [imageRep release];
    [ret addRepresentation:retRep];
    return [ret autorelease];

    return nil;
}

// ----------------------------------------------------------------------------------------------
- (void) dealloc
// ----------------------------------------------------------------------------------------------
{
    if ([self kernel] != nil)
	free(kernel);
    [super dealloc];
}
@end
