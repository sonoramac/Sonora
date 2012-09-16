//
//  SNRGraphicsHelpers.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-23.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRGraphicsHelpers.h"

static CGColorSpaceRef _rgbColorSpace = NULL;

#pragma mark - Bitmap Contexts

CGColorSpaceRef SNRGetRGBColorSpace(void)
{
    if (!_rgbColorSpace) {
        _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return _rgbColorSpace;
}

CGContextRef SNRCGContextCreateWithSize(CGSize size) 
{
    return CGBitmapContextCreate(NULL, size.width, size.height, 8, 4 * size.width, SNRGetRGBColorSpace(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedLast);
}

#pragma mark - Images

CGImageRef SNRCGImageWithJPEGData(NSData *data)
{
    NSData *inMemoryData = [NSData dataWithBytes:[data bytes] length:[data length]];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)inMemoryData);
    CGImageRef cgImage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    return (CGImageRef)[(id)cgImage autorelease];
}

CGImageRef SNRCGImageWithName(NSString *name, BOOL cache) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForImageResource:name];
    if (!path) { return NULL; }
    NSDictionary *options = [NSDictionary dictionaryWithObject:cache ? (id)kCFBooleanTrue : (id)kCFBooleanFalse forKey:(NSString*)kCGImageSourceShouldCache];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], (CFDictionaryRef)options);
    if (imageSource == NULL) { return NULL; }
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)options);
    CFRelease(imageSource);
    return (CGImageRef)[(id)image autorelease];
}

CGSize SNRCGImageGetSize(CGImageRef image) {
    return CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
}

#pragma mark - Patterns

static void drawPatternImage(void *info, CGContextRef ctx)
{
    CGImageRef image = (CGImageRef)info;
    CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, CGImageGetWidth(image), CGImageGetHeight(image)), image);
}

static void releasePatternImage(void *info)
{
    CGImageRelease((CGImageRef)info);
}

CGColorRef SNRCGColorWithPatternImageName(NSString *name, BOOL cache) {
    CGImageRef image = CGImageRetain(SNRCGImageWithName(name, cache));
    if (image == NULL) { return NULL; }
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    static const CGPatternCallbacks callbacks = {0, &drawPatternImage, &releasePatternImage};
    CGPatternRef pattern = CGPatternCreate (image, CGRectMake(0.f, 0.f, width, height), CGAffineTransformMake (1, 0, 0, 1, 0, 0), width, height, kCGPatternTilingConstantSpacing, true, &callbacks);
    CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
    CGFloat components[1] = {1.0};
    CGColorRef color = CGColorCreateWithPattern(space, pattern, components);
    CGColorSpaceRelease(space);
    CGPatternRelease(pattern);
    return (CGColorRef)[(id)color autorelease];
}

CGPathRef SNRCGPathCreateWithRoundedRect(CGRect rect, CGFloat radius, SNRCGPathRoundedCorner corners)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
	if (corners & SNRCGPathRoundedCornerTopLeft) {
        CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height);
        CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height);
    }
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    if (corners & SNRCGPathRoundedCornerTopRight) {
        CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    }
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    if (corners & SNRCGPathRoundedCornerBottomRight) {
        CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y);
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y);
    }
    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    if (corners & SNRCGPathRoundedCornerBottomLeft) {
        CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y);
        CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    }
    CGPathCloseSubpath(path);
    return path;
}

void SNRCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat radius)
{
    CGPathRef path = SNRCGPathCreateWithRoundedRect(rect, radius, SNRCGPathRoundedCornerTopLeft | SNRCGPathRoundedCornerTopRight | SNRCGPathRoundedCornerBottomLeft | SNRCGPathRoundedCornerBottomRight);
    CGContextAddPath(context, path);
    CGPathRelease(path);
}

void SNRCGContextAddRoundedRectWithCorners(CGContextRef context, CGRect rect, CGFloat radius, SNRCGPathRoundedCorner corners)
{
    CGPathRef path = SNRCGPathCreateWithRoundedRect(rect, radius, corners);
    CGContextAddPath(context, path);
    CGPathRelease(path);
}