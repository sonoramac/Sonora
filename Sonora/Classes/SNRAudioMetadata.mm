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
#import "SNRAudioMetadata.h"
#import <SFBAudioEngine/AudioMetadata.h>
#import <SFBAudioEngine/AttachedPicture.h>

@implementation SNRAudioMetadata  {
    AudioMetadata *_metadata;
}

#pragma mark -
#pragma mark Initialization

- (id)initWithFileAtURL:(NSURL*)url
{
    if ((self = [super init])) {
        _metadata = AudioMetadata::CreateMetadataForURL((__bridge CFURLRef)url);
        if (_metadata == NULL) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    delete _metadata;
    _metadata = NULL;
}

#pragma mark -
#pragma mark Supported Formats

+ (NSArray*)supportedFileExtensions
{
    return (__bridge NSArray*)AudioMetadata::CreateSupportedFileExtensions();
}

+ (NSArray*)supportedMIMETypes
{
    return (__bridge NSArray*)AudioMetadata::CreateSupportedMIMETypes();
}

+ (BOOL)handlesFilesWithExtension:(NSString*)extension
{
    return (BOOL)AudioMetadata::HandlesFilesWithExtension((__bridge CFStringRef)extension);
}

+ (BOOL)handlesMIMEType:(NSString*)mimeType
{
    return (BOOL)AudioMetadata::HandlesMIMEType((__bridge CFStringRef)mimeType);
}

+ (NSArray*)supportedUTIs
{
    NSArray *mimeTypes = [self supportedMIMETypes];
    NSMutableArray *UTIs = [NSMutableArray array];
    for (NSString *mime in mimeTypes) {
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mime, NULL);
        if (uti) { [UTIs addObject:(__bridge_transfer NSString*)uti]; }
    }
    return UTIs;
}

#pragma mark -
#pragma mark Reading and Writing Metadata

- (BOOL)readMetadata
{
    return (BOOL)_metadata->ReadMetadata();
}

- (BOOL)writeMetadata
{
    return (BOOL)_metadata->WriteMetadata();
}

- (BOOL)hasUnsavedChanges
{
    return (BOOL)_metadata->HasUnsavedChanges();
}

- (void)revertUnsavedChanges
{
    _metadata->RevertUnsavedChanges();
}

#pragma mark -
#pragma mark Audio Properties

- (NSURL*)url
{
    return (__bridge NSURL*)_metadata->GetURL();
}

- (NSString*)formatName
{
    return (__bridge NSString*)_metadata->GetFormatName();
}

- (NSNumber*)totalFrames
{
    return (__bridge NSNumber*)_metadata->GetTotalFrames();
}

- (NSNumber*)channelsPerFrame
{
    return (__bridge NSNumber*)_metadata->GetChannelsPerFrame();
}

- (NSNumber*)bitsPerChannel
{
    return (__bridge NSNumber*)_metadata->GetBitsPerChannel();
}

- (NSNumber*)sampleRate
{
    return (__bridge NSNumber*)_metadata->GetSampleRate();
}

- (NSNumber*)duration
{
    return (__bridge NSNumber*)_metadata->GetDuration();
}

- (NSNumber*)bitrate
{
    return (__bridge NSNumber*)_metadata->GetBitrate();
}

#pragma mark -
#pragma mark Metadata Access

- (NSString*)title
{
    return (__bridge NSString*)_metadata->GetTitle();
}

- (void)setTitle:(NSString *)title
{
    _metadata->SetTitle((__bridge CFStringRef)title);
}

- (NSString*)albumTitle
{
    return (__bridge NSString*)_metadata->GetAlbumTitle();
}

- (void)setAlbumTitle:(NSString *)albumTitle
{
    _metadata->SetAlbumTitle((__bridge CFStringRef)albumTitle);
}

- (NSString*)artist
{
    return (__bridge NSString*)_metadata->GetArtist();
}

- (void)setArtist:(NSString *)artist
{
    _metadata->SetArtist((__bridge CFStringRef)artist);
}

- (NSString*)albumArtist
{
    return (__bridge NSString*)_metadata->GetAlbumArtist();
}

- (void)setAlbumArtist:(NSString *)albumArtist
{
    _metadata->SetAlbumArtist((__bridge CFStringRef)albumArtist);
}

- (NSString*)genre
{
    return (__bridge NSString*)_metadata->GetGenre();
}

- (void)setGenre:(NSString *)genre
{
    _metadata->SetGenre((__bridge CFStringRef)genre);
}

- (NSString*)composer
{
    return (__bridge NSString*)_metadata->GetComposer();
}

- (void)setComposer:(NSString *)composer
{
    _metadata->SetComposer((__bridge CFStringRef)composer);
}

- (NSString*)releaseDate
{
    return (__bridge NSString*)_metadata->GetReleaseDate();
}

- (void)setReleaseDate:(NSString *)releaseDate
{
    _metadata->SetReleaseDate((__bridge CFStringRef)releaseDate);
}

- (NSNumber*)compilation
{
    return (__bridge NSNumber*)_metadata->GetCompilation();
}

- (void)setCompilation:(NSNumber*)isCompilation
{
    _metadata->SetCompilation((__bridge CFBooleanRef)isCompilation);
}

- (NSNumber*)trackNumber
{
    return (__bridge NSNumber*)_metadata->GetTrackNumber();
}

- (void)setTrackNumber:(NSNumber *)trackNumber
{
    _metadata->SetTrackNumber((__bridge CFNumberRef)trackNumber);
}

- (NSNumber*)trackTotal
{
    return (__bridge NSNumber*)_metadata->GetTrackTotal();
}

