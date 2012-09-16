#import "_SNRSong.h"

@interface SNRSong : _SNRSong {}
@property (nonatomic, readonly) NSString *durationString;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *displayArtistName;
- (double)popularityForPlayCounts:(NSSet*)playCounts;
- (void)modifyPopularityByAddingPlayCounts:(NSSet*)playCounts;
- (void)modifyPopularityWithValue:(double)value;
- (void)addPlayCountObjectWithDate:(NSDate*)date;
- (BOOL)setBookmarkWithPath:(NSString*)path;
@end
