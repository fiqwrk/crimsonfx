//
//  NSBezierPath-Saber.h

#import <Cocoa/Cocoa.h>


@interface NSBezierPath(saber)
+ (NSBezierPath *)saberPathFromPoint:(NSPoint)start
			  startWidth:(float)finish
			     toPoint:(NSPoint)endPoint
			    endWidth:(float)endWidth
			  roundStart:(BOOL)roundStart
			 roundFinish:(BOOL)roundFinish
			   andEmitterBulb:(BOOL)isAura;

@end
