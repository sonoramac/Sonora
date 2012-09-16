//
//  NSUserDefaults-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSUserDefaults (SNRAdditions)
@property (nonatomic, copy) NSString *lastFMUsername;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL scrobble;
@property (nonatomic, assign) BOOL synciTunesSongs;
@property (nonatomic, assign) BOOL synciTunesPlaylists;
@property (nonatomic, assign) BOOL growlNowPlaying;
@property (nonatomic, assign) BOOL growlNewImport;
@property (nonatomic, assign) BOOL copyMusic;
@property (nonatomic, assign) BOOL embedArtwork;
@property (nonatomic, assign) NSInteger sortMode;
@property (nonatomic, assign) NSInteger repeatMode;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, assign) BOOL firstImport;
@property (nonatomic, assign) BOOL firstMetadataiTunes;
@property (nonatomic, assign) BOOL useMemoryInputSource;
- (void)showFirstMetadataiTunesAlert;
@end
