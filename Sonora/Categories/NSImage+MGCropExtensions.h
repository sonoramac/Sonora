//
//  NSImage+MGCropExtensions.h
//  ImageCropDemo
//
//  Created by Matt Gemmell on 16/03/2006.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (MGCropExtensions)

typedef enum {
    MGImageResizeCrop,
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale
} MGImageResizingMethod;

- (void)drawInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(float)delta method:(MGImageResizingMethod)resizeMethod;
- (NSImage *)imageToFitSize:(NSSize)size method:(MGImageResizingMethod)resizeMethod;
- (NSImage *)imageCroppedToFitSize:(NSSize)size;
- (NSImage *)imageScaledToFitSize:(NSSize)size;

@end
