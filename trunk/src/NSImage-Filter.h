//
//  NSImage-Filter.h
//  MosaicTester
#import <Cocoa/Cocoa.h>

@interface NSImage(Filter)
- (NSImage *)adjustToInputLevelsLow:(int)low andHigh:(int)high;
- (NSImage *)grayscaleImage;
- (NSImage *)fastGaussianBlur: (int)pixels;
//- (NSImage *)edgeDetect: (int)threshold;
@end
