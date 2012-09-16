#import "_SNRAlbum.h"

@interface SNRAlbum : _SNRAlbum {}
@property (nonatomic, readonly) double duration;
@property (nonatomic, readonly) NSImage *artworkImage;
@property (nonatomic, readonly) NSImage *thumbnailArtworkImage;
@property (nonatomic, readonly, getter=isCompilation) BOOL compilation;
- (void)setArtworkWithData:(NSData*)data cropped:(BOOL)cropped;
- (void)setArtworkWithProcessedLargeData:(NSData*)large thumbnailData:(NSData*)thumbnail;
+ (NSData*)artworkDataForImageData:(NSData*)data size:(CGSize)size cropped:(BOOL)cropped;
- (void)removeArtwork;
- (void)recalculatePopularity;
@end
