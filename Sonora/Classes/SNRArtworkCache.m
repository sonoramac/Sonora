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

#import "SNRArtworkCache.h"
#import "SNRAlbum.h"
#import "SNRArtwork.h"
#import "SNRLastFMEngine.h"
#import "SNRArtist.h"

#import "SNRGraphicsHelpers.h"
#import "NSManagedObjectContext-SNRAdditions.h"

@interface SNRArtworkCache ()
- (void)createArtworkForObjectAndCallHandler:(id)object artworkSize:(NSSize)size;
- (void)downloadArtworkForObjectAndCallHandler:(id)object artworkSize:(NSSize)size;
@property (nonatomic, strong) NSManagedObjectContext *downloadContext;
@end

@implementation SNRArtworkCache {
    NSCache *_cachedArtwork;
    NSMutableDictionary *_handlerBlocks;
    
    dispatch_queue_t _backgroundQueue;
    NSManagedObjectContext *_downloadContext;
    NSMutableArray *_artworkQueue;
}
@synthesize downloadContext = _downloadContext;

#pragma mark - Initialization

- (id)init
{
    if ((self = [super init])) {
        _backgroundQueue = dispatch_queue_create("com.iktm.Sonora.artworkCache", DISPATCH_QUEUE_SERIAL);
        _cachedArtwork = [NSCache new];
        [_cachedArtwork setCountLimit:100];
        _handlerBlocks = [NSMutableDictionary dictionary];
        _artworkQueue = [NSMutableArray array];
        
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_backgroundQueue);
}

#pragma mark - Retrieving Cached Images

- (NSImage*)asynchronousCachedArtworkForObject:(id)object artworkSize:(NSSize)size asyncHandler:(void (^)(NSImage *image))handler;
{
    NSManagedObjectID *objectID = [object objectID];
    NSImage *artwork = [_cachedArtwork objectForKey:objectID];
    if (artwork) { return artwork; }
    if (handler) {
        NSMutableArray *blocks = [_handlerBlocks objectForKey:objectID] ?: [NSMutableArray array];
        [blocks addObject:[handler copy]];
        [_handlerBlocks setObject:blocks forKey:objectID];
    }
    if ([_artworkQueue containsObject:objectID]) { return nil; }
    [_artworkQueue addObject:objectID];
    if ([object artwork]) {
        [self createArtworkForObjectAndCallHandler:object artworkSize:size];
    } else if ([object isKindOfClass:[SNRAlbum class]] && ![[object valueForKey:@"didSearchForArtwork"] boolValue]) {
        [self downloadArtworkForObjectAndCallHandler:object artworkSize:size];
    } else {
        [_artworkQueue removeObject:objectID];
        [_handlerBlocks removeObjectForKey:objectID];
    }
    return nil;
}

- (NSImage*)synchronousCachedArtworkForObject:(id)object artworkSize:(NSSize)size
{
    NSManagedObjectID *objectID = [object objectID];
    NSImage *artwork = [_cachedArtwork objectForKey:objectID];
    if (artwork) { return artwork; }
    NSData *artworkData = [[object artwork] data];
    NSImage *jpegImage = [[self class] scaledArtworkWithData:artworkData artworkSize:size];
    [self setCachedArtwork:jpegImage forObject:object];
    [[object managedObjectContext] refreshObject:[object artwork] mergeChanges:NO];
    return jpegImage;
}

- (void)createArtworkForObjectAndCallHandler:(id)object artworkSize:(NSSize)size
{
    NSManagedObjectID *objectID = [object objectID];
    NSData *artworkData = [[object artwork] data];
    dispatch_async(_backgroundQueue, ^{
        NSImage *jpegImage = [[self class] scaledArtworkWithData:artworkData artworkSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setCachedArtwork:jpegImage forObject:object];
            [[object managedObjectContext] refreshObject:[object artwork] mergeChanges:NO];
            NSArray *handlers = [_handlerBlocks objectForKey:objectID];
            [_handlerBlocks removeObjectForKey:objectID];
            [_artworkQueue removeObject:objectID];
            if ([handlers count]) {
                for (void (^block)(NSImage *) in handlers) {
                    block(jpegImage);
                }
            }
        });
    });
}

- (void)downloadArtworkForObjectAndCallHandler:(id)object artworkSize:(NSSize)size
{
    __weak SNRArtworkCache *weakSelf = self;
    NSPersistentStoreCoordinator *coordinator = [SONORA_MANAGED_OBJECT_CONTEXT persistentStoreCoordinator];
    NSManagedObjectID *objectID = [object objectID];
    [[SNRLastFMEngine sharedInstance] artworkDataForAlbumWithName:[object name] artist:[[object artist] name] completionHandler:^(NSData *data, NSError *error) {
		dispatch_async(_backgroundQueue, ^{
            SNRArtworkCache *strongSelf = weakSelf;
			if (!strongSelf.downloadContext) {
                strongSelf.downloadContext = [[NSManagedObjectContext alloc] init];
                [strongSelf.downloadContext setPersistentStoreCoordinator:coordinator];
                [strongSelf.downloadContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                    [nc addObserver:self selector:@selector(backgroundContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:strongSelf.downloadContext];
                });
            }
			SNRAlbum *album = (SNRAlbum*)[strongSelf.downloadContext existingObjectWithID:objectID error:nil];
			if (!error)
                [album setDidSearchForArtwork:[NSNumber numberWithBool:YES]];
			if (data)
                [album setArtworkWithData:data cropped:YES];
			[strongSelf.downloadContext saveChanges];
			[strongSelf.downloadContext reset];
			dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    [self createArtworkForObjectAndCallHandler:object artworkSize:size];
                } else {
                    [_handlerBlocks removeObjectForKey:objectID];
                    [_artworkQueue removeObject:objectID];
                }
			});
		});
	}];
}

#pragma mark - Cache Management

- (void)setCachedArtwork:(NSImage*)artwork forObject:(id)object
{
    [_cachedArtwork setObject:artwork forKey:[object objectID]];
}

- (void)removeAllCachedArtwork
{
    [_cachedArtwork removeAllObjects];
}

- (void)removeCachedArtworkForObject:(id)object
{
    [_cachedArtwork removeObjectForKey:[object objectID]];
}

#pragma mark - Image Processing

+ (NSImage*)scaledArtworkWithData:(NSData*)data artworkSize:(NSSize)size
{
    CGFloat scale = SONORA_SCALE_FACTOR;
    size.width *= scale;
    size.height *= scale;
	CGImageRef cgImage = SNRCGImageWithJPEGData(data);
    CGSize imageSize = SNRCGImageGetSize(cgImage);
	CGContextRef ctx = SNRCGContextCreateWithSize(size);
	CGRect drawingRect = CGRectMake(0.f, 0.f, size.width, size.height);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
	CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    if (size.height != size.width) {
        CGFloat targetHeight = floor((size.height/size.width) * imageSize.width);
        CGRect cropRect = CGRectMake(0.f, floor(targetHeight/6.f), imageSize.width, targetHeight);
        CGImageRef cropped = CGImageCreateWithImageInRect(cgImage, cropRect);
        CGContextDrawImage(ctx, drawingRect, cropped);
        CGImageRelease(cropped);
    } else {
        CGContextDrawImage(ctx, drawingRect, cgImage);
    }
	CGImageRef scaledImage = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
    NSImage *image = [[NSImage alloc] initWithCGImage:scaledImage size:size];
    CGImageRelease(scaledImage);
    return image;
}

#pragma mark - Notifications

- (void)backgroundContextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
        [context mergeChangesFromContextDidSaveNotification:notification];
        [context saveChanges];
    });
}
@end
