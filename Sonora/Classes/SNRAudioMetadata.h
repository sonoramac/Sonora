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
