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

#import "SNRQueueViewCell.h"
#import "SNRQueueShineLayer.h"
#import "SNRQueueTextLayer.h"
#import "SNRQueuePlayLayer.h"

#import "CALayer+SNRAdditions.h"
#import "SNRGraphicsHelpers.h"
#import "NSString-SNRAdditions.h"

#define kQueueGridViewCellCornerRadius 4.f
#define kQueueGridViewCellTextLayerHeight 32.f
#define kQueueGridViewCellPlayButtonWidth 46.f
#define kQueueGridViewCellPlayButtonVerticalInset 7.f
#define kQueueGridViewCellShadowRadius 2.f
#define kQueueGridViewCellShadowOpacity 0.8f
#define kQueueGridViewCellShadowOffset CGSizeMake(0.f, 1.f)
#define kQueueGridViewCellNSShadowOffset NSMakeSize(0.f, -1.f)
#define kAnimationDuration 0.15f

static NSString* const kImageQueuePlaceholder = @"default-queue-artwork";

@interface SNRQueueViewCell ()
- (void)resetDurationString;
- (void)unbindAll;
@property (nonatomic, assign) NSTimeInterval hoverTime;
@end

@implementation SNRQueueViewCell  {
    OEGridLayer *_shadowLayer;
    OEGridLayer *_imageLayer;
    SNRQueueShineLayer *_shineLayer;
    SNRQueueTextLayer *_textLayer;
    SNRQueuePlayLayer *_playLayer;
    OEGridLayer *_highlightLayer;
}
@synthesize nowPlaying = _nowPlaying;
@synthesize totalTime = _totalTime;
@synthesize remainingTime = _remainingTime;
@synthesize hoverTime = _hoverTime;
@synthesize artistName = _artistName;
@synthesize representedObject = _representedObject;
@synthesize dimmed = _dimmed;
@synthesize queueController = _queueController;

