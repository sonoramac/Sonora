/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
