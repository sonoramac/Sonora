#import "_SNRMix.h"

@interface SNRMix : _SNRMix {}
@property (nonatomic, readonly) double duration;
@property (nonatomic, readonly) NSImage *artworkImage;
@property (nonatomic, readonly) NSImage *thumbnailArtworkImage;
- (void)setArtworkWithData:(NSData*)data cropped:(BOOL)cropped;
- (void)setArtworkWithProcessedLargeData:(NSData*)large thumbnailData:(NSData*)thumbnail;
- (void)removeArtwork;
- (void)recalculatePopularity;
@end
