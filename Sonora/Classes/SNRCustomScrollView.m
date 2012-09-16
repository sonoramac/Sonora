//
//  SNRCustomScrollView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRCustomScrollView.h"

@implementation SNRCustomScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(redrawClipView) name:NSWindowDidBecomeMainNotification object:[self window]];
        [nc addObserver:self selector:@selector(redrawClipView) name:NSWindowDidResignMainNotification object:[self window]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)redrawClipView
{
    [[self contentView] setNeedsDisplay:YES];
}

- (NSView *)hitTest:(NSPoint)aPoint {
    NSEvent * currentEvent = [NSApp currentEvent];
    if([currentEvent type] == NSLeftMouseDown){
        // if we have a vertical scroller and it accepts the current hit
        if([self hasVerticalScroller] && [[self verticalScroller] hitTest:aPoint] != nil){
            [[self verticalScroller] mouseDown:currentEvent];
            return nil;
        }
        // if we have a horizontal scroller and it accepts the current hit
        if([self hasHorizontalScroller] && [[self horizontalScroller] hitTest:aPoint] != nil){
            [[self horizontalScroller] mouseDown:currentEvent];
            return nil;
        }
    }else if([currentEvent type] == NSLeftMouseUp){
        // if mouse up, just tell both our scrollers we have moused up
        if([self hasVerticalScroller]){
            [[self verticalScroller] mouseUp:currentEvent];
        }
        if([self hasHorizontalScroller]){
            [[self horizontalScroller] mouseUp:currentEvent];
        }
        return self;
    }
    
    return [super hitTest:aPoint];
}

@end
