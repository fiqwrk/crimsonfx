// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>

@interface NKDConvolutionKernel : NSObject 
{
		int	    dimension;	 
		short	    *kernel;
		int	    sum;
}
+ (id)gaussianBlur;
+ (id)colorEmbossFilter;
+ (id)softenFilter:(short)amount;
+ (id)outlineFilter;
+ (id)embossFilter;
+ (id)laplacianFilter;
+ (id)laplacianOfGaussianFilter;
+ (id)horizontalShiftFilter;
+ (id)blur;
+ (id)blurMore;
+ (id)blurCrazy;
+ (id)blurFilterOfSize:(short)inDim;
+ (id)sharpenFilter;
+ (id)sharpenMoreFilter;
+ (id)sharpenCrazyFilter;
+ (id)highPassSharpeningFilter:(short)amount;

- (id)initWithDimension:(int)inDim;
- (int)dimension;
- (void)setDimension:(int)newDimension;
- (short *)kernel;
- (void)setKernel:(short *)newKernel;
- (short)sum;
- (void)setSum:(short)newSum;
- (void)allocateKernelMemory;
- (void)calculateSum;
- (NSImage *)filter:(NSImage *)image;
- (NSImage *)filterUsingVImage: (NSImage *)image;
@end