- (id)init
{
    if ((self = [super init])) {
        _imageLayer = [OEGridLayer layer];
        _imageLayer.cornerRadius = kQueueGridViewCellCornerRadius;
        _imageLayer.masksToBounds = YES;
        _shadowLayer = [OEGridLayer layer];
        _shadowLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
        _shadowLayer.opaque = NO;
        _shadowLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _shadowLayer.shadowRadius = kQueueGridViewCellShadowRadius;
        _shadowLayer.shadowOpacity = kQueueGridViewCellShadowOpacity;
        _shadowLayer.shadowOffset = kQueueGridViewCellShadowOffset;
        _shadowLayer.cornerRadius = kQueueGridViewCellCornerRadius;
        _shadowLayer.shouldRasterize = YES;
        _shineLayer = [SNRQueueShineLayer layer];
        _textLayer = [SNRQueueTextLayer layer];
        __weak SNRQueueViewCell *weakSelf = self;
        [_textLayer setScrubbingBlock:^(SNRQueueTextLayer *layer) {
            SNRQueueViewCell *strongSelf = weakSelf;
            [strongSelf.queueController seekToTime:layer.doubleValue];
            strongSelf.hoverTime = layer.doubleValue;
        }];
        [_textLayer setHoverBlock:^(SNRQueueTextLayer *layer, double hoverValue) {
            SNRQueueViewCell *strongSelf = weakSelf;
            strongSelf.hoverTime = hoverValue;
        }];
        _playLayer = [SNRQueuePlayLayer layer];
        [_playLayer setMouseUpBlock:^(SNRQueuePlayLayer *layer) {
            [self.queueController playPause];
        }];
        _playLayer.hidden = YES;
        _highlightLayer = [OEGridLayer layer];
        _highlightLayer.cornerRadius = kQueueGridViewCellCornerRadius;
        _highlightLayer.opaque = NO;
        [self addSublayer:_shadowLayer];
        [self addSublayer:_imageLayer];
        [self addSublayer:_shineLayer];
        [self addSublayer:_textLayer];
        [self addSublayer:_playLayer];
        [self addSublayer:_highlightLayer];
        [self prepareForReuse];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    [_imageLayer setFrame:[self bounds]];
    [_shadowLayer setFrame:[self bounds]];
    [_shineLayer setFrame:[self bounds]];
    [_highlightLayer setFrame:[self bounds]];
    CGPathRef shadowPath = SNRCGPathCreateWithRoundedRect([_shadowLayer bounds], kQueueGridViewCellCornerRadius, SNRCGPathRoundedCornerBottomLeft | SNRCGPathRoundedCornerBottomRight | SNRCGPathRoundedCornerTopLeft | SNRCGPathRoundedCornerTopRight);
    [_shadowLayer setShadowPath:shadowPath];
    CGPathRelease(shadowPath);
    CGRect textRect = CGRectMake(0.f, CGRectGetMaxY([self bounds]) - kQueueGridViewCellTextLayerHeight, [self bounds].size.width, kQueueGridViewCellTextLayerHeight);
    [_textLayer setFrame:textRect];
    CGFloat maxPlayWidth = MIN(kQueueGridViewCellPlayButtonWidth, [self bounds].size.width);
    CGRect playRect = CGRectMake(floor(CGRectGetMidX([self bounds]) - (maxPlayWidth / 2.f)), floor((([self bounds].size.height - textRect.size.height) / 2.f) - (maxPlayWidth / 2.f) + kQueueGridViewCellPlayButtonVerticalInset), maxPlayWidth, maxPlayWidth);
    [_playLayer setFrame:playRect];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.songName = nil;
    self.artistName = nil;
    self.image = nil;
    self.totalTime = 0.0;
    self.dimmed = NO;
    self.playbackState = NO;
    self.queueController = nil;
    self.representedObject = nil;
    [self unbindAll];
    [self setNowPlaying:NO animated:NO];
}

- (void)dealloc
{
    [self unbindAll];
}

- (void)unbindAll
{
    [self unbind:@"artistName"];
    [self unbind:@"totalTime"];
    [self unbind:@"songName"];
}

#pragma mark - Accessors

- (NSString*)songName
{
    return _textLayer.songTextLayer.string;
}

- (void)setSongName:(NSString *)songName
{
    _textLayer.songTextLayer.string = songName;
}

- (void)setArtistName:(NSString *)artistName
{
    if (_artistName != artistName) {
        _artistName = artistName;
        _textLayer.artistTextLayer.string = artistName;
    }
}

- (NSImage*)image
{
    return _imageLayer.contents;
}

- (void)setImage:(NSImage *)image
{
    if (!image) { image = [NSImage imageNamed:kImageQueuePlaceholder]; }
    _imageLayer.contents = image;    
}

- (void)setNowPlaying:(BOOL)playing animated:(BOOL)animated
{
    if (_nowPlaying != playing) {
        _nowPlaying = playing;
        _playLayer.interactive = playing;
        _textLayer.interactive = playing;
        self.progressMaxValue = 0.0;
        self.progressDoubleValue = 0.0;
        self.remainingTime = 0.0;
        self.hoverTime = 0.0;
        if (animated) {
            if (_nowPlaying) {
                _playLayer.opacity = 0.f;
                _playLayer.hidden = NO;
                [_playLayer animateOpacityFrom:0.f toOpacity:1.f duration:kAnimationDuration timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                _playLayer.opacity = 1.f;
            } else {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    _playLayer.hidden = YES;
                }];
                [_playLayer animateOpacityFrom:1.f toOpacity:0.f duration:kAnimationDuration timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                _playLayer.opacity = 0.f;
                [CATransaction commit];
            }
        } else {
            _playLayer.opacity = 1.f;
            _playLayer.hidden = !_nowPlaying;
        }
    }
}

- (BOOL)playbackState
{
    return _playLayer.state;
}

- (void)setPlaybackState:(BOOL)playbackState
{
    _playLayer.state = playbackState;
}

- (double)progressDoubleValue
{
    return _textLayer.doubleValue;
}

- (void)setProgressDoubleValue:(double)progressDoubleValue
{
    if (_textLayer.tracking) { return; }
    _textLayer.doubleValue = progressDoubleValue;
}

- (double)progressMaxValue
{
    return _textLayer.maxValue;
}

- (void)setProgressMaxValue:(double)progressMaxValue
{
    if (_textLayer.tracking) { return; }
    _textLayer.maxValue = progressMaxValue;
}

- (void)setHoverTime:(NSTimeInterval)hoverTime
{
    if (_hoverTime != hoverTime) {
        _hoverTime = hoverTime;
        [self resetDurationString];
    }
}

- (void)setRemainingTime:(NSTimeInterval)remainingTime
{
    if (_remainingTime != remainingTime) {
        _remainingTime = remainingTime;
        [self resetDurationString];
    }
}

- (void)setTotalTime:(NSTimeInterval)totalTime
{
    if (_totalTime != totalTime) {
        _totalTime = totalTime;
        [self resetDurationString];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted && self.nowPlaying) { return; }
    [super setHighlighted:highlighted];
    if (highlighted) {
        CGColorRef backgroundColor = CGColorCreateGenericGray(0.f, 0.3f);
        _highlightLayer.backgroundColor = backgroundColor;
        CGColorRelease(backgroundColor);
    }
    _highlightLayer.hidden = !highlighted;
}

- (void)setDimmed:(BOOL)dimmed
{
    if (_dimmed != dimmed) {
        _dimmed = dimmed;
        if (dimmed) {
            CGColorRef backgroundColor = CGColorCreateGenericGray(0.78f, 0.4f);
            _highlightLayer.backgroundColor = backgroundColor;
            CGColorRelease(backgroundColor);
        }
        _highlightLayer.hidden = !dimmed;
    }
}

#pragma mark - Private

- (void)resetDurationString
{
    if (self.hoverTime) {
        _textLayer.artistTextLayer.string = [NSString timeStringForTimeInterval:self.hoverTime];
        _textLayer.durationTextLayer.string =[NSString stringWithFormat:@"-%@", [NSString timeStringForTimeInterval:self.totalTime - self.hoverTime]];
    } else if (self.nowPlaying) {
        _textLayer.durationTextLayer.string = [NSString stringWithFormat:@"-%@", [NSString timeStringForTimeInterval:self.remainingTime]];
        _textLayer.artistTextLayer.string = self.artistName;
    } else {
        _textLayer.durationTextLayer.string = [NSString timeStringForTimeInterval:self.totalTime];
        _textLayer.artistTextLayer.string = self.artistName;
    }
}
@end
