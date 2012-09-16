//
//  SNRAlbumGridViewCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-02.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumGridViewCell.h"
#import "SNRAlbumSelectionLayer.h"
#import "SNRAlbumPlayLayer.h"
#import "SNRAlbumTextLayer.h"
#import "SNRAlbumGenericLayer.h"
#import "SNRAlbumDropLayer.h"
#import "SNRAlbumEditLayer.h"
#import "SNRAlbum.h"
#import "SNRMix.h"
#import "SNRQueueCoordinator.h"

#import "CALayer+SNRAdditions.h"
#import "NSString-SNRAdditions.h"

#define kImageLayerShadowColor CGColorGetConstantColor(kCGColorBlack)
#define kImageLayerShadowOpacity 0.8f
#define kImageLayerShadowBlurRadius 2.f
#define kImageLayerShadowOffset CGSizeMake(0.f, 3.f)
#define kPlayLayerWidth 36.f
#define kAnimationDuration 0.25f

static NSString* const kImageLoading = @"dotted-border";
static NSString* const kFontMixes = @"Noteworthy Bold";
static NSString* const kFontAlbums = @"Lucida Grande Bold";

@interface SNRAlbumGridViewCell ()
- (void)_resetValueForKey:(NSString*)key;
@end

@implementation SNRAlbumGridViewCell {
    OEGridLayer *_imageLayer;
    SNRAlbumDropLayer *_dropLayer;
    SNRAlbumSelectionLayer *_selectionLayer;
    SNRAlbumPlayLayer *_playLayer;
    SNRAlbumEditLayer *_editLayer;
    SNRAlbumTextLayer *_textLayer;
    SNRAlbumGenericLayer *_genericLayer;
    NSData *_droppedArtworkData;
    NSData *_droppedImageData;
    NSDragOperation _currentDragOperation;
    BOOL _startedEnterAnimation;
    BOOL _artistNameBound;
    BOOL _isDisplayingMix;
}
@synthesize representedObject = _representedObject;
@synthesize displayGenericArtwork = _displayGenericArtwork;
@synthesize delegate = _delegate;
- (id)init
{
    if ((self = [super init])) {
        self.receivesHoverEvents = YES;
        _imageLayer = [OEGridLayer layer];
        _imageLayer.contentsGravity = kCAGravityResize;
        _selectionLayer = [SNRAlbumSelectionLayer layer];
        _playLayer = [SNRAlbumPlayLayer layer];
        _editLayer = [SNRAlbumEditLayer layer];
        __weak SNRAlbumGridViewCell *weakSelf = self;
        [_playLayer setMouseUpBlock:^(SNRAlbumButtonLayer *layer) {
            SNRAlbumGridViewCell *strongSelf = weakSelf;
            if (strongSelf.representedObject) {
                (([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask) ? [(SNRManagedObject*)strongSelf.representedObject shuffle] : [(SNRManagedObject*)strongSelf.representedObject play];
            }
        }];
        [_editLayer setMouseUpBlock:^(SNRAlbumButtonLayer *layer) {
            SNRAlbumGridViewCell *strongSelf = weakSelf;
            if (strongSelf.representedObject) {
                [SNR_QueueCoordinator showMixEditingQueueControllerForMix:strongSelf.representedObject];
            }
        }];
        _textLayer = [SNRAlbumTextLayer layer];
        _genericLayer = [SNRAlbumGenericLayer layer];
        _genericLayer.shadowColor = kImageLayerShadowColor;
        _genericLayer.shadowOpacity = kImageLayerShadowOpacity;
        _genericLayer.shadowRadius = kImageLayerShadowBlurRadius;
        _genericLayer.shadowOffset = kImageLayerShadowOffset;
        _genericLayer.opaque = YES;
        [self prepareForReuse];
        [self setImage:nil];
        [self addSublayer:_imageLayer];
        [self addSublayer:_genericLayer];
        [self addSublayer:_playLayer];
        [self addSublayer:_editLayer];
        [self addSublayer:_textLayer];
        [self addSublayer:_selectionLayer];
        
    }
    return self;
}

- (void)dealloc
{
    [self unbind:@"albumName"];
    [self unbind:@"artistName"];
    [self removeObserver:self forKeyPath:@"representedObject.songs"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"representedObject.songs"]) {
        [self _resetValueForKey:@"duration"];
    }
}

- (void)_resetValueForKey:(NSString*)key
{
    if ([key isEqualToString:@"duration"]) {
        self.albumDuration = (self.representedObject != nil) ? [NSString timeStringForTimeInterval:[(SNRAlbum*)_representedObject duration]] : nil;
    }
}

#pragma mark - Layers

- (void)layoutSublayers
{
    [super layoutSublayers];
    [_selectionLayer setFrame:self.bounds];
    CGFloat inset = [[self class] selectionInset];
    CGRect imageRect = CGRectInset(self.bounds, inset, inset);
    [_imageLayer setFrame:imageRect];
    [_genericLayer setFrame:imageRect];
    CGPathRef shadowPath = CGPathCreateWithRect([_imageLayer bounds], NULL);
    if (_imageLayer.shadowOpacity) {
        [_imageLayer setShadowPath:shadowPath];
    }
    [_genericLayer setShadowPath:shadowPath];
    CGPathRelease(shadowPath);
    CGRect playFrame = CGRectMake(imageRect.origin.x, CGRectGetMaxY(imageRect) - kPlayLayerWidth, kPlayLayerWidth, kPlayLayerWidth);
    [_playLayer setFrame:playFrame];
    CGRect textFrame = playFrame;
    textFrame.origin.x += playFrame.size.width;
    if (_isDisplayingMix) {
        textFrame.size.width = imageRect.size.width - (playFrame.size.width * 2.f);
        CGRect editFrame = playFrame;
        editFrame.origin.x = CGRectGetMaxX(textFrame);
        [_editLayer setFrame:editFrame];
    } else {
        textFrame.size.width = imageRect.size.width - playFrame.size.width;
    }
    [_textLayer setFrame:textFrame];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _imageLayer.hidden = NO;
    _selectionLayer.hidden = YES;
    _playLayer.hidden = YES;
    _editLayer.hidden = YES;
    _editLayer.hidden = YES;
    _textLayer.hidden = YES;
    _genericLayer.hidden = YES;
    [_dropLayer removeFromSuperlayer];
    _dropLayer = nil;
    self.representedObject = nil;
    self.albumName = nil;
    self.artistName = nil;
    self.displayGenericArtwork = NO;
    self.delegate = nil;
    self.image = nil;
    _isDisplayingMix = NO;
}

+ (CGFloat)selectionInset
{
    return 6.f;
}

#pragma mark - Accessors

- (void)setDisplayGenericArtwork:(BOOL)displayGenericArtwork
{
    if (_displayGenericArtwork != displayGenericArtwork) {
        _displayGenericArtwork = displayGenericArtwork;
        _imageLayer.hidden = _displayGenericArtwork;
        _genericLayer.hidden = !_displayGenericArtwork;
    }
}

- (void)setAlbumName:(NSString *)albumName
{
    _textLayer.albumTextLayer.string = albumName;
    _genericLayer.albumTextLayer.string = albumName;
}

- (NSString*)albumName
{
    return _textLayer.albumTextLayer.string;
}

- (void)setArtistName:(NSString *)artistName
{
    _textLayer.artistTextLayer.string = artistName;
    _genericLayer.artistTextLayer.string = artistName;
}

- (NSString*)artistName
{
    return _textLayer.artistTextLayer.string;
}

- (void)setAlbumDuration:(NSString *)duration
{
    _textLayer.durationTextLayer.string = duration;
}

- (NSString*)albumDuration
{
    return _textLayer.durationTextLayer.string;
}

- (void)setRepresentedObject:(id)representedObject
{
    if (_representedObject != representedObject) {
        [self unbind:@"artistName"];
        [self willChangeValueForKey:@"representedObject"];
        _representedObject = representedObject;
        [self didChangeValueForKey:@"representedObject"];
        _isDisplayingMix = [representedObject isKindOfClass:[SNRMix class]];
        _genericLayer.albumTextLayer.font = (__bridge CFTypeRef)[NSFont fontWithName:_isDisplayingMix ? kFontMixes : kFontAlbums size:16.f];
        
        if (_representedObject) {
            [self bind:@"albumName" toObject:self withKeyPath:@"representedObject.name" options:nil];
            [self addObserver:self forKeyPath:@"representedObject.songs" options:0 context:NULL];
            if ([_representedObject isKindOfClass:[SNRAlbum class]]) {
                [self bind:@"artistName" toObject:self withKeyPath:@"representedObject.artist.name" options:nil];
            }
        } else {
            [self unbind:@"albumName"];
            [self removeObserver:self forKeyPath:@"representedObject.songs"];
        }
        [self _resetValueForKey:@"duration"];
    }
}

- (void)setImage:(NSImage *)image
{
    self.displayGenericArtwork = NO;
    if (image) {
        [_imageLayer setContents:image];
        _imageLayer.shadowColor = kImageLayerShadowColor;
        _imageLayer.shadowOpacity = kImageLayerShadowOpacity;
        _imageLayer.shadowRadius = kImageLayerShadowBlurRadius;
        _imageLayer.shadowOffset = kImageLayerShadowOffset;
        _imageLayer.opaque = YES;
    } else {
        [_imageLayer setContents:[NSImage imageNamed:kImageLoading]];
        _imageLayer.shadowColor = nil;
        _imageLayer.shadowOpacity = 0.f;
        _imageLayer.shadowRadius = 0.f;
        _imageLayer.shadowOffset = CGSizeZero;
        _imageLayer.opaque = NO;
    }
}

- (NSImage*)image
{
    return _imageLayer.contents;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	_selectionLayer.hidden = !selected;
	[super setSelected:selected animated:animated];
}

#pragma mark - Mouse Events

- (void)mouseEnteredAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CGRect playStartingFrame = _playLayer.frame;
    playStartingFrame.origin.y += playStartingFrame.size.height;
    playStartingFrame.size.height = 0.f;
    CGRect playEndingFrame = _playLayer.frame;
    CGRect textStartingFrame = _textLayer.frame;
    textStartingFrame.origin.y += textStartingFrame.size.height;
    textStartingFrame.size.height = 0.f;
    CGRect textEndingFrame = _textLayer.frame;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        _startedEnterAnimation = NO;
    }];
    _startedEnterAnimation = YES;
    _playLayer.hidden = NO;
    _textLayer.hidden = NO;
    [_playLayer animateOpacityFrom:0.f toOpacity:1.f duration:kAnimationDuration timingFunction:timingFunction];
    [_textLayer animateOpacityFrom:0.f toOpacity:1.f duration:kAnimationDuration timingFunction:timingFunction];
    [_playLayer animateFromFrame:playStartingFrame toFrame:playEndingFrame duration:kAnimationDuration timingFunction:timingFunction];
    [_textLayer animateFromFrame:textStartingFrame toFrame:textEndingFrame duration:kAnimationDuration timingFunction:timingFunction];
    if (_isDisplayingMix) {
        _editLayer.hidden = NO;
        CGRect editStartingFrame = _editLayer.frame;
        editStartingFrame.origin.y += editStartingFrame.size.height;
        editStartingFrame.size.height = 0.f;
        CGRect editEndingFrame = _editLayer.frame;
        [_editLayer animateOpacityFrom:0.f toOpacity:1.f duration:kAnimationDuration timingFunction:timingFunction];
        [_editLayer animateFromFrame:editStartingFrame toFrame:editEndingFrame duration:kAnimationDuration timingFunction:timingFunction];
    }
    [CATransaction commit];
}

