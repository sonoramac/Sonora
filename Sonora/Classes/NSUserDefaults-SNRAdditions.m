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

#import "NSUserDefaults-SNRAdditions.h"

static NSString* const kUserDefaultsLastFMUsernameKey = @"lastFMUsername";
static NSString* const kUserDefaultsCellWidthKey = @"cellWidth";
static NSString* const kUserDefaultsVolumeKey = @"volume";
static NSString* const kUserDefaultsScrobble = @"scrobble";
static NSString* const kUserDefaultsSyncAddedFromiTunes = @"syncAddedFromiTunes";
static NSString* const kUserDefaultsSynciTunesPlaylistsKey = @"synciTunesPlaylists";
static NSString* const kUserDefaultsSortModeKey = @"albumsSortMode";
static NSString* const kUserDefaultsGrowlNowPlayingKey = @"growlNowPlaying";
static NSString* const kUserDefaultsGrowlNewImportKey = @"growlNewImport";
static NSString* const kUserDefaultsCopyMusicKey = @"copyMusic";
static NSString* const kUserDefaultsEmbedArtworkKey = @"embedArtwork";
static NSString* const kUserDefaultsRepeatModeKey = @"repeatMode";
static NSString* const kUserDefaultsLibraryPathKey = @"libraryPath";
static NSString* const kUserDefaultsLibraryBookmarkKey = @"libraryBookmark";
static NSString* const kUserDefaultsiTunesBookmarkKey = @"iTunesBookmark";
static NSString* const kUserDefaultsFirstImportKey = @"firstImport";
static NSString* const kUserDefaultsFirstMetadataiTunesKey = @"firstMetadataiTunes";
static NSString* const kUserDefaultsMemoryInputSourceKey = @"useMemoryInputSource";

@implementation NSUserDefaults (SNRAdditions)
- (NSString*)lastFMUsername
{
    return [self objectForKey:kUserDefaultsLastFMUsernameKey];
}

- (void)setLastFMUsername:(NSString*)username
{
    [self setObject:username forKey:kUserDefaultsLastFMUsernameKey];
}

- (float)volume
{
    return [self floatForKey:kUserDefaultsVolumeKey];
}

- (void)setVolume:(float)volume
{
    [self setFloat:volume forKey:kUserDefaultsVolumeKey];
}

- (CGFloat)cellWidth
{
    return [self doubleForKey:kUserDefaultsCellWidthKey];
}

- (void)setCellWidth:(CGFloat)cellWidth
{
    [self setDouble:cellWidth forKey:kUserDefaultsCellWidthKey];
}

- (BOOL)scrobble
{
    return [self boolForKey:kUserDefaultsScrobble];
}

- (void)setScrobble:(BOOL)scrobble
{
    [self setBool:scrobble forKey:kUserDefaultsScrobble];
}

- (BOOL)synciTunesSongs
{
    return [self boolForKey:kUserDefaultsSyncAddedFromiTunes];
}

- (void)setSynciTunesSongs:(BOOL)synciTunesSongs
{
    [self setBool:synciTunesSongs forKey:kUserDefaultsSyncAddedFromiTunes];
}

- (void)setSortMode:(NSInteger)mode
{
    [self setInteger:mode forKey:kUserDefaultsSortModeKey];
}

- (NSInteger)sortMode
{
    return [self integerForKey:kUserDefaultsSortModeKey];
}

- (BOOL)synciTunesPlaylists
{
    return [self boolForKey:kUserDefaultsSynciTunesPlaylistsKey];
}

- (void)setSynciTunesPlaylists:(BOOL)synciTunesPlaylists
{
    [self setBool:synciTunesPlaylists forKey:kUserDefaultsSynciTunesPlaylistsKey];
}

- (BOOL)growlNowPlaying
{
    return [self boolForKey:kUserDefaultsGrowlNowPlayingKey];
}

- (void)setGrowlNowPlaying:(BOOL)growlNowPlaying
{
    [self setBool:growlNowPlaying forKey:kUserDefaultsGrowlNowPlayingKey];
}

- (BOOL)growlNewImport
{
    return [self boolForKey:kUserDefaultsGrowlNewImportKey];
}

- (void)setGrowlNewImport:(BOOL)growlNewImport
{
    [self setBool:growlNewImport forKey:kUserDefaultsGrowlNewImportKey];
}

- (BOOL)copyMusic
{
    return [self boolForKey:kUserDefaultsCopyMusicKey];
}

- (void)setCopyMusic:(BOOL)copyMusic
{
    [self setBool:copyMusic forKey:kUserDefaultsCopyMusicKey];
}

- (BOOL)embedArtwork
{
    return [self boolForKey:kUserDefaultsEmbedArtworkKey];
}

- (void)setEmbedArtwork:(BOOL)embedArtwork
{
    [self setBool:embedArtwork forKey:kUserDefaultsEmbedArtworkKey];
}

- (NSInteger)repeatMode
{
    return [self integerForKey:kUserDefaultsRepeatModeKey];
}

- (void)setRepeatMode:(NSInteger)repeatMode
{
    [self setInteger:repeatMode forKey:kUserDefaultsRepeatModeKey];
}

- (void)setLibraryPath:(NSString*)libraryPath
{
    [self setObject:libraryPath forKey:kUserDefaultsLibraryPathKey];
}

- (NSString*)libraryPath
{
    return [self objectForKey:kUserDefaultsLibraryPathKey];
}

- (void)setFirstImport:(BOOL)firstImport
{
    [self setBool:firstImport forKey:kUserDefaultsFirstImportKey];
}

- (BOOL)firstImport
{
    return [self boolForKey:kUserDefaultsFirstImportKey];
}

- (BOOL)firstMetadataiTunes
{
    return [self boolForKey:kUserDefaultsFirstMetadataiTunesKey];
}

- (void)setFirstMetadataiTunes:(BOOL)firstMetadataiTunes
{
    [self setBool:firstMetadataiTunes forKey:kUserDefaultsFirstMetadataiTunesKey];
}

- (void)showFirstMetadataiTunesAlert
{
    if (self.firstMetadataiTunes) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"FirstMetadataiTunesTitle", nil) defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"FirstMetadataiTunesMessage", nil)];
        [alert runModal];
        self.firstMetadataiTunes = NO;
    }
}

- (BOOL)useMemoryInputSource
{
    return [self boolForKey:kUserDefaultsMemoryInputSourceKey];
}

- (void)setUseMemoryInputSource:(BOOL)memoryInputSource
{
    [self setBool:memoryInputSource forKey:kUserDefaultsMemoryInputSourceKey];
}
@end
