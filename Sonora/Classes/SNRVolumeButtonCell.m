//
//  SNRVolumeButtonCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRVolumeButtonCell.h"
#import "NSUserDefaults-SNRAdditions.h"

static NSString* const kImage0 = @"volume";
static NSString* const kImage1 = @"<SNRVolumeButtonCell>1";
static NSString* const kImage2 = @"<SNRVolumeButtonCell>2";

@implementation SNRVolumeButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    float volume = [[NSUserDefaults standardUserDefaults] volume];
    BOOL volumeOverHalf = volume > 0.5f;
    CGFloat alpha1 = volumeOverHalf ? 1.0 : volume*2;
    CGFloat alpha2 = volumeOverHalf ? (volume - 0.5f)*2 : 0.0;
    NSImage *volume0 = [NSImage imageNamed:kImage0];
    BOOL flipped = [controlView isFlipped];
    [volume0 setFlipped:flipped];
    NSSize volumeSize = [volume0 size];
    NSRect volumeRect = NSMakeRect(floor(NSMidX(cellFrame) - (volumeSize.width / 2.f)), floor(NSMidY(cellFrame) - (volumeSize.height / 2.f)), volumeSize.width, volumeSize.height);
    [volume0 drawInRect:volumeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
    if (alpha1 > 0.0) {
        NSImage *volume1 = [NSImage imageNamed:kImage1];
        [volume1 setFlipped:flipped];
        [volume1 drawInRect:volumeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha1];
        if (alpha2 > 0.0) {
            NSImage *volume2 = [NSImage imageNamed:kImage2];
            [volume2 setFlipped:flipped];
            [volume2 drawInRect:volumeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha2];
        }
    }
}

@end

@implementation SNRVolumeButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.volume" options:0 context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay:YES];
}

- (void)dealloc
{
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.volume"];
}

@end