- (void)mouseExitedAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CGRect playFrame = _playLayer.frame;
    playFrame.origin.y += playFrame.size.height;
    playFrame.size.height = 0.f;
    CGRect textFrame = _textLayer.frame;
    textFrame.origin.y += textFrame.size.height;
    textFrame.size.height = 0.f;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (!_startedEnterAnimation) {
            _playLayer.hidden = YES;
            _textLayer.hidden = YES;
            if (_isDisplayingMix)
                _editLayer.hidden = YES;
            [self setNeedsLayout];
        }
        _playLayer.opacity = 1.f;
        _textLayer.opacity = 1.f;
        if (_isDisplayingMix)
            _editLayer.opacity = 1.f;
    }];
    [_playLayer animateOpacityFrom:1.f toOpacity:0.f duration:kAnimationDuration timingFunction:timingFunction];
    [_textLayer animateOpacityFrom:1.f toOpacity:0.f duration:kAnimationDuration timingFunction:timingFunction];
    [_playLayer animateFromFrame:_playLayer.frame toFrame:playFrame duration:kAnimationDuration timingFunction:timingFunction];
    [_textLayer animateFromFrame:_textLayer.frame toFrame:textFrame duration:kAnimationDuration timingFunction:timingFunction];
    _playLayer.frame = playFrame;
    _textLayer.frame = textFrame;
    _playLayer.opacity = 0.f;
    _textLayer.opacity = 0.f;
    if (_isDisplayingMix) {
        CGRect editFrame = _editLayer.frame;
        editFrame.origin.y += editFrame.size.height;
        editFrame.size.height = 0.f;
        [_editLayer animateOpacityFrom:1.f toOpacity:0.f duration:kAnimationDuration timingFunction:timingFunction];
        [_editLayer animateFromFrame:_editLayer.frame toFrame:editFrame duration:kAnimationDuration timingFunction:timingFunction];
        _editLayer.frame = editFrame;
        _editLayer.opacity = 0.f;
    }
    [CATransaction commit];
}

