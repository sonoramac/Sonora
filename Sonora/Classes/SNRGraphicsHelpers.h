//
//  SNRGraphicsHelpers.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-23.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

typedef enum {
    SNRCGPathRoundedCornerTopLeft = 1,
    SNRCGPathRoundedCornerTopRight = 1 << 1,
    SNRCGPathRoundedCornerBottomRight = 1 << 2,
    SNRCGPathRoundedCornerBottomLeft = 1 << 3
} SNRCGPathRoundedCorner;

#pragma mark - Bitmap Contexts
CGColorSpaceRef SNRGetRGBColorSpace(void);
CGContextRef SNRCGContextCreateWithSize(CGSize size);

#pragma mark - Images
CGImageRef SNRCGImageWithJPEGData(NSData *data);
CGImageRef SNRCGImageWithName(NSString *name, BOOL cache);
CGSize SNRCGImageGetSize(CGImageRef image);

#pragma mark - Patterns
CGColorRef SNRCGColorWithPatternImageName(NSString *name, BOOL cache);

#pragma mark - Paths
CGPathRef SNRCGPathCreateWithRoundedRect(CGRect rect, CGFloat radius, SNRCGPathRoundedCorner corners);
void SNRCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat radius);
void SNRCGContextAddRoundedRectWithCorners(CGContextRef context, CGRect rect, CGFloat radius, SNRCGPathRoundedCorner corners);