- (void)setTrackTotal:(NSNumber *)trackTotal
{
    _metadata->SetTrackTotal((__bridge CFNumberRef)trackTotal);
}

- (NSNumber*)discNumber
{
    return (__bridge NSNumber*)_metadata->GetDiscNumber();
}

- (void)setDiscNumber:(NSNumber *)discNumber
{
    _metadata->SetDiscNumber((__bridge CFNumberRef)discNumber);
}

- (NSNumber*)discTotal
{
    return (__bridge NSNumber*)_metadata->GetDiscTotal();
}

- (void)setDiscTotal:(NSNumber *)discTotal
{
    _metadata->SetDiscTotal((__bridge CFNumberRef)discTotal);
}

- (NSString*)lyrics
{
    return (__bridge NSString*)_metadata->GetLyrics();
}

- (void)setLyrics:(NSString *)lyrics
{
    _metadata->SetLyrics((__bridge CFStringRef)lyrics);
}

- (NSString*)comment
{
    return (__bridge NSString*)_metadata->GetComment();
}

- (void)setComment:(NSString *)comment
{
    _metadata->SetComment((__bridge CFStringRef)comment);
}

- (NSString*)MCN
{
    return (__bridge NSString*)_metadata->GetMCN();
}

- (void)setMCN:(NSString *)MCN
{
    _metadata->SetMCN((__bridge CFStringRef)MCN);
}

- (NSString*)ISRC
{
    return (__bridge NSString*)_metadata->GetISRC();
}

- (void)setISRC:(NSString *)ISRC
{
    _metadata->SetISRC((__bridge CFStringRef)ISRC);
}

- (NSString*)musicBrainzAlbumID
{
    return (__bridge NSString*)_metadata->GetMusicBrainzReleaseID();
}

- (void)setMusicBrainzAlbumID:(NSString *)musicBrainzAlbumID
{
    _metadata->SetMusicBrainzReleaseID((__bridge CFStringRef)musicBrainzAlbumID);
}

- (NSString*)musicBrainzTrackID
{
    return (__bridge NSString*)_metadata->GetMusicBrainzRecordingID();
}

- (void)setMusicBrainzTrackID:(NSString *)musicBrainzTrackID
{
    _metadata->SetMusicBrainzRecordingID((__bridge CFStringRef)musicBrainzTrackID);
}

#pragma mark -
#pragma mark Additional Metadata

- (NSDictionary*)additionalMetadata
{
    return (__bridge NSDictionary*)_metadata->GetAdditionalMetadata();
}

- (void)setAdditionalMetadata:(NSDictionary *)additionalMetadata
{
    _metadata->SetAdditionalMetadata((__bridge CFDictionaryRef)additionalMetadata);
}

#pragma mark -
#pragma mark Replay Gain

- (NSNumber*)replayGainReferenceLoudness
{
    return (__bridge NSNumber*)_metadata->GetReplayGainReferenceLoudness();
}

- (void)setReplayGainReferenceLoudness:(NSNumber *)replayGainReferenceLoudness
{
    _metadata->SetReplayGainReferenceLoudness((__bridge CFNumberRef)replayGainReferenceLoudness);
}

- (NSNumber*)replayGainTrackGain
{
    return (__bridge NSNumber*)_metadata->GetReplayGainTrackGain();
}

- (void)setReplayGainTrackGain:(NSNumber *)replayGainTrackGain
{
    _metadata->SetReplayGainTrackGain((__bridge CFNumberRef)replayGainTrackGain);
}

- (NSNumber*)replayGainTrackPeak
{
    return (__bridge NSNumber*)_metadata->GetReplayGainTrackPeak();
}

- (void)setReplayGainTrackPeak:(NSNumber *)replayGainTrackPeak
{
    _metadata->SetReplayGainTrackPeak((__bridge CFNumberRef)replayGainTrackPeak);
}

- (NSNumber*)replayGainAlbumGain
{
    return (__bridge NSNumber*)_metadata->GetReplayGainAlbumGain();
}

- (void)setReplayGainAlbumGain:(NSNumber *)replayGainAlbumGain
{
    _metadata->SetReplayGainAlbumGain((__bridge CFNumberRef)replayGainAlbumGain);
}

- (NSNumber*)replayGainAlbumPeak
{
    return (__bridge NSNumber*)_metadata->GetReplayGainAlbumPeak();
}

- (void)setReplayGainAlbumPeak:(NSNumber *)replayGainAlbumPeak
{
    _metadata->SetReplayGainTrackPeak((__bridge CFNumberRef)replayGainAlbumPeak);
}

#pragma mark -
#pragma mark Album Artwork

- (NSData*)frontCoverArtData
{
	std::vector<AttachedPicture *> front = _metadata->GetAttachedPicturesOfType(AttachedPicture::Type::FrontCover);
	if (front.size()) {
		AttachedPicture *frontArt = front.at(0);
		return (__bridge NSData*)frontArt->GetData();
	} else {
		std::vector<AttachedPicture *> all = _metadata->GetAttachedPictures();
		if (all.size()) {
			AttachedPicture *art = all.at(0);
			return (__bridge NSData*)art->GetData();
		}
	}
	return nil;
}

- (void)setFrontCoverArtData:(NSData *)frontCoverArtData
{
	_metadata->RemoveAttachedPicturesOfType(AttachedPicture::Type::FrontCover);
	AttachedPicture *picture = new AttachedPicture;
	picture->SetType(AttachedPicture::Type::FrontCover);
	picture->SetData((__bridge CFDataRef)frontCoverArtData);
	_metadata->AttachPicture(picture);
	delete picture, picture = nullptr;
}

@end