#pragma mark - Dragging

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([sender draggingSource]) { 
        return NSDragOperationNone; 
    } else if (_dropLayer) {
        return NSDragOperationCopy;
    }
	NSPasteboard *pboard = [sender draggingPasteboard];
	NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    if ([files count]) {
        NSString *imageFile = [files objectAtIndex:0];
        NSString *extension = [imageFile pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
        BOOL conforms = UTTypeConformsTo(fileUTI, kUTTypeImage);
        CFRelease(fileUTI);
        if (conforms) {
            _droppedImageData = [NSData dataWithContentsOfFile:imageFile];
        }
    } else {
        _droppedImageData = [pboard dataForType:NSTIFFPboardType];
    }
	if (_droppedImageData) {
        _dropLayer = [SNRAlbumDropLayer layer];
        _dropLayer.contentsGravity = kCAGravityResize;
        _dropLayer.shadowColor = kImageLayerShadowColor;
        _dropLayer.shadowOpacity = kImageLayerShadowOpacity;
        _dropLayer.shadowRadius = kImageLayerShadowBlurRadius;
        _dropLayer.shadowOffset = kImageLayerShadowOffset;
        _dropLayer.opaque = YES;
        _dropLayer.shouldRasterize = YES;
        _dropLayer.opacity = 0.f;
        _dropLayer.frame = _imageLayer.frame;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *artworkData = [SNRAlbum artworkDataForImageData:_droppedImageData size:CGSizeZero cropped:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                _droppedArtworkData = artworkData;
                _dropLayer.contents = [[NSImage alloc] initWithData:_droppedArtworkData];
                [self insertSublayer:_dropLayer above:_genericLayer];
                [_dropLayer animateOpacityFrom:0.f toOpacity:1.f duration:kAnimationDuration timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                _dropLayer.opacity = 1.f;
            });
        });
        _currentDragOperation = NSDragOperationCopy;
    } else {
        _currentDragOperation = NSDragOperationNone;
    }
    return _currentDragOperation;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    return _currentDragOperation;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    _currentDragOperation = NSDragOperationNone;
     _droppedArtworkData = nil;
    _droppedImageData = nil;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [_dropLayer removeFromSuperlayer];
        _dropLayer = nil;
    }];
    [_dropLayer animateOpacityFrom:1.f toOpacity:0.f duration:kAnimationDuration timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    _dropLayer.opacity = 0.f;
    [CATransaction commit];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    BOOL delegateCalled = NO;
    if ([self.delegate respondsToSelector:@selector(albumGridViewCell:acceptedArtworkImageData:originalImageData:)]) {
        [self.delegate albumGridViewCell:self acceptedArtworkImageData:_droppedArtworkData originalImageData:_droppedImageData];
        delegateCalled = YES;
    }
    [self draggingExited:sender];
    return delegateCalled;
}
@end
