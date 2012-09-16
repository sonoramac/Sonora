//
//  SNRProgressIndicator.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-15.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

#import "SNRProgressIndicator.h"

#define kTrackCornerRadius 3.f
#define kTrackHighlightColor [NSColor colorWithCalibratedWhite:1.f alpha:0.3f]
#define kTrackGradientStartingColor [NSColor colorWithDeviceRed:0.847f green:0.847f blue:0.847f alpha:1.f]
#define kTrackGradientEndingColor [NSColor colorWithDeviceRed:0.792f green:0.792f blue:0.792f alpha:1.f]
#define kTrackBorderColor [NSColor colorWithDeviceRed:0.522f green:0.522f blue:0.522f alpha:1.f]
#define kTrackShadowColor [NSColor colorWithCalibratedWhite:0.f alpha:0.15f]
#define kTrackShadowBlurRadius 1.f
#define kTrackShadowOffset NSMakeSize(0.f, -1.f)

#define kFillHighlightColor [NSColor colorWithCalibratedWhite:1.f alpha:0.4f]
#define kFillGradientTopStartingColor [NSColor colorWithDeviceRed:0.431f green:0.761f blue:0.961f alpha:1.f]
#define kFillGradientTopEndingColor [NSColor colorWithDeviceRed:0.667f green:0.843f blue:1.f alpha:1.f]
#define kFillGradientBottomStartingColor [NSColor colorWithDeviceRed:0.404f green:0.765f blue:0.969f alpha:1.f]
#define kFillGradientBottomEndingColor [NSColor colorWithDeviceRed:0.345f green:0.675f blue:0.902f alpha:1.f]

static NSString* const kImageLeft = @"<SNRProgressIndicator>left";
static NSString* const kImageMidEmpty = @"<SNRProgressIndicator>mid-empty";
static NSString* const kImageMidFull = @"<SNRProgressIndicator>mid-full";
static NSString* const kImageRight = @"<SNRProgressIndicator>right";

@implementation SNRProgressIndicator
@synthesize maxValue = sMaxValue;
@synthesize doubleValue = sDoubleValue;

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.maxValue = 1.f;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect drawingRect = [self bounds];
    /* Draw the background path that will create the highlight at the bottom */
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:kTrackCornerRadius yRadius:kTrackCornerRadius];
    [kTrackHighlightColor set];
    [path fill];
    /* Move the rectangle upwards to draw the main track border */
    drawingRect.origin.y++;
    drawingRect.size.height--;
    path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:kTrackCornerRadius yRadius:kTrackCornerRadius];
    /* Draw the track gradient fill */
    NSGradient *trackGradient = [[NSGradient alloc] initWithStartingColor:kTrackGradientStartingColor endingColor:kTrackGradientEndingColor];
    [trackGradient drawInBezierPath:path angle:90.f];
    NSShadow *trackShadow = [[NSShadow alloc] init];
    [trackShadow setShadowBlurRadius:kTrackShadowBlurRadius];
    [trackShadow setShadowOffset:kTrackShadowOffset];
    [trackShadow setShadowColor:kTrackShadowColor];
    /* Clip to the drawing path, set the inner shadow, and draw the border */
    [path addClip];
    [NSGraphicsContext saveGraphicsState];
    CGFloat lineWidth = 2.f;
    [path setLineWidth:lineWidth];
    [trackShadow set];
    [kTrackBorderColor set];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
    /* Now draw the actual blue fill */
    CGFloat progressLength = round((self.doubleValue / self.maxValue) * drawingRect.size.width);
    NSGradient *topFill = [[NSGradient alloc] initWithStartingColor:kFillGradientTopStartingColor endingColor:kFillGradientTopEndingColor];
    NSGradient *bottomFill = [[NSGradient alloc] initWithStartingColor:kFillGradientBottomStartingColor endingColor:kFillGradientBottomEndingColor];
    NSRect bottomRect = NSMakeRect(drawingRect.origin.x, drawingRect.origin.y, progressLength, round(drawingRect.size.height * 0.5f));
    NSRect topRect = bottomRect;
    topRect.origin.y += topRect.size.height;
    [topFill drawInRect:topRect angle:90.f];
    [bottomFill drawInRect:bottomRect angle:90.f];
    /* Draw the border a second time, over the fill */
    [kTrackBorderColor set];
    [path stroke];
    /* Draw the highlight lines */
    [kFillHighlightColor set];
    NSRect topHighlight = NSMakeRect(drawingRect.origin.x + lineWidth, NSMaxY(drawingRect) - lineWidth, progressLength - lineWidth, 1);
    NSRect rightHighlight = NSMakeRect(NSMaxX(bottomRect) - 1.f, lineWidth, 1.f, drawingRect.size.height - lineWidth);
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRect:topHighlight];
    [highlightPath fill];
    highlightPath = [NSBezierPath bezierPathWithRect:rightHighlight];
    [highlightPath fill];
    /* Draw the border line */
    [kTrackBorderColor set];
    NSRect borderRect = rightHighlight;
    borderRect.origin.x++;
    NSRectFill(borderRect);
}

- (void)incrementBy:(double)increment
{
    self.doubleValue += increment;
    [self setNeedsDisplay:YES];
}

- (void)setDoubleValue:(double)doubleValue
{
    sDoubleValue = doubleValue;
    [self setNeedsDisplay:YES];
}

- (void)setMaxValue:(double)maxValue
{
    sMaxValue = maxValue;
    [self setNeedsDisplay:YES];
}
@end
