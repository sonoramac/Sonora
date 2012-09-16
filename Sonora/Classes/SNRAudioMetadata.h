//
//  SNRAudioMetadata.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-05.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

struct AudioMetadata;
typedef struct AudioMetadata AudioMetadata;

@interface SNRAudioMetadata : NSObject
- (id)initWithFileAtURL:(NSURL*)url;
+ (NSArray*)supportedFileExtensions;
+ (NSArray*)supportedMIMETypes;
+ (NSArray*)supportedUTIs;
+ (BOOL)handlesFilesWithExtension:(NSString*)extension;
+ (BOOL)handlesMIMEType:(NSString*)mimeType;

- (BOOL)readMetadata;
- (BOOL)writeMetadata;
- (BOOL)hasUnsavedChanges;
- (void)revertUnsavedChanges;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *formatName;
@property (nonatomic, readonly) NSNumber *totalFrames;
@property (nonatomic, readonly) NSNumber *channelsPerFrame;
@property (nonatomic, readonly) NSNumber *bitsPerChannel;
@property (nonatomic, readonly) NSNumber *sampleRate;
@property (nonatomic, readonly) NSNumber *duration;
@property (nonatomic, readonly) NSNumber *bitrate;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *albumTitle;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *albumArtist;
@property (nonatomic, retain) NSString *genre;
@property (nonatomic, retain) NSString *composer;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSNumber *compilation;
@property (nonatomic, retain) NSNumber *trackNumber;
@property (nonatomic, retain) NSNumber *trackTotal;
@property (nonatomic, retain) NSNumber *discNumber;
@property (nonatomic, retain) NSNumber *discTotal;
@property (nonatomic, retain) NSString *lyrics;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSString *MCN;
@property (nonatomic, retain) NSString *ISRC;
@property (nonatomic, retain) NSString *musicBrainzAlbumID;
@property (nonatomic, retain) NSString *musicBrainzTrackID;

@property (nonatomic, retain) NSDictionary *additionalMetadata;

@property (nonatomic, retain) NSNumber *replayGainReferenceLoudness;
@property (nonatomic, retain) NSNumber *replayGainTrackGain;
@property (nonatomic, retain) NSNumber *replayGainTrackPeak;
@property (nonatomic, retain) NSNumber *replayGainAlbumGain;
@property (nonatomic, retain) NSNumber *replayGainAlbumPeak;

@property (nonatomic, retain) NSData *frontCoverArtData;
@end
